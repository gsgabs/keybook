import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:keybook/service/theme_service.dart';
import 'theme/app_themes.dart';

import 'screens/key_list_screen.dart'; // Home
import 'screens/profile_screen.dart'; // Perfil
import 'screens/historic_screen.dart'; // Histórico
import 'widgets/custom_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController.instance;
  await themeController.loadThemeMode();
  runApp(KeybookApp(themeController: themeController));
}

class KeybookApp extends StatelessWidget {
  final ThemeController themeController;

  const KeybookApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/login',
          routes: AppRoutes.routes,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: themeController.themeMode,
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const KeyListScreen(), // 0 - Home (Lista de Chaves)
    // const HomeScreen(),      // 1 - Mapa/Notificações
    const HistoricScreen(), // 2 - Histórico
    const ProfileScreen(), // 3 - Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
