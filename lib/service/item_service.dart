import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'auth_service.dart'; // Adicione esta importação

class ItemService {
  final String baseUrl = 'http://127.0.0.1:8080'; // Remova a barra no final
  // final String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, dynamic>> createItem({
    required String nome,
    required int tabelaId,
    String? transponder,
    String? tipoServico,
    String? anoVeiculo,
    double? valorCobrado,
    String? marcaVeiculo,
    String? modeloVeiculo,
    String? tipoChave,
    String? maquina,
    String? fornecedor,
    String? dataConstrucao,
    String? corteMecanico,
    String? sistemaImobilizador,
    String? observacoes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/tables/$tabelaId/items'); // URL correta

      // Obtenha os headers de autenticação
      final headers = await AuthService.headers;
      headers['Content-Type'] = 'application/json';

      final response = await http.post(
        url,
        headers: headers, // Use os headers com autenticação
        body: jsonEncode({
          'nome': nome,
          'transponder': transponder,
          'tipoServico': tipoServico,
          'anoVeiculo': anoVeiculo,
          'valorCobrado': valorCobrado,
          'marcaVeiculo': marcaVeiculo,
          'modeloVeiculo': modeloVeiculo,
          'tipoChave': tipoChave,
          'maquina': maquina,
          'fornecedor': fornecedor,
          'dataConstrucao': dataConstrucao,
          'corteMecanico': corteMecanico,
          'sistemaImobilizador': sistemaImobilizador,
          'observacoes': observacoes,
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating item: $e');
      }
      rethrow;
    }
  }

  // Deleta um item
  Future<void> deleteItem(int itemId) async {
    try {
      final url = Uri.parse('$baseUrl/items/$itemId');
      final headers = await AuthService.headers;

      final response = await http.delete(url, headers: headers);

      if (response.statusCode != 204) {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting item: $e');
      }
      rethrow;
    }
  }

  // Busca os detalhes completos de um item
  Future<Map<String, dynamic>> getItemDetails(int itemId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/items/$itemId/details'),
      headers: await AuthService.headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load item details');
    }
  }

  // Atualiza um item existente
  Future<void> updateItem({
    required int itemId,
    required String nome,
    String? transponder,
    String? tipoServico,
    String? anoVeiculo,
    double? valorCobrado,
    String? marcaVeiculo,
    String? modeloVeiculo,
    String? tipoChave,
    String? fornecedor,
    String? dataConstrucao,
    String? observacoes,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/$itemId/details'),
      headers: await AuthService.headers,
      body: jsonEncode({
        'nome': nome,
        'transponder': transponder,
        'tipoServico': tipoServico,
        'anoVeiculo': anoVeiculo,
        'valorCobrado': valorCobrado,
        'marcaVeiculo': marcaVeiculo,
        'modeloVeiculo': modeloVeiculo,
        'tipoChave': tipoChave,
        'fornecedor': fornecedor,
        'dataConstrucao': dataConstrucao,
        'observacoes': observacoes,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update item: ${response.statusCode}');
    }
  }

  Future<List<String>> getFieldSuggestions(
    String fieldName,
    String query,
  ) async {
    try {
      // Log 1: Antes da requisição
      debugPrint(
        '🔍 Buscando sugestões para campo "$fieldName" com query: "$query"',
      );
      debugPrint(
        '📡 URL: $baseUrl/items/suggestions?field=$fieldName&query=$query',
      );

      final headers = await AuthService.headers;
      debugPrint('🔑 Headers: $headers');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/items/suggestions?field=$fieldName&query=${Uri.encodeQueryComponent(query)}',
        ),
        headers: headers,
      );

      // Log 2: Resposta bruta
      debugPrint('📥 Resposta recebida - Status: ${response.statusCode}');
      debugPrint('📦 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Log 3: Dados convertidos
        debugPrint('✅ Dados decodificados: $data');

        final suggestions = data.cast<String>();
        debugPrint('🔄 ${suggestions.length} sugestões encontradas');

        return suggestions;
      } else {
        debugPrint('❌ Erro HTTP: ${response.statusCode}');
        throw Exception(
          'Failed to load suggestions. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('‼️ Erro ao buscar sugestões: $e');
      if (kDebugMode) {
        print('Error getting suggestions: $e');
      }
      return [];
    }
  }
}
