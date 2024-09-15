import 'dart:isolate' show Isolate, ReceivePort;
import 'package:ssh_rdp/action.dart' show ActionType;
import 'package:ssh_rdp/connectivity.dart'
    show monitorConnectivity, Connectivity;
import 'package:ssh_rdp/isolate/synchronize.dart' show synchronize;
import 'package:ssh_rdp/logging/logger.dart' show getLogger;
import 'package:ssh_rdp/process.dart' show isAlive;
import 'package:ssh_rdp/server_action.dart' show ServerAction;

final logger = getLogger();

extension Connectable on ServerAction {
  static final processes = <String, int>{};

  String get _hash => '$host:${type.name}';
  String get _otherHash {
    final otherType = type == ActionType.ssh ? ActionType.rdp : ActionType.ssh;
    return '$host:${otherType.name}';
  }

  int? get id => processes[_hash];
  set id(int? pid) {
    if (pid == null) {
      processes.remove(_hash);
      return;
    }
    processes[_hash] = pid;
  }

  int? get otherId => processes[_otherHash];
  set otherId(int? pid) {
    if (pid == null) {
      processes.remove(_otherHash);
      return;
    }
    processes[_otherHash] = pid;
  }

  Future<void> _connectSSH() async {
    final id = this.id;
    if (id is int && isAlive(id)) {
      logger.warning(
        "SSH port forwarding process ($id) for host '$host' is running.",
      );
      return;
    }

    final sshPid = await execute();
    logger.info(
      "Started SSH port forwarding process ($sshPid) for host '$host'.",
    );
    this.id = sshPid;
  }

  Future<void> _connectRDP() async {
    final otherId = this.otherId;
    if (otherId == null) {
      logger.warning(
        "SSH port forwarding process for host '$host' is unavailable.",
      );
      return;
    }

    if (!isAlive(otherId)) {
      logger.warning(
        "SSH port forwarding process ($otherId) for host '$host' has exited.",
      );
      this.otherId = null;
      return;
    }

    final id = this.id;
    if (id is int && isAlive(id)) {
      logger.warning(
        "Remote Desktop process ($id) for host '$host' is running.",
      );
      return;
    }

    final rdpPid = await execute();
    logger.info(
      "Started Remote Desktop process ($rdpPid) for host '$host'.",
    );
    this.id = rdpPid;

    await _setCallback(otherId, rdpPid);
  }

  Future<void> _setCallback(int sshPid, int rdpPid) async {
    final port = ReceivePort();

    port.listen(
      (_) {
        for (final entry in [...processes.entries]) {
          final (key, value) = (entry.key, entry.value);
          if (value == sshPid) {
            processes.remove(key);
            logger.info('Removed SSH port forwarding process ($value).');
            continue;
          }

          if (value == rdpPid) {
            processes.remove(key);
            logger.info('Removed Remote Desktop process ($value).');
            continue;
          }

          if (!isAlive(value)) {
            processes.remove(key);
            logger.info('Removed exited process ($value).');
          }
        }

        port.close();

        logger.info('Checking for internet connection...');
        monitorConnectivity().listen((connectivity) {
          switch (connectivity) {
            case Connectivity.unknown:
              logger.warning('Failed to check for internet connection.');
              break;
            case Connectivity.connected:
              logger.info(
                'Remote Desktop process has exited by user; do not attempt to reconnect.',
              );
              break;
            case Connectivity.reconnected:
              logger.info(
                "Remote Desktop process has exited due to network; reconnecting to host '$host'...",
              );
              ServerAction.fromMap({'type': 'ssh', 'host': host}).connect();
              break;
          }
        });
      },
    );

    await Isolate.spawn(
      synchronize,
      (sshPid, rdpPid),
      onExit: port.sendPort,
    );
  }

  Future<void> connect() {
    return switch (type) {
      ActionType.ssh => _connectSSH(),
      ActionType.rdp => _connectRDP(),
    };
  }
}
