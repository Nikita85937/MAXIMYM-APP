import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'socket_service.dart';

class AuthService {
  static const String _currentUserKey = 'current_user';
  static User? _currentUser;
  
  // Получить текущего пользователя
  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      
      // Подключить WebSocket
      await SocketService.connect(_currentUser!.id);
      
      return _currentUser;
    }
    
    return null;
  }
  
  // Регистрация через API
  static Future<User> register({
    required String name,
    required String username,
    String? phone,
    required String password,
  }) async {
    try {
      // Вызов API
      final response = await ApiService.register(
        name: name,
        username: username,
        password: password,
        phone: phone,
      );
      
      final user = User.fromJson(response['user']);
      
      // Сохранение локально
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      
      _currentUser = user;
      
      // Подключить WebSocket
      await SocketService.connect(user.id);
      
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Вход через API
  static Future<User> login({
    required String username,
    required String password,
  }) async {
    try {
      // Вызов API
      final response = await ApiService.login(
        username: username,
        password: password,
      );
      
      final user = User.fromJson(response['user']);
      
      // Сохранение локально
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(user.toJson()));
      
      _currentUser = user;
      
      // Подключить WebSocket
      await SocketService.connect(user.id);
      
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Выход
  static Future<void> logout() async {
    // Отключить WebSocket
    SocketService.disconnect();
    
    // Удалить токен
    await ApiService.removeToken();
    
    // Удалить локальные данные
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
    
    _currentUser = null;
  }
  
  // Обновление профиля через API
  static Future<User> updateProfile({
    String? name,
    String? username,
    String? phone,
    String? bio,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }
    
    try {
      // Вызов API
      final updatedUser = await ApiService.updateProfile(
        userId: currentUser.id,
        name: name,
        username: username,
        phone: phone,
        bio: bio,
      );
      
      // Сохранение локально
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(updatedUser.toJson()));
      
      _currentUser = updatedUser;
      return updatedUser;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Получить всех пользователей через API
  static Future<List<User>> getAllUsers() async {
    try {
      return await ApiService.getUsers();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  // Поиск пользователей через API
  static Future<List<User>> searchUsers(String query) async {
    try {
      return await ApiService.searchUsers(query);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
