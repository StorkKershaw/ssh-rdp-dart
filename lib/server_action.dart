import 'dart:io' show Process, ProcessStartMode;
import 'package:ssh_rdp/action.dart' show Action, ActionType;
import 'package:ssh_rdp/logging/logger.dart' show getLogger;
import 'package:ssh_rdp/panic.dart' show panic;

final logger = getLogger();

class ServerAction extends Action {
  final String? _user;
  final String? _password;
  final String? _file;

  @override
  final ActionType type;
  @override
  final String host;
  @override
  String get user => _user ?? panic();
  @override
  String get password => _password ?? panic();
  @override
  String get file => _file ?? panic();

  ServerAction._(
    this.type,
    this.host, [
    this._user,
    this._password,
    this._file,
  ]);

  factory ServerAction.fromMap(Map<String, dynamic> map) {
    final type = map['type'].toString();
    final host = map['host'].toString();

    final action = switch (type) {
      'ssh' => ServerAction._(
          ActionType.ssh,
          host,
        ),
      'rdp' => ServerAction._(
          ActionType.rdp,
          host,
          map['user'].toString(),
          map['password'].toString(),
          map['file'].toString(),
        ),
      _ => throw FormatException('Invalid action type: $type'),
    };

    return action;
  }

  Future<int> _executeSSH() async {
    final process = await Process.start(
      'conhost.exe',
      ['--headless', 'ssh.exe', host],
      mode: ProcessStartMode.detached,
    );
    return process.pid;
  }

  Future<int> _executeRDP() async {
    await Process.run(
      'cmdkey.exe',
      ['/add:TERMSRV/localhost', '/user:$user', '/pass:$password'],
    );
    final process = await Process.start(
      'mstsc.exe',
      [file],
      mode: ProcessStartMode.detached,
    );
    return process.pid;
  }

  Future<int> execute() {
    return switch (type) {
      ActionType.ssh => _executeSSH(),
      ActionType.rdp => _executeRDP(),
    };
  }
}
