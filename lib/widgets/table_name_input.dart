import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TableNameInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;

  const TableNameInput({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final hintColor = textColor.withOpacity(0.6);
    final borderColor = theme.dividerColor;
    final accentColor = theme.colorScheme.primary;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.inter(color: textColor),
            decoration: InputDecoration(
              hintText: 'Nome da Tabela',
              hintStyle: GoogleFonts.inter(color: hintColor),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Adicionar Tabela',
              style: GoogleFonts.inter(
                color: theme.colorScheme.onPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}