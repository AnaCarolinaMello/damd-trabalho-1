import 'package:damd_trabalho_1/services/Api.dart';
import 'package:damd_trabalho_1/services/NotificationService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationController {
  static final path = 'notification';
  static final Set<String> _notifiedIds = <String>{}; // Controle de notificações já exibidas

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      // Pegar o userId do usuário logado
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      
      if (userString != null) {
        final userJson = jsonDecode(userString);
        final userId = userJson['id'];
        
        // Fazer GET request para buscar notificações
        final response = await ApiService.get('$path/$userId');
        print('response: $response');
        
        // Exibir push notification para cada notificação não lida e não notificada ainda
        if (response is List) {
          for (var notification in response) {
            final notificationId = _notifiedIds.length + 1;
            final isUnread = notification['sent'] == false;
            final notAlreadyNotified = !_notifiedIds.contains(notification['id']);
            print('notificationId: $notificationId');
            print('isUnread: $isUnread');
            print('notAlreadyNotified: $notAlreadyNotified');
            
            if (isUnread && notAlreadyNotified) {
              print('Nova notificação: $notification');
              await NotificationService.showLocalNotification(
                title: notification['title'] ?? 'Nova Notificação',
                body: notification['message'] ?? '',
                id: notificationId,
              );
              
              // Marcar como notificada
              await ApiService.put('$path/${notification['id']}', {});
              print('notificação atualizada');
              _notifiedIds.add(notification['id']);
            }
          }
          return List<Map<String, dynamic>>.from(response);
        }
      }
      return [];
    } catch (e) {
      print('error getNotifications: $e');
      return [];
    }
  }

  static Future<void> createNotification() async {
    try {
      await ApiService.post(path, {});
    } catch (e) {
      print('error createNotification: $e');
    }
  }
  
  // Método para limpar o cache de notificações (útil para testes)
  static void clearNotificationCache() {
    _notifiedIds.clear();
    print('Cache de notificações limpo');
  }
}