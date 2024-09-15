import 'dart:io' show stderr;
import 'package:format/format.dart' show format;
import 'package:logging/logging.dart' show LogRecord;
import 'package:path/path.dart' show context;
import 'package:stack_trace/stack_trace.dart' show Trace;

typedef Handler = void Function(String logFormat, LogRecord record);

const oneLineFormat =
    '[{time}] {level}: {message} - {library}:{function} (line: {line})';

extension FormatMessage on LogRecord {
  String formatMessage(String logFormat) {
    final stackTrace = this.stackTrace;
    final frame =
        stackTrace is StackTrace ? Trace.from(stackTrace).frames[2] : null;

    final variables = {
      #time: time,
      #level: level.name,
      #message: message,
      #library: frame?.library.replaceAll(context.separator, '/'),
      #function: frame?.member,
      #line: frame?.line,
    };
    return format(logFormat, variables);
  }
}

void stderrHandler(String logFormat, LogRecord record) =>
    stderr.writeln(record.formatMessage(logFormat));
