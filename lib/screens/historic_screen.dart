import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../service/history_service.dart';

class HistoricScreen extends StatefulWidget {
  const HistoricScreen({super.key});

  @override
  State<HistoricScreen> createState() => _HistoricScreenState();
}

class _HistoricScreenState extends State<HistoricScreen> {
  // Variáveis de Estado para Paginação
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _items = [];
  bool _isLoading = false;
  bool _hasMore = true; // Ainda tem itens para carregar?
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _isFirstLoad = true; // Para mostrar o loading central na primeira vez

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Carrega a primeira página

    // Ouve o scroll. Se chegar no final, carrega mais.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent -
                  200 && // -200px antes do fim
          !_isLoading &&
          _hasMore) {
        _fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Chama o service passando a página atual
      final newItems = await HistoryService().getHistory(
        page: _currentPage,
        size: _pageSize,
      );

      setState(() {
        _currentPage++;
        _items.addAll(newItems);

        // Se vieram menos itens que o tamanho da página, acabou o histórico
        if (newItems.length < _pageSize) {
          _hasMore = false;
        }

        _isLoading = false;
        _isFirstLoad = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mais itens: $e')),
        );
      }
    }
  }

  // Reseta tudo e carrega do zero (Pull to Refresh)
  Future<void> _refreshHistory() async {
    setState(() {
      _items.clear();
      _currentPage = 0;
      _hasMore = true;
      _isFirstLoad = true;
    });
    await _fetchHistory();
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
          child: const Icon(Icons.add_circle_outline, color: Colors.green),
        );
      case 'REMOCAO':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red),
        );
      case 'EDICAO':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_note, color: Colors.orange),
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

                      // Lógica de Exibição da Lista
                      Expanded(
                        child:
                            _isFirstLoad
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : _items.isEmpty
                                ? Center(
                                  child: Text(
                                    'Nenhum evento registrado ainda.',
                                    style: GoogleFonts.inter(
                                      color: mutedColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  controller: _scrollController,
                                  // Importante!
                                  itemCount: _items.length + (_hasMore ? 1 : 0),
                                  // +1 pro loading do final
                                  separatorBuilder:
                                      (ctx, i) => Divider(
                                        color: mutedColor.withOpacity(0.2),
                                      ),
                                  itemBuilder: (context, index) {
                                    // Se for o último item e ainda tiver mais, mostra loading
                                    if (index == _items.length) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final item = _items[index];
                                    final tipo = item['tipoEvento'] ?? 'OUTRO';
                                    final descricao = item['descricao'] ?? '';

                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: _getIconForType(
                                        tipo,
                                        colorScheme,
                                      ),
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
                                            style: GoogleFonts.inter(
                                              color: mutedColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
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
