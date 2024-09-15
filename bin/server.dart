import 'dart:convert' show jsonDecode, utf8;
import 'dart:io' show ServerSocket, InternetAddress;
import 'package:ssh_rdp/connectable.dart' show Connectable;
import 'package:ssh_rdp/logging/logger.dart'
    show eventViewerFormat, eventViewerHandler, getLogger;
import 'package:ssh_rdp/server_action.dart' show ServerAction;

final logger = getLogger(
  showStackTrace: true,
  logFormat: eventViewerFormat,
  handler: eventViewerHandler,
);

Future<void> main() async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 1999);
  logger.info(
    'Server is listening on ${server.address.address}:${server.port}.',
  );

  await for (final socket in server) {
    await for (final data in socket) {
      final map = Map<String, dynamic>.from(jsonDecode(utf8.decode(data)));
      await ServerAction.fromMap(map).connect();
    }
  }
}
