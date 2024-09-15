import 'dart:ffi' show sizeOf, Uint32, Uint32Pointer;
import 'package:ffi/ffi.dart' show malloc;
import 'package:ssh_rdp/logging/logger.dart' show getLogger;
import 'package:win32/win32.dart'
    show
        FALSE,
        FILE_ACCESS_RIGHTS,
        INFINITE,
        NULL,
        PROCESS_ACCESS_RIGHTS,
        STILL_ACTIVE,
        CloseHandle,
        GetExitCodeProcess,
        OpenProcess,
        WaitForSingleObject;

final logger = getLogger();

bool isAlive(int pid) {
  final hProcess = OpenProcess(
    PROCESS_ACCESS_RIGHTS.PROCESS_QUERY_LIMITED_INFORMATION,
    FALSE,
    pid,
  );

  if (hProcess == NULL) {
    logger.warning('Failed to open process ($pid).');
    return false;
  }

  final lpExitCode = malloc.allocate<Uint32>(sizeOf<Uint32>());
  GetExitCodeProcess(hProcess, lpExitCode);
  final exitCode = lpExitCode.value;
  CloseHandle(hProcess);
  malloc.free(lpExitCode);

  if (exitCode != STILL_ACTIVE) {
    logger.info('Retrieved exit code $exitCode from process ($pid).');
    return false;
  }

  logger.info(
    'Retrieved exit code $exitCode (STILL_ACTIVE) from process ($pid).',
  );
  return true;
}

void waitProcess(int pid) {
  final hProcess = OpenProcess(FILE_ACCESS_RIGHTS.SYNCHRONIZE, FALSE, pid);
  if (hProcess == NULL) {
    return;
  }

  WaitForSingleObject(hProcess, INFINITE);
  CloseHandle(hProcess);
}
