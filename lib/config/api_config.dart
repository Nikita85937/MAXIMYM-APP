class ApiConfig {
  // ВАЖНО: Замените на ваш URL после деплоя на Railway!
  
  // Для локального тестирования:
  // static const String baseUrl = 'http://localhost:3000/api';
  // static const String socketUrl = 'http://localhost:3000';
  
  // Для Android эмулятора (localhost на ПК):
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  // static const String socketUrl = 'http://10.0.2.2:3000';
  
  // Для реального устройства в локальной сети:
  // static const String baseUrl = 'http://192.168.1.X:3000/api';
  // static const String socketUrl = 'http://192.168.1.X:3000';
  
  // Для продакшн (Railway.app):
  static const String baseUrl = 'https://your-app.railway.app/api';
  static const String socketUrl = 'https://your-app.railway.app';
  
  // Таймауты
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // WebSocket опции
  static const bool autoConnect = true;
  static const List<String> transports = ['websocket'];
}
