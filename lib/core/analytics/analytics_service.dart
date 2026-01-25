import 'package:flutter/foundation.dart';

abstract class AnalyticsService {
  Future<void> logEvent(String name, {Map<String, Object>? parameters});
  Future<void> setUserId(String? userId);
  Future<void> setUserProperty({required String name, required String? value});
  Future<void> setCurrentScreen({required String screenName});
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (kDebugMode) {
      print('📊 analytics event: $name | params: ${parameters ?? {}}');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      print('📊 analytics userId: $userId');
    }
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (kDebugMode) {
      print('📊 analytics user property: $name = $value');
    }
  }

  @override
  Future<void> setCurrentScreen({required String screenName}) async {
    if (kDebugMode) {
      print('📊 analytics screen: $screenName');
    }
  }
}