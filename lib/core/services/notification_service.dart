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

    // Permessi Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Permessi iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Pianifica le notifiche settimanali SOLO per i giorni selezionati in frequencyDays
  Future<void> scheduleHabitNotification(Habit habit) async {
    // Rimuove sempre le vecchie notifiche prima di ripianificare
    await cancelNotification(habit.id);

    if (habit.reminderTime == null || habit.frequencyDays.isEmpty) return;

    final time = _parseReminderTime(habit.reminderTime!);
    if (time == null) return;

    const androidDetails = AndroidNotificationDetails(
      'habit_reminders_channel',
      'Habit Reminders',
      channelDescription: 'Notifications for daily habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Pianifica una notifica settimanale per ogni giorno scelto
    for (final weekday in habit.frequencyDays) {
      final scheduledDate = _nextInstanceOfWeekdayAndTime(
        weekday,
        time.hour,
        time.minute,
        habit.startDate,
      );

      final notificationId = _getNotificationId(habit.id, weekday);

      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Promemoria Abitudine 🎯',
        body: 'È ora di completare: ${habit.title}',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  /// Annulla tutti i promemoria pianificati per tutti i giorni della settimana
  Future<void> cancelNotification(String habitId) async {
    for (int day = 1; day <= 7; day++) {
      await _notificationsPlugin.cancel(id: _getNotificationId(habitId, day));
    }
    // Rimuove anche l'eventuale ID generato con la vecchia logica singola
    await _notificationsPlugin.cancel(id: habitId.hashCode & 0x7fffffff);
  }

  /// Genera un ID univoco a 31-bit per ciascun giorno della settimana dell'abitudine
  int _getNotificationId(String habitId, int weekday) {
    return ((habitId.hashCode & 0x07ffffff) * 10) + weekday;
  }

  /// Calcola la prossima data valida che corrisponde sia al giorno della settimana sia all'orario
  tz.TZDateTime _nextInstanceOfWeekdayAndTime(
    int weekday,
    int hour,
    int minute,
    String startDateStr,
  ) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Rispetta la data di inizio (startDate) se fissata nel futuro
    try {
      final parts = startDateStr.split('-');
      final startDateTime = tz.TZDateTime(
        tz.local,
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
        hour,
        minute,
      );
      if (scheduledDate.isBefore(startDateTime)) {
        scheduledDate = startDateTime;
        while (scheduledDate.weekday != weekday) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }
    } catch (_) {}

    return scheduledDate;
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
