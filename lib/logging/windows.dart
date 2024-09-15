import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart' show Level, LogRecord;
import 'package:ssh_rdp/logging/utils.dart' show FormatMessage;
import 'package:ssh_rdp/panic.dart' show panic;
import 'package:ssh_rdp/windows/advapi32.dart'
    show EVENTLOG_TYPE, DeregisterEventSource, RegisterEventSource, ReportEvent;
import 'package:win32/win32.dart' show CloseHandle;

const eventViewerFormat = '{message}\n---\n{library}:{function} (line: {line})';
const _appName = 'ssh-rdpd';

void eventViewerHandler(String logFormat, LogRecord record) {
  // before running this code, you need to run the following command as an administrator:
  // New-EventLog -LogName Application -Source 'ssh-rdpd'
  final lpSourceName = _appName.toNativeUtf16();
  final hEventLog = RegisterEventSource(nullptr, lpSourceName);
  if (hEventLog == 0) {
    panic(Exception('Failed to register event source.'));
  }

  final lpStrings = malloc.allocate<Pointer<Utf16>>(sizeOf<Pointer<Utf16>>());
  lpStrings.value = record.formatMessage(logFormat).toNativeUtf16();

  final wType = switch (record.level) {
    Level.FINE => EVENTLOG_TYPE.SUCCESS,
    Level.INFO => EVENTLOG_TYPE.INFORMATION,
    Level.WARNING => EVENTLOG_TYPE.WARNING,
    Level.SEVERE => EVENTLOG_TYPE.ERROR,
    _ => panic(Exception("Cannot map the level '${record.level.name}'.")),
  };

  ReportEvent(hEventLog, wType, 0, 0, nullptr, 1, 0, lpStrings, nullptr);
  DeregisterEventSource(hEventLog);
  CloseHandle(hEventLog);

  malloc.free(lpStrings.value);
  malloc.free(lpStrings);
  malloc.free(lpSourceName);
}
