import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final result = jsonDecode(response.body);
      
      if (result['success'] == true && result['token'] != null) {
        await saveToken(result['token']);
        await saveEmail(email);
      }
      
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> saveEmail(String email) async {
    await _storage.write(key: 'user_email', value: email);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> getEmail() async {
    return await _storage.read(key: 'user_email');
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_email');
  }

  Future<Map<String, dynamic>> getNotes() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'No token found'};

      final response = await http.get(
        Uri.parse('$baseUrl/notes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> addNote(String description, String userType) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'description': description,
          'user_type': userType,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateNote(int id, String description, String userType) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'description': description,
          'user_type': userType,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteNote(int id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/notes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
