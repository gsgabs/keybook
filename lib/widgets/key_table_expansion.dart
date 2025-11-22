import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/table_data.dart';
import 'add_key_card.dart';
import '../widgets/key_item_card.dart' as item_card;
import '../screens/key_detail_screen.dart';

class KeyTableExpansion extends StatelessWidget {
  final TableData table;
  final Function(String, String) onEditTable; // Agora recebe ID e novo nome
  final Function(String) onDeleteTable;
  final Function(TableData) onAddKey;
  final Function(KeyItemData) onKeyTap;

  const KeyTableExpansion({
    super.key,
    required this.table,
    required this.onEditTable,
    required this.onDeleteTable,
    required this.onAddKey,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.6);
    final popupColor = theme.colorScheme.surface;
    final errorColor = theme.colorScheme.error;
    final dialogBackground = theme.colorScheme.surface;
    final isLabelDark =
      ThemeData.estimateBrightnessForColor(table.color) == Brightness.dark;
    final labelTextColor = isLabelDark
      ? theme.colorScheme.onPrimary
      : theme.colorScheme.onSurface;

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: table.color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          table.name,
          style: GoogleFonts.inter(
            color: labelTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        '${table.keys.length} ${table.keys.length == 1 ? 'item' : 'items'}',
        style: GoogleFonts.inter(color: mutedColor, fontSize: 13),
        textAlign: TextAlign.end,
      ),
      trailing: PopupMenuButton<int>(
        color: popupColor,
        icon: Icon(Icons.more_vert, color: mutedColor),
        onSelected: (value) {
          if (value == 0) {
            // Editar tabela
            final controller = TextEditingController(text: table.name);
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: dialogBackground,
                    title: Text(
                      'Editar Tabela',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                    content: TextField(
                      controller: controller,
                      style: GoogleFonts.inter(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Novo nome',
                        hintStyle: GoogleFonts.inter(color: mutedColor),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(color: mutedColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onEditTable(table.id.toString(), controller.text.trim());
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'OK',
                          style: GoogleFonts.inter(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
            );
          } else if (value == 1) {
            // Deletar tabela
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: dialogBackground,
                    title: Text(
                      'Deletar Tabela',
                      style: GoogleFonts.inter(color: errorColor),
                    ),
                    content: Text(
                      'Tem certeza que deseja deletar esta tabela?',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(color: mutedColor),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                        ),
                        onPressed: () {
                          onDeleteTable(table.id.toString());// Chamando a função de deletar
                          print("Id da tabela a ser deletada" + "Nome: " + table.name);
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Deletar Tabela',
                          style: GoogleFonts.inter(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                    ],
                  ),
            );
          }
        },
        itemBuilder:
            (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.edit, color: mutedColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Editar Tabela',
                      style: GoogleFonts.inter(color: textColor),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.delete, color: errorColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Deletar Tabela',
                      style: GoogleFonts.inter(color: errorColor),
                    ),
                  ],
                ),
              ),
            ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: AddKeyCard(onTap: () => onAddKey(table)),
                  ),
                  ...table.keys.map(
                    (k) => SizedBox(
                      width: cardWidth,
                      child: GestureDetector(
                        onTap: () => onKeyTap(k),
                        child: item_card.KeyItemCard(
                          keyName: k.name,
                          valorCobrado: k.valorCobrado,
                          modeloVeiculo: k.modeloVeiculo,
                          cardColor: theme.cardColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
