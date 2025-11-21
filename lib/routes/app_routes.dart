import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../main.dart'; // Importa MainNavigation

class AppRoutes {
  static final routes = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const MainNavigation(),
  };
}
