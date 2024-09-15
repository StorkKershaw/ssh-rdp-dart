import 'dart:io' show Process;
import 'package:ssh_rdp/logging/logger.dart'
    show eventViewerFormat, eventViewerHandler, getLogger;
import 'package:ssh_rdp/process.dart' show waitProcess;

void synchronize((int, int) pid) {
  final logger = getLogger(
    showStackTrace: true,
    logFormat: eventViewerFormat,
    handler: eventViewerHandler,
  );
  final (sshPid, rdpPid) = pid;

  waitProcess(rdpPid);
  logger.info('Remote Desktop process ($rdpPid) has exited.');

  Process.runSync(
    'taskkill.exe',
    ['/F', '/T', '/PID', sshPid.toString()],
  );
  logger.info('Terminated SSH port forwarding process ($sshPid).');
}
