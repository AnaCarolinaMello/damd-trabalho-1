import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';
import 'package:damd_trabalho_1/services/NotificationService.dart';
import 'package:damd_trabalho_1/theme/Theme.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/views/setup/pages/Welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damd_trabalho_1/services/Database.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize shared preferences
  await SharedPreferences.getInstance();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Initialize notification service
  try {
    await NotificationService.initialize();
    print("Notification service initialized successfully");
  } catch (e) {
    print("Error initializing notification service: $e");
  }

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

class _MyApp extends State<MyApp> with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUser();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.stopNotificationTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        NotificationService.startNotificationTimer();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        NotificationService.stopNotificationTimer();
        break;
      case AppLifecycleState.hidden:
        break;
    }
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
            home:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : user.isNotEmpty
                    ? MainScreen()
                    : const WelcomePage(),
          ),
    );
  }
}
