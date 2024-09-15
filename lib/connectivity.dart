import 'dart:ffi';
import 'dart:io';
import 'package:win32/win32.dart';

enum Connectivity {
  unknown,
  connected,
  reconnected,
}

Stream<Connectivity> monitorConnectivity() async* {
  if (FAILED(CoInitializeEx(nullptr, COINIT.COINIT_MULTITHREADED))) {
    yield Connectivity.unknown;
    return;
  }

  try {
    final manager = NetworkListManager.createInstance();
    if (manager.isConnectedToInternet != 0) {
      yield Connectivity.connected;
      return;
    }

    while (manager.isConnectedToInternet == 0) {
      sleep(const Duration(seconds: 1));
    }

    yield Connectivity.reconnected;
  } finally {
    CoUninitialize();
  }
}
