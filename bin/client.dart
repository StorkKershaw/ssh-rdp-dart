import 'dart:io' show exit, stderr;
import 'package:args/args.dart' show ArgParser;
import 'package:ssh_rdp/client_action.dart' show ClientAction;
import 'package:ssh_rdp/panic.dart' show panic;

ArgParser buildParser() {
  return ArgParser()
    ..addOption(
      'user',
      abbr: 'u',
      help: 'The user to connect.',
    )
    ..addOption(
      'password',
      abbr: 'p',
      help: 'The password to use.',
    )
    ..addOption(
      'file',
      abbr: 'f',
      help: 'The rdp file to use.',
    );
}

Future<void> main(List<String> arguments) async {
  final parser = buildParser();
  try {
    final results = parser.parse(arguments);

    final host =
        results.rest.firstOrNull ?? panic(FormatException('No host provided.'));
    final user = results.option('user');
    final password = results.option('password');
    final file = results.option('file');

    final action = user == null || password == null || file == null
        ? ClientAction.ssh(host)
        : ClientAction.rdp(host, user, password, file);

    await action.send();
  } catch (e) {
    stderr.writeln(e.toString());
    stderr.writeln('Usage: ssh_rdp.exe <host> [options]');
    stderr.writeln('Options:');
    stderr.writeln(parser.usage);
    exit(1);
  }
}
