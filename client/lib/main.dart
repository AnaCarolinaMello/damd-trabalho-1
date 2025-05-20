import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';
import 'package:damd_trabalho_1/theme/Theme.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/views/setup/pages/Welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // INICIALIZA O FIREBASE

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  // Initialize database with error handling
  try {
    await DatabaseService.instance.database;
    print("Database initialized successfully");
  } catch (e) {
    print("Error initializing database: $e");
    // Continue with app startup even if database fails
    // The app will handle database errors gracefully
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  // This widget is the root of your application.
  late String user;
  bool loading = true;

  getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('user') ?? '';
      loading = false;
    });
  }

  void setupFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicita permissão (necessário para iOS, opcional no Android)
    NotificationSettings settings = await messaging.requestPermission();

    // Obtem token FCM do dispositivo (salve no backend se quiser enviar push por ID)
    String? token = await messaging.getToken();
    print("FCM Token: $token");

    // Aparecer as mensagens em foreground (quando o app está aberto)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("Mensagem recebida no foreground: ${message.notification!.title}");

        showDialog(
          context: navigatorKey.currentContext!,
          builder: (context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'Notificação'),
              content: Text(message.notification!.body ?? ''),
              actions: [
               TextButton(
                 onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
               ),
              ],
            );
          },
        );
      }
    });


   // Mensagem quando o app é aberto via notificação
   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp: ${message.data}');

    final screen = message.data['screen'];
      if (screen == 'orders') {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MainScreen(item: 'orders'),
         ),
       );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    setupFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder:
          (context, themeNotifier, child) => MaterialApp(
            title: 'Serviço de Rastreio',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeNotifier.themeMode,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : user != null
                    ? MainScreen()
                    : const WelcomePage(),
          ),
    );
  }
}
