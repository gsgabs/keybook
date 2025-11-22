import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final int filterOption;
  final ValueChanged<String> onChanged;
  final ValueChanged<int> onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.filterOption,
    required this.onChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.6);
    final background = theme.colorScheme.surfaceVariant;
    final menuColor = theme.colorScheme.surface;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.search, color: mutedColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: StatefulBuilder(
              builder: (context, setState) {
                return TextField(
                  controller: controller,
                  style: GoogleFonts.inter(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar items',
                    hintStyle: GoogleFonts.inter(color: mutedColor),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    alignLabelWithHint: true,
                    suffixIcon: controller.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              controller.clear();
                              onChanged('');
                              setState(() {});
                            },
                            child: Icon(Icons.clear, color: mutedColor, size: 18),
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    onChanged(value);
                    setState(() {});
                  },
                );
              },
            ),
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.filter_list, color: mutedColor, size: 22),
            color: menuColor,
            onSelected: onFilterChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Ordem Alfabética (A-Z)', style: GoogleFonts.inter(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Ordem Alfabética (Z-A)', style: GoogleFonts.inter(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Mais Recentes', style: GoogleFonts.inter(color: textColor)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: textColor, size: 18),
                    const SizedBox(width: 8),
                    Text('Mais Antigas', style: GoogleFonts.inter(color: textColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}