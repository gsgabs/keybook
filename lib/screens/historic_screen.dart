import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../service/history_service.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

// MUDANÇA AQUI: De _HistoryScreenState para _HistoricScreenState
class _HistoricScreenState extends State<HistoricScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = HistoryService().getHistory();
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _getIconForType(String type, ColorScheme colors) {
    switch (type) {
      case 'CRIACAO':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.add_circle_outline, color: Colors.green),
        );
      case 'REMOCAO':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_outline, color: Colors.red),
        );
      case 'EDICAO':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.edit_note, color: Colors.orange),
        );
      case 'EXPORTACAO_PDF':
      default:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.picture_as_pdf, color: colors.primary),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = colorScheme.onSurface;
    final mutedColor = textColor.withOpacity(0.6);
    final cardColor = theme.cardColor;

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Histórico',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 16),

              // Container Principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Últimos Eventos',
                            style: GoogleFonts.inter(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: colorScheme.primary,
                            ),
                            onPressed: _refreshHistory,
                            tooltip: "Atualizar",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Lista Dinâmica
                      Expanded(
                        child: FutureBuilder<List<dynamic>>(
                          future: _historyFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar histórico.',
                                  style: GoogleFonts.inter(
                                    color: colorScheme.error,
                                  ),
                                ),
                              );
                            }

                            final lista = snapshot.data ?? [];

                            if (lista.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum evento registrado ainda.',
                                  style: GoogleFonts.inter(
                                    color: mutedColor,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: lista.length,
                              separatorBuilder:
                                  (ctx, i) => Divider(
                                    color: mutedColor.withOpacity(0.2),
                                  ),
                              itemBuilder: (context, index) {
                                final item = lista[index];
                                final tipo =
                                    item['tipoEvento'] ??
                                    'OUTRO'; // Campo novo vindo do DTO
                                final descricao = item['descricao'] ?? '';

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  // Usa a função para o ícone
                                  leading: _getIconForType(tipo, colorScheme),
                                  title: Text(
                                    item['nomeItem'] ?? 'Item Desconhecido',
                                    style: GoogleFonts.inter(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        descricao,
                                        // Mostra "Chave criada" ou "PDF Gerado: ..."
                                        style: GoogleFonts.inter(
                                          color: mutedColor,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _formatDate(item['dataHora']),
                                        // Campo renomeado no DTO
                                        style: GoogleFonts.inter(
                                          color: mutedColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
