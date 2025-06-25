import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:damd_trabalho_1/controllers/notification.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static Timer? _notificationTimer;
  
  static Future<void> initialize() async {
    // Configurar notificações locais
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _localNotifications.initialize(initializationSettings);
    
    if (kDebugMode) {
      print('Local notifications initialized successfully');
    }
    
    // Solicitar permissões
    await _requestPermissions();
    
    // Configurar handlers de mensagens
    _setupMessageHandlers();
    
    // Iniciar timer para verificar notificações a cada 10 segundos
    startNotificationTimer();
  }
  
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }
  }
  
  static void _setupMessageHandlers() {
    // Quando o app está em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }
      
      if (message.notification != null) {
        _showLocalNotification(message.notification!);
      }
    });
    
    // Quando o app é aberto por uma notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      // Navegar para tela específica se necessário
    });
  }
  
  static Future<void> _showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'delivery_channel',
      'Delivery Notifications',
      channelDescription: 'Notificações de entrega',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      0,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }
  
  static void startNotificationTimer() {
    _notificationTimer?.cancel(); // Cancelar timer anterior se existir
    
    _notificationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (kDebugMode) {
        print('Verificando notificações...');
      }
      
      try {
        await NotificationController.getNotifications();
      } catch (e) {
        if (kDebugMode) {
          print('Erro ao verificar notificações: $e');
        }
      }
    });
    
    if (kDebugMode) {
      print('Timer de notificações iniciado - verificando a cada 30 segundos');
    }
  }
  
  static void stopNotificationTimer() {
    _notificationTimer?.cancel();
    _notificationTimer = null;
    
    if (kDebugMode) {
      print('Timer de notificações parado');
    }
  }
  
  static Future<void> showLocalNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'delivery_channel',
      'Delivery Notifications',
      channelDescription: 'Notificações de entrega',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
} 