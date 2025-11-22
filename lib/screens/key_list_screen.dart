import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/table_data.dart';
import '../service/item_service.dart';
import '../widgets/key_table_expansion.dart';
import '../widgets/table_name_input.dart';
import '../widgets/search_filter_bar.dart';
import 'key_detail_screen.dart';
import '../service/table_service.dart';
import '../service/auth_service.dart';

class KeyListScreen extends StatefulWidget {
  const KeyListScreen({super.key});

  @override
  State<KeyListScreen> createState() => _KeyListScreenState();
}

// Classe auxiliar para sugestão de chave
class _KeySuggestion {
  final KeyItemData key;
  final TableData table;
  _KeySuggestion({required this.key, required this.table});
}

class _KeyListScreenState extends State<KeyListScreen> {
  List<TableData> tables = [];
  final TextEditingController tableNameController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  int _filterOption = 0;
  int? userId;
  bool _isLoading = true;

  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      50 + random.nextInt(156),
      50 + random.nextInt(156),
      50 + random.nextInt(156),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserAndTables();
  }

  Future<void> _loadUserAndTables() async {
    try {
      userId = await AuthService.getUserId();
      print('UserId obtido: $userId');

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuário não autenticado')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      await _loadTables();
    } catch (e) {
      print('Erro ao carregar dados: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadTables() async {
    if (userId == null) return;

    try {
      final list = await TableService.getUserTables(userId!.toString());

      final loadedTables = await Future.wait(
        list.map((tableData) async {
          final items = await TableService.getTableItems(
            tableData['id'].toString(),
          );

          final keys =
              items
                  .map<KeyItemData>(
                    (item) => KeyItemData(
                      item['nome'],
                      id: item['id'],
                      valorCobrado: item['valorCobrado']?.toDouble(),
                      modeloVeiculo: item['modeloVeiculo'],
                    ),
                  )
                  .toList();

          return TableData(
            tableData['nome'],
            getRandomColor(),
            id: tableData['id'],
            keys: keys,
            dataCriacao: tableData['dataCriacao'] != null
                ? DateTime.tryParse(tableData['dataCriacao'])
                : null,
          );
        }),
      );

      setState(() => tables = loadedTables);
    } catch (e) {
      print('Erro ao carregar tabelas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar tabelas: ${e.toString()}')),
        );
      }
    }
  }

  //CREATE TABLE
  void addTable() async {
    final name = tableNameController.text.trim();
    if (name.isEmpty || userId == null) return;

    try {
      final newTable = await TableService.createTable(userId!.toString(), name);
      setState(() {
        tables.add(
          TableData(
            newTable['nome'],
            getRandomColor(),
            id: newTable['id'],
          ),
        );
        tableNameController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar tabela: ${e.toString()}')),
        );
      }
    }
  }

  //UPDATE
  Future<void> _editTable(String tableId, String newName) async {
    try {
      print('Tentando renomear tabela $tableId para $newName');
      await TableService.renameTable(tableId, newName);

      setState(() {
        final index = tables.indexWhere((t) => t.id.toString() == tableId);
        if (index != -1) {
          tables[index] = TableData(
            newName,
            tables[index].color,
            keys: tables[index].keys,
            id: tables[index].id,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabela renomeada com sucesso')),
      );
    } catch (e) {
      print('Erro ao editar tabela: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao editar tabela: ${e.toString()}')),
      );
    }
  }

  //DELETE TABLE
  void deleteTable(String tableId) async {
    try {
      await TableService.deleteTable(tableId);

      setState(() {
        tables.removeWhere((table) => table.id.toString() == tableId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabela deletada com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar tabela: ${e.toString()}')),
      );
    }
  }

  //CREATE KEY
  void addKey(TableData table) {
    final _keynamecontroller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) {
            final theme = Theme.of(context);
            final textColor = theme.colorScheme.onSurface;
            final mutedColor = textColor.withOpacity(0.7);
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Nova chave',
                style: GoogleFonts.inter(color: textColor),
              ),
              content: TextField(
                controller: _keynamecontroller,
                style: GoogleFonts.inter(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Nome da chave',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () async {
                  if (_keynamecontroller.text.trim().isNotEmpty) {
                    try {
                      final newItem = await ItemService().createItem(
                        nome: _keynamecontroller.text.trim(),
                        tabelaId: table.id!,
                      );

                      final updatedKeys = [
                        KeyItemData(
                          _keynamecontroller.text.trim(),
                          id: newItem['id'],
                        ),
                        ...table.keys,
                      ];

                      setState(() {
                        tables =
                            tables.map((t) {
                              return t.id == table.id
                                  ? TableData(
                                    t.name,
                                    t.color,
                                    keys: updatedKeys,
                                    id: t.id,
                                  )
                                  : t;
                            }).toList();
                      });

                      Navigator.pop(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Erro ao criar chave: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                  child: Text(
                    'OK',
                    style: GoogleFonts.inter(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ],
            );
          },
    );
  }

  void onKeyTap(KeyItemData keyItem) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => KeyDetailScreen(keyName: keyItem.name, itemId: keyItem.id!),
      ),
    );

    // Sempre atualiza a lista ao voltar da tela de detalhes
    await _loadTables();

    // Se deletou, mostra feedback visual
    if (result == true) {
      final successColor = Theme.of(context).colorScheme.primary;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Chave deletada com sucesso'),
          backgroundColor: successColor,
        ),
      );
    }
  }

  // SUGESTÕES DE CHAVES (AUTOCOMPLETE)
  List<_KeySuggestion> get keySuggestions {
    final search = searchController.text.trim().toLowerCase();
    if (search.isEmpty) return [];
    final suggestions = <_KeySuggestion>[];
    for (final table in tables) {
      for (final key in table.keys) {
        if (key.name.toLowerCase().contains(search)) {
          suggestions.add(_KeySuggestion(key: key, table: table));
        }
      }
    }
    return suggestions;
  }

  List<TableData> get filteredTables {
    String search = searchController.text.trim().toLowerCase();
    List<TableData> filtered =
        tables
            .where(
              (t) =>
                  t.name.toLowerCase().contains(search) ||
                  t.keys.any((k) => k.name.toLowerCase().contains(search)),
            )
            .toList();

    switch (_filterOption) {
      case 0: // Ordem Alfabética (A-Z)
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 1: // Ordem Alfabética (Z-A)
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 2: // Mais Recentes
        filtered.sort((a, b) =>
          (b.dataCriacao ?? DateTime(0)).compareTo(a.dataCriacao ?? DateTime(0)));
        break;
      case 3: // Mais Antigas
        filtered.sort((a, b) =>
          (a.dataCriacao ?? DateTime(0)).compareTo(b.dataCriacao ?? DateTime(0)));
        break;
    }
    return filtered;
  }

  @override
  void dispose() {
    tableNameController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.65);
    final cardColor = theme.cardColor;

    return SafeArea(
      child: Scaffold(
        appBar: null,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lista de Chaves',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              TableNameInput(controller: tableNameController, onAdd: addTable),
              const SizedBox(height: 12),
              SearchFilterBar(
                controller: searchController,
                filterOption: _filterOption,
                onChanged: (_) => setState(() {}),
                onFilterChanged:
                    (value) => setState(() => _filterOption = value),
              ),
              // SUGESTÕES DE CHAVES (AUTOCOMPLETE)
                if (keySuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: keySuggestions.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor),
                      itemBuilder: (context, i) {
                        final suggestion = keySuggestions[i];
                        return ListTile(
                          leading: Icon(Icons.vpn_key, color: mutedColor),
                          title: Text(
                            suggestion.key.name,
                            style: GoogleFonts.inter(color: textColor),
                          ),
                          subtitle: Text(
                            suggestion.table.name,
                            style: GoogleFonts.inter(color: mutedColor, fontSize: 13),
                          ),
                          onTap: () {
                            searchController.text = suggestion.key.name;
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
              const SizedBox(height: 16),
              Expanded(
                child: keySuggestions.isNotEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        itemCount: filteredTables.length,
                        itemBuilder: (context, tableIndex) {
                          final table = filteredTables[tableIndex];
                          return KeyTableExpansion(
                            table: table,
                            onEditTable: (id, newName) => _editTable(id, newName),
                            onDeleteTable: deleteTable,
                            onAddKey: addKey,
                            onKeyTap: onKeyTap,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


