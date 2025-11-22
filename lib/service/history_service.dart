import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api.dart'; // Importa o getBaseUrl centralizado
import 'auth_service.dart';

class HistoryService {
  // 1. Buscar o histórico (GET)
  Future<List<dynamic>> getHistory() async {
    try {
      final url = Uri.parse('${getBaseUrl()}/historico');
      final headers = await AuthService.headers;

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      return []; // Retorna lista vazia em caso de erro para não quebrar a tela
    }
  }

  // 2. Registrar uma exportação (POST)
  // O Backend espera: /historico/{itemId}?nomeArquivo=...
  Future<void> registerExport(int itemId, String nomeArquivo) async {
    try {
      // Atenção aqui: O parâmetro vai na URL (Query Param), não no body
      final url = Uri.parse(
        '${getBaseUrl()}/historico/$itemId?nomeArquivo=${Uri.encodeComponent(nomeArquivo)}',
      );

      final headers = await AuthService.headers;

      // O post é vazio pois os dados estão na URL, mas precisa autenticar
      final response = await http.post(url, headers: headers);

      if (response.statusCode != 200) {
        debugPrint('Falha ao registrar histórico no backend: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao conectar com endpoint de histórico: $e');
      // Não damos rethrow aqui para não impedir o usuário de ver o PDF
      // só porque o log falhou.
    }
  }
}
