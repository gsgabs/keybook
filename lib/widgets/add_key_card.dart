import 'package:flutter/material.dart';

class AddKeyCard extends StatelessWidget {
  final VoidCallback? onTap;
  const AddKeyCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final iconColor = theme.colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 64,
          child: Center(
            child: Icon(Icons.add, color: iconColor, size: 28),
          ),
        ),
      ),
    );
  }
}