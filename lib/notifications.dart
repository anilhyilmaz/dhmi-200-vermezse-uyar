import 'package:awesome_notifications/awesome_notifications.dart';

Future<void> createNotifications() async {
  DateTime now = DateTime.now();
  var time = now.hour.toString() +
      ":" +
      now.minute.toString() +
      ":" +
      now.second.toString();
  now.second.toString();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'DHMİ',
        body:
        'Siteye ulaşılamıyor, $time',
        criticalAlert: true,
      ),actionButtons: [NotificationActionButton(key: 'MARK_DONE', label: 'pingi durdur')]);
}
