import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<Color>? selectedColors;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.selectedColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomNavTheme = theme.bottomNavigationBarTheme;
    final resolvedSelectedColor =
        (selectedColors != null && selectedColors!.length > currentIndex)
            ? selectedColors![currentIndex]
            : bottomNavTheme.selectedItemColor ?? theme.colorScheme.primary;
    final resolvedUnselectedColor =
        bottomNavTheme.unselectedItemColor ?? theme.colorScheme.onSurface.withOpacity(0.6);
    final resolvedBackgroundColor =
        bottomNavTheme.backgroundColor ?? theme.colorScheme.surface;

    return BottomNavigationBar(
      backgroundColor: resolvedBackgroundColor,
      selectedItemColor: resolvedSelectedColor,
      unselectedItemColor: resolvedUnselectedColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 26),
          label: 'Home',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.list, size: 26),
        //   label: 'Tabelas',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inbox_rounded, size: 26),
          label: 'Criar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 26),
          label: 'Buscar',
        ),
      ],
    );
  }
}
