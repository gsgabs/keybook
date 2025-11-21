import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/key_list_screen.dart'; // Home
import 'screens/home_screen.dart'; // (Mapa e notificações, se quiser usar em outro lugar)
import 'screens/profile_screen.dart'; // Perfil
import 'screens/historic_screen.dart'; // Histórico
import 'widgets/custom_bottom_nav_bar.dart';

void main() {
  runApp(const KeybookApp());
}

class KeybookApp extends StatelessWidget {
  const KeybookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: AppRoutes.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1D1D1D),
        textTheme: GoogleFonts.interTextTheme(),
      ),
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
