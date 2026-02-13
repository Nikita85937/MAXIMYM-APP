import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/channel.dart';

class ApiService {
  static String? _token;
  
  // Получить сохраненный токен
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    return _token;
  }
  
  // Сохранить токен
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }
  
  // Удалить токен
  static Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
  
  // Заголовки с авторизацией
  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // РЕГИСТРАЦИЯ
  static Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'username': username,
          'password': password,
          'phone': phone,
        }),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка регистрации');
      }
    } catch (e) {
      throw Exception('Ошибка подключения к серверу: $e');
    }
  }
  
  // ВХОД
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['token']);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка входа');
      }
    } catch (e) {
      throw Exception('Ошибка подключения к серверу: $e');
    }
  }
  
  // ПОЛУЧИТЬ ВСЕХ ПОЛЬЗОВАТЕЛЕЙ
  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка получения пользователей');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПОИСК ПОЛЬЗОВАТЕЛЕЙ
  static Future<List<User>> searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/search?q=$query'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка поиска');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПОЛУЧИТЬ ПРОФИЛЬ
  static Future<User> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Ошибка получения профиля');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ОБНОВИТЬ ПРОФИЛЬ
  static Future<User> updateProfile({
    required String userId,
    String? name,
    String? username,
    String? phone,
    String? bio,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: await _getHeaders(),
        body: json.encode({
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (phone != null) 'phone': phone,
          if (bio != null) 'bio': bio,
        }),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка обновления');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // СОЗДАТЬ КАНАЛ
  static Future<Channel> createChannel({
    required String name,
    required String username,
    String? description,
    bool isPublic = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/channels'),
        headers: await _getHeaders(),
        body: json.encode({
          'name': name,
          'username': username,
          'description': description,
          'isPublic': isPublic,
        }),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Channel.fromJson(data);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Ошибка создания канала');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПОЛУЧИТЬ ВСЕ КАНАЛЫ
  static Future<List<Channel>> getChannels() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/channels'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Channel.fromJson(json)).toList();
      } else {
        throw Exception('Ошибка получения каналов');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПОДПИСАТЬСЯ НА КАНАЛ
  static Future<void> subscribeToChannel(String channelId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/channels/$channelId/subscribe'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка подписки');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ОТПИСАТЬСЯ ОТ КАНАЛА
  static Future<void> unsubscribeFromChannel(String channelId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/channels/$channelId/unsubscribe'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Ошибка отписки');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПОЛУЧИТЬ ИСТОРИЮ СООБЩЕНИЙ
  static Future<List<dynamic>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/messages/$chatId'),
        headers: await _getHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Ошибка получения сообщений');
      }
    } catch (e) {
      throw Exception('Ошибка подключения: $e');
    }
  }
  
  // ПРОВЕРКА ПОДКЛЮЧЕНИЯ
  static Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.socketUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
