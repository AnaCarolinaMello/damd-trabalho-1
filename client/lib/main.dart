import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:damd_trabalho_1/services/ThemeNotifier.dart';
import 'package:damd_trabalho_1/theme/Theme.dart';
import 'package:damd_trabalho_1/views/main/MainScreen.dart';
import 'package:damd_trabalho_1/views/setup/pages/Welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:damd_trabalho_1/services/Database.dart';
import 'package:damd_trabalho_1/services/Sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SharedPreferences.getInstance();

  final databaseService = DatabaseService.instance;
  try {
    await databaseService.database;
    print("Database initialized successfully");
  } catch (e) {
    print("Error initializing database: $e");
  }

  final syncService = SyncService(databaseService: databaseService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        Provider<SyncService>(create: (_) => syncService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String user;
  bool loading = true;
  late SyncService syncService;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await getUser();
    syncService = Provider.of<SyncService>(context, listen: false);
    syncService.initializeSync();
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      user = prefs.getString('user') ?? '';
      loading = false;
    });
  }

  @override
  void dispose() {
    syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) => MaterialApp(
        title: 'Serviço de Rastreio',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeNotifier.themeMode,
        debugShowCheckedModeBanner: false,
        home: loading
            ? const Center(child: CircularProgressIndicator())
            : user.isNotEmpty
            ? MainScreen()
            : const WelcomePage(),
      ),
    );
  }
}