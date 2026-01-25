import 'package:sentry_flutter/sentry_flutter.dart';

class SentryService {
  static Future<void> init() async {
    await SentryFlutter.init(
      (options) {
        options.dsn = 'https://tu-dsn@sentry.io/project-id';
        options.tracesSampleRate = 0.2;
        options.enableAppLifecycleBreadcrumbs = true;
        options.attachStacktrace = true;
        options.debug = false;
      },
      appRunner: () {
        // Tu app se ejecuta aquí
      },
    );
  }

  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Hint? hint, // CAMBIO AQUÍ
    Map<String, dynamic>? extra,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: hint,
      withScope: (scope) {
        if (extra != null) {
          extra.forEach((key, value) {
            scope.setExtra(key, value); // CAMBIO AQUÍ
          });
        }
      },
    );
  }

  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    await Sentry.captureMessage(message, level: level);
  }
}
