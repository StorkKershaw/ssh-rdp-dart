import 'dart:convert' show jsonEncode;
import 'dart:io' show InternetAddress, Socket;
import 'package:ssh_rdp/action.dart' show Action, ActionType;
import 'package:ssh_rdp/panic.dart' show panic;

class ClientAction extends Action {
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

  ClientAction._(
    this.type,
    this.host, [
    this._user,
    this._password,
    this._file,
  ]);

  factory ClientAction.ssh(String host) {
    return ClientAction._(ActionType.ssh, host);
  }

  factory ClientAction.rdp(
      String host, String user, String password, String file) {
    return ClientAction._(ActionType.rdp, host, user, password, file);
  }

  Map<String, String?> get _payload => switch (type) {
        ActionType.ssh => {
            'type': type.name,
            'host': host,
          },
        ActionType.rdp => {
            'type': type.name,
            'host': host,
            'user': user,
            'password': password,
            'file': file,
          },
      };

  Future<void> send() async {
    final socket = await Socket.connect(InternetAddress.loopbackIPv4, 1999);
    socket.write(jsonEncode(_payload));
    await socket.flush();
    socket.destroy();
  }
}
