import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  // static const String _baseUrl =
  //     'http://10.0.2.2:8080'; // Para emulador Android
  static String? _token;
  static int? _userId;

  // Método para inicializar o token ao iniciar o app
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Registrar novo usuário
  static Future<void> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'email': email, 'password': password}),
      );

      // Debug logs: status and body to help diagnose backend responses
      debugPrint('Register response status: ${response.statusCode}');
      debugPrint('Register response body: "${response.body}"');

      if (response.statusCode != 201) {
        // If body is empty or not JSON, avoid jsonDecode to prevent FormatException
        final body = response.body
            .toString()
            .trim();
        if (body.isNotEmpty) {
          try {
            final error = jsonDecode(body);
            throw Exception(error['message'] ?? 'Falha no registro');
          } catch (e) {
            // If parsing fails, throw a generic exception including raw body
            throw Exception('Falha no registro: status ${response.statusCode}, body: $body');
          }
        } else {
          throw Exception('Falha no registro: status ${response.statusCode} (body vazio)');
        }
      }
    } catch (e) {
      debugPrint('Erro no registro: $e');
      rethrow;
    }
  }

  // Login
  static Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${getBaseUrl()}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Resposta do login: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userId = data['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _userId.toString());

        print('Login realizado - Token: $_token, UserId: $_userId'); // Debug
        return _token!;
      } else {
        throw Exception('Falha no login: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro no login: $e');
      rethrow;
    }
  }

  // Getter para userId
  static Future<int?> getUserId() async {
    if (_userId != null) return _userId;

    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('user_id');

    if (userIdString != null && userIdString.isNotEmpty) {
      _userId = int.tryParse(userIdString);
      return _userId;
    }
    return null;
  }

  // Logout
  static Future<void> logout() async {
    try {
      // Tenta chamar o endpoint de logout (opcional)
      await http.post(
        Uri.parse('${getBaseUrl()}/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
    } catch (e) {
      debugPrint('Erro ao chamar logout no backend: $e');
    } finally {
      // Limpeza local garantida
      _token = null;
      _userId = null;
      _cachedUserDetails = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
    }
  }

  // Verifica se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    if (_token != null) return true;

    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Obtém os headers com o token para requisições autenticadas
  static Future<Map<String, String>> get headers async {
    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
    }

    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  //READ USER
  static Future<Map<String, dynamic>> getUserDetails({
    bool forceRefresh = false,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) throw Exception('Usuário não autenticado');

      // Se não for forçar refresh e já tiver dados em cache
      if (!forceRefresh && _cachedUserDetails != null) {
        return _cachedUserDetails!;
      }

      final response = await http.get(
        Uri.parse('${getBaseUrl()}/users/$userId'),
        headers: await headers,
      );

      if (response.statusCode == 200) {
        _cachedUserDetails = jsonDecode(response.body);
        return _cachedUserDetails!;
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      debugPrint('Error getting user details: $e');
      rethrow;
    }
  }

  static Map<String, dynamic>? _cachedUserDetails;

  static Future<void> clearUserCache() async {
    _cachedUserDetails = null;
  }

  //UPDATE USER
  static Future<void> updateUser({
    required String nome,
    required String email,
    String? password,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await http.put(
        Uri.parse('${getBaseUrl()}/users/$userId'),
        headers: await headers,
        body: jsonEncode({
          'nome': nome,
          'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user: ${response.statusCode}');
      }

      // Limpa o cache após atualização
      await clearUserCache();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  //DELETE USER
  static Future<void> deleteAccount() async {
    try {
      final userId = await getUserId();
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await http.delete(
        Uri.parse('${getBaseUrl()}/users/$userId'),
        headers: await headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Falha ao deletar conta: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao deletar conta: $e');
      rethrow;
    }
  }
}
