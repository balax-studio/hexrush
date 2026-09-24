import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../localization/game_localization.dart';
import '../../domain/models/game_state_model.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  FlutterLocalNotificationsPlugin? _pluginInstance;
  FlutterLocalNotificationsPlugin get _plugin =>
      _pluginInstance ??= FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const int idIdle1h = 100;
  static const int idIdle4h = 101;
  static const int idInactivity24h = 102;
  static const int idDailyCouncil = 201;
  static const int idDailyHarvest = 202;

  static const String channelId = 'hexrush_steppe_channel';
  static const String channelName = 'HexRush Steppe Notifications';
  static const String channelDescription = 'Production alerts, council decrees and harvest reports.';

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(initSettings);
      _isInitialized = true;
    } catch (e) {
      // Test ve desteklenmeyen ortamlarda sessizce atla
    }
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
      final macOsImplementation =
          _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
      if (macOsImplementation != null) {
        final granted = await macOsImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[LocalNotificationService] Request permission error: $e');
    }
    return false;
  }

  NotificationDetails _notificationDetails({required String title, required String body}) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
      ),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  /// Oyuncu oyundan ayrıldığında (arka plana geçtiğinde) tüm bildirimleri takvimler.
  Future<void> scheduleOnAppBackground({
    required SettingsModel settings,
  }) async {
    if (kIsWeb) return;
    if (!settings.notifications.enabled) {
      await cancelAll();
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    final lang = settings.language;

    try {
      // 1. 1 Saat Sonra: Bozkır Devriyesi
      if (settings.notifications.idle1hAlert) {
        final title1h = GameLocalization.get('notif_idle_1h_title', lang: lang);
        final body1h = GameLocalization.get('notif_idle_1h_body', lang: lang);
        final scheduleTime1h = tz.TZDateTime.now(tz.local).add(const Duration(hours: 1));

        await _plugin.zonedSchedule(
          idIdle1h,
          title1h,
          body1h,
          scheduleTime1h,
          _notificationDetails(title: title1h, body: body1h),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // 2. 4 Saat Sonra: Bozkır Üretimi Hazır
      if (settings.notifications.idle4hAlert) {
        final title4h = GameLocalization.get('notif_idle_4h_title', lang: lang);
        final body4h = GameLocalization.get('notif_idle_4h_body', lang: lang);
        final scheduleTime4h = tz.TZDateTime.now(tz.local).add(const Duration(hours: 4));

        await _plugin.zonedSchedule(
          idIdle4h,
          title4h,
          body4h,
          scheduleTime4h,
          _notificationDetails(title: title4h, body: body4h),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // 3. 24 Saat Sonra: Bozkırda Yeni Gün (İnaktiflik)
      if (settings.notifications.inactivityAlert) {
        final title24h = GameLocalization.get('notif_inactivity_title', lang: lang);
        final body24h = GameLocalization.get('notif_inactivity_body', lang: lang);
        final scheduleTime24h = tz.TZDateTime.now(tz.local).add(const Duration(hours: 24));

        await _plugin.zonedSchedule(
          idInactivity24h,
          title24h,
          body24h,
          scheduleTime24h,
          _notificationDetails(title: title24h, body: body24h),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      // 4. Günlük Öğle Kurultayı (12:30)
      if (settings.notifications.dailyCouncilAlert) {
        final titleCouncil = GameLocalization.get('notif_daily_council_title', lang: lang);
        final bodyCouncil = GameLocalization.get('notif_daily_council_body', lang: lang);
        final nextCouncilTime = _nextInstanceOfTime(12, 30);

        await _plugin.zonedSchedule(
          idDailyCouncil,
          titleCouncil,
          bodyCouncil,
          nextCouncilTime,
          _notificationDetails(title: titleCouncil, body: bodyCouncil),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      // 5. Günlük Akşam Hasat Raporu (20:00)
      if (settings.notifications.dailyHarvestAlert) {
        final titleHarvest = GameLocalization.get('notif_daily_harvest_title', lang: lang);
        final bodyHarvest = GameLocalization.get('notif_daily_harvest_body', lang: lang);
        final nextHarvestTime = _nextInstanceOfTime(20, 0);

        await _plugin.zonedSchedule(
          idDailyHarvest,
          titleHarvest,
          bodyHarvest,
          nextHarvestTime,
          _notificationDetails(title: titleHarvest, body: bodyHarvest),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      debugPrint('[LocalNotificationService] Schedule error: $e');
    }
  }

  /// Oyuncu oyuna döndüğünde tetiklenmemiş boşta (idle) bildirimlerini iptal eder.
  Future<void> cancelIdleNotifications() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancel(idIdle1h);
      await _plugin.cancel(idIdle4h);
      await _plugin.cancel(idInactivity24h);
    } catch (e) {
      debugPrint('[LocalNotificationService] Cancel idle error: $e');
    }
  }

  /// Tüm zamanlanmış bildirimleri iptal eder (Bildirimler kapatıldığında).
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[LocalNotificationService] Cancel all error: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
