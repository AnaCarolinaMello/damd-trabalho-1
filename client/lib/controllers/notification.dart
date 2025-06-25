import 'package:damd_trabalho_1/services/Api.dart';

class NotificationController {
  static final path = 'notification';

  static Future<void> createNotification() async {
    try {
      await ApiService.post(path, {});
    } catch (e) {
      print('error createNotification: $e');
    }
  }
}