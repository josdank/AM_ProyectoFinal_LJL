import 'package:flutter/foundation.dart';

/// Servicio de analítica desacoplado (Clean Architecture).
/// 
/// Este archivo NO depende de Firebase para no romper compilación.
/// Más adelante puedes implementar FirebaseAnalytics y reemplazar
/// esta clase en el injection_container.
abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object?>? parameters});
  Future<void> setUserId(String? userId);
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object?>? parameters}) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('📊 analytics event: $name | params: ${parameters ?? {}}');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      // ignore: avoid_print
      print('📊 analytics userId: $userId');
    }
  }
}
