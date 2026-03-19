import 'dart:io';

class Logger {
    static File? _logFile;

    static Future<void> init() async {
        final exePath = Platform.resolvedExecutable;
        final directory = File(exePath).parent.path;
        final logPath = '$directory/app.log';
        print('Logger initialized, log file path: $logPath');
        _logFile = File(logPath);

        if (!await _logFile!.exists()) {
            await _logFile!.create(recursive: true);
        }
    }

    static Future<void> write(String message) async {
        if (_logFile == null) {
            await init();
        }

        final row = DateTime.now().toIso8601String();
        final line = '[$row] $message\n';

        await _logFile!.writeAsString(line, mode: FileMode.append, flush: true);
    }
}