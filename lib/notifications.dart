import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationWeekAndTime {
  final int dayOfTheWeek;
  final TimeOfDay timeOfDay;

  NotificationWeekAndTime(this.dayOfTheWeek, this.timeOfDay);
}

Future<void> savedFoodReminder(
    NotificationWeekAndTime notificationSchedule) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'scheduled_notification',
        title:
            '${Emojis.emotion_orange_heart} Yuk selamatkan lebih banyak makanan!',
        body:
            'Cek berapa makanan yang sudah kamu selamatkan minggu ini ${Emojis.activites_party_popper}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
          weekday: notificationSchedule.dayOfTheWeek,
          hour: notificationSchedule.timeOfDay.hour,
          minute: notificationSchedule.timeOfDay.minute,
          second: 0,
          millisecond: 0,
          repeats: true));
}
