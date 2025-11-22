import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoricScreen extends StatelessWidget {
  const HistoricScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
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
              // Histórico de exportações (PDFs)
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(18),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de Exportações',
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Aqui vai a lista de PDFs exportados do backend
                      Expanded(
                        child: Center(
                          child: Text(
                            'Nenhum PDF exportado ainda.',
                            style: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Exemplo: ListView.builder para mostrar arquivos futuramente
                      // TODO: Substituir pelo conteúdo real do backend
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Modificações em Chaves
              GestureDetector(
                onTap: () {
                  // TODO: Implementar navegação para histórico de modificações em chaves
                  // Aqui você vai mostrar as últimas chaves modificadas do backend
                },
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(18),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modificações em Chaves',
                        style: GoogleFonts.inter(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Aqui vai a lista de modificações de chaves do backend
                      Expanded(
                        child: Center(
                          child: Text(
                            'Nenhuma modificação recente.',
                            style: GoogleFonts.inter(
                              color: mutedColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Exemplo: ListView.builder para mostrar modificações futuramente
                      // TODO: Substituir pelo conteúdo real do backend
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
