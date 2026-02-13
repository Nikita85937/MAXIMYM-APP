import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/welcome_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/chats_screen.dart';
import 'services/auth_service.dart';
import 'services/official_service.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MaximumApp());
}

class MaximumApp extends StatelessWidget {
  const MaximumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Максимум',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = await AuthService.getCurrentUser();
    
    if (!mounted) return;
    
    if (user != null) {
      // Инициализация официального бота и канала
      await OfficialService.initializeOfficial();
      
      // Пользователь авторизован
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ChatsScreen()),
      );
    } else {
      // Новый пользователь - регистрация
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
