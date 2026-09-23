import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/habits/domain/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    // Configura automaticamente tz.local sull'offset locale del dispositivo (evita il bug UTC)
    try {
      final localOffset = DateTime.now().timeZoneOffset.inMilliseconds;
      final matchedLocation = tz.timeZoneDatabase.locations.values.firstWhere(
        (loc) => loc.currentTimeZone.offset == localOffset,
        orElse: () => tz.getLocation('Europe/Rome'),
      );
      tz.setLocalLocation(matchedLocation);
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);

    // Richiesta permessi Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Richiesta permessi espliciti iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Pianifica una notifica giornaliera per l'abitudine
  Future<void> scheduleHabitNotification(Habit habit) async {
    if (habit.reminderTime == null) return;

    final time = _parseReminderTime(habit.reminderTime!);
    if (time == null) return;

    final notificationId = habit.id.hashCode & 0x7fffffff;

    // Cancella eventuali schedulazioni precedenti per questa abitudine
    await cancelNotification(habit.id);

    final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for daily habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Permette di mostrare banner e suoni anche se l'app è aperta a schermo (iOS)
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: 'Promemoria Abitudine 🎯',
      body: 'È ora di completare: ${habit.title}',
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Annulla la notifica programmata per un'abitudine
  Future<void> cancelNotification(String habitId) async {
    final notificationId = habitId.hashCode & 0x7fffffff;
    await _notificationsPlugin.cancel(id: notificationId);
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Converte stringhe tipo "07:30 AM" o "08:15 PM" in ore e minuti (24h)
  _HourMinute? _parseReminderTime(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final period = parts.length > 1 ? parts[1].toUpperCase() : null;

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return _HourMinute(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }
}

class _HourMinute {
  final int hour;
  final int minute;
  _HourMinute({required this.hour, required this.minute});
}
