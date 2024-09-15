import 'dart:ffi';
import 'package:ffi/ffi.dart';

final _advapi32 = DynamicLibrary.open('advapi32.dll');

extension type const EVENTLOG_TYPE(int _) implements int {
  static const SUCCESS = 0x0000;
  static const INFORMATION = 0x0004;
  static const WARNING = 0x0002;
  static const ERROR = 0x0001;
}

typedef _RegisterEventSourceC = IntPtr Function(Pointer<Utf16>, Pointer<Utf16>);
typedef _RegisterEventSourceDart = int Function(Pointer<Utf16>, Pointer<Utf16>);
final _RegisterEventSource =
    _advapi32.lookupFunction<_RegisterEventSourceC, _RegisterEventSourceDart>(
  'RegisterEventSourceW',
);

int RegisterEventSource(
  Pointer<Utf16> lpUNCServerName,
  Pointer<Utf16> lpSourceName,
) {
  return _RegisterEventSource(lpUNCServerName, lpSourceName);
}

typedef _DeregisterEventSourceC = Int32 Function(IntPtr);
typedef _DeregisterEventSourceDart = int Function(int);
final _DeregisterEventSource = _advapi32
    .lookupFunction<_DeregisterEventSourceC, _DeregisterEventSourceDart>(
  'DeregisterEventSource',
);

int DeregisterEventSource(int hEventLog) {
  return _DeregisterEventSource(hEventLog);
}

typedef _ReportEventC = Int32 Function(
  IntPtr hEventLog,
  Uint16 wType,
  Uint16 wCategory,
  Uint32 dwEventID,
  Pointer<Opaque> lpUserSid,
  Uint16 wNumStrings,
  Uint32 dwDataSize,
  Pointer<Pointer<Utf16>> lpStrings,
  Pointer<Opaque> lpRawData,
);

typedef _ReportEventDart = int Function(
  int hEventLog,
  int wType,
  int wCategory,
  int dwEventID,
  Pointer<Never> lpUserSid,
  int wNumStrings,
  int dwDataSize,
  Pointer<Pointer<Utf16>> lpStrings,
  Pointer<Never> lpRawData,
);

final _ReportEvent = _advapi32.lookupFunction<_ReportEventC, _ReportEventDart>(
  'ReportEventW',
);

int ReportEvent(
  int hEventLog,
  int wType,
  int wCategory,
  int dwEventID,
  Pointer<Never> lpUserSid,
  int wNumStrings,
  int dwDataSize,
  Pointer<Pointer<Utf16>> lpStrings,
  Pointer<Never> lpRawData,
) {
  return _ReportEvent(
    hEventLog,
    wType,
    wCategory,
    dwEventID,
    lpUserSid,
    wNumStrings,
    dwDataSize,
    lpStrings,
    lpRawData,
  );
}
