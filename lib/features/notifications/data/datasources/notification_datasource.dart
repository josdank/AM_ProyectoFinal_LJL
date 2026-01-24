import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Import necesario para PostgresChangeFilterType en realtime_client 2.x
import 'package:realtime_client/realtime_client.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/notification_model.dart';

abstract class NotificationDatasource {
  Future<void> init();

  Future<void> showLocal({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  Future<void> scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  });

  Future<void> cancelLocal(int id);

  Future<AppNotificationModel> createInApp({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  });

  Future<List<AppNotificationModel>> getMyNotifications({required String userId});

  Future<void> markRead({required String notificationId});

  Stream<AppNotificationModel> streamNewNotifications({required String userId});
}

class NotificationDatasourceImpl implements NotificationDatasource {
  final FlutterLocalNotificationsPlugin plugin;
  final SupabaseClient client;

  bool _initialized = false;

  NotificationDatasourceImpl({
    required this.plugin,
    required this.client,
  });

  static const _table = 'notifications';

  @override
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await plugin.initialize(initSettings);
    _initialized = true;
  }

  @override
  Future<void> showLocal({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Notificaciones',
      channelDescription: 'Canal principal de notificaciones',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await plugin.show(id, title, body, details, payload: payload);
  }

  @override
  Future<void> scheduleLocal({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    String? payload,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Recordatorios',
      channelDescription: 'Recordatorios programados',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      payload: payload,
      // En flutter_local_notifications v19+, se usa AndroidScheduleMode
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelLocal(int id) async {
    await init();
    await plugin.cancel(id);
  }

  @override
  Future<AppNotificationModel> createInApp({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.from(_table).insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'data': data,
        'is_read': false,
      }).select().single();

      return AppNotificationModel.fromJson(Map<String, dynamic>.from(response));
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<AppNotificationModel>> getMyNotifications({required String userId}) async {
    try {
      final rows = await client
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (rows as List)
          .map((e) => AppNotificationModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markRead({required String notificationId}) async {
    try {
      await client.from(_table).update({'is_read': true}).eq('id', notificationId);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message, statusCode: _tryInt(e.code));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Stream<AppNotificationModel> streamNewNotifications({required String userId}) {
    final controller = StreamController<AppNotificationModel>.broadcast();

    final channel = client
        .channel('public:$_table:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,

          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),

          callback: (payload) {
            final record = payload.newRecord;
            if (record != null) {
              controller.add(
                AppNotificationModel.fromJson(Map<String, dynamic>.from(record)),
              );
            }
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await client.removeChannel(channel);
      await controller.close();
    };

    return controller.stream;
  }

  int? _tryInt(String? s) => s == null ? null : int.tryParse(s);
}
