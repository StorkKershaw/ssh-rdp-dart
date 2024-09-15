import 'package:logging/logging.dart'
    show recordStackTraceAtLevel, Level, Logger;
import 'package:ssh_rdp/logging/utils.dart'
    show oneLineFormat, stderrHandler, Handler;

export 'package:ssh_rdp/logging/utils.dart';
export 'package:ssh_rdp/logging/windows.dart';

Logger? _logger;

Logger _configureLogger({
  required Level level,
  required bool showStackTrace,
  required String logFormat,
  required Handler handler,
}) {
  if (showStackTrace) {
    recordStackTraceAtLevel = Level.ALL;
  }

  return Logger.root
    ..level = level
    ..onRecord.listen((record) => handler(logFormat, record));
}

Logger getLogger({
  Level level = Level.INFO,
  bool showStackTrace = false,
  String logFormat = oneLineFormat,
  Handler handler = stderrHandler,
}) {
  return _logger ??= _configureLogger(
    level: level,
    showStackTrace: showStackTrace,
    logFormat: logFormat,
    handler: handler,
  );
}
