import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';
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

  @override
  void initState() {
    super.initState();
    getUser();
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
                    : user != null
                    ? MainScreen()
                    : const WelcomePage(),
          ),
    );
  }
}
