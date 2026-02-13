import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'api_service.dart';

class SocketService {
  static IO.Socket? _socket;
  static String? _currentUserId;
  
  // Callbacks для событий
  static Function(dynamic)? onNewMessage;
  static Function(String)? onUserOnline;
  static Function(String)? onUserOffline;
  static Function(String, String)? onUserTyping;
  static Function(String, String)? onUserStopTyping;
  static Function(String, dynamic)? onIncomingCall;
  static Function(dynamic)? onCallAnswered;
  static Function()? onCallEnded;
  static Function(bool)? onConnectionChanged;
  
  // Подключение к WebSocket
  static Future<void> connect(String userId) async {
    if (_socket != null && _socket!.connected) {
      print('⚠️ Socket уже подключен');
      return;
    }
    
    _currentUserId = userId;
    
    try {
      _socket = IO.io(
        ApiConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(ApiConfig.transports)
            .enableAutoConnect()
            .setExtraHeaders({'Authorization': 'Bearer ${await ApiService.getToken()}'})
            .build(),
      );
      
      _socket!.onConnect((_) {
        print('✅ Socket подключен');
        _authenticate(userId);
        onConnectionChanged?.call(true);
      });
      
      _socket!.onDisconnect((_) {
        print('❌ Socket отключен');
        onConnectionChanged?.call(false);
      });
      
      _socket!.on('authenticated', (data) {
        print('✅ Socket аутентифицирован');
      });
      
      _socket!.on('auth_error', (data) {
        print('❌ Ошибка аутентификации: $data');
      });
      
      // Новое сообщение
      _socket!.on('new_message', (data) {
        print('📨 Новое сообщение: $data');
        onNewMessage?.call(data);
      });
      
      // Сообщение отправлено
      _socket!.on('message_sent', (data) {
        print('✅ Сообщение отправлено');
      });
      
      // Ошибка отправки
      _socket!.on('message_error', (data) {
        print('❌ Ошибка отправки: $data');
      });
      
      // Пользователь онлайн
      _socket!.on('user_online', (data) {
        print('🟢 Пользователь онлайн: ${data['userId']}');
        onUserOnline?.call(data['userId']);
      });
      
      // Пользователь офлайн
      _socket!.on('user_offline', (data) {
        print('⚫ Пользователь офлайн: ${data['userId']}');
        onUserOffline?.call(data['userId']);
      });
      
      // Печатает
      _socket!.on('user_typing', (data) {
        onUserTyping?.call(data['chatId'], data['userId']);
      });
      
      // Перестал печатать
      _socket!.on('user_stop_typing', (data) {
        onUserStopTyping?.call(data['chatId'], data['userId']);
      });
      
      // Входящий звонок
      _socket!.on('incoming_call', (data) {
        print('📞 Входящий звонок от: ${data['callerId']}');
        onIncomingCall?.call(data['callerId'], data['offer']);
      });
      
      // Звонок принят
      _socket!.on('call_answered', (data) {
        print('✅ Звонок принят');
        onCallAnswered?.call(data['answer']);
      });
      
      // Звонок завершен
      _socket!.on('call_ended', (_) {
        print('📴 Звонок завершен');
        onCallEnded?.call();
      });
      
      _socket!.connect();
      
    } catch (e) {
      print('❌ Ошибка подключения Socket: $e');
      onConnectionChanged?.call(false);
    }
  }
  
  // Аутентификация
  static void _authenticate(String userId) async {
    final token = await ApiService.getToken();
    
    if (token != null && _socket != null) {
      _socket!.emit('authenticate', {
        'token': token,
        'userId': userId,
      });
    }
  }
  
  // Отправить сообщение
  static void sendMessage({
    required String chatId,
    required String senderId,
    required String recipientId,
    required String type,
    required String content,
  }) {
    if (_socket == null || !_socket!.connected) {
      print('❌ Socket не подключен');
      return;
    }
    
    _socket!.emit('send_message', {
      'chatId': chatId,
      'senderId': senderId,
      'recipientId': recipientId,
      'type': type,
      'content': content,
    });
  }
  
  // Отметить прочитанным
  static void markAsRead(String messageId, String userId) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('mark_read', {
      'messageId': messageId,
      'userId': userId,
    });
  }
  
  // Печатает
  static void typing(String chatId, String userId, String recipientId) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('typing', {
      'chatId': chatId,
      'userId': userId,
      'recipientId': recipientId,
    });
  }
  
  // Перестал печатать
  static void stopTyping(String chatId, String userId, String recipientId) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('stop_typing', {
      'chatId': chatId,
      'userId': userId,
      'recipientId': recipientId,
    });
  }
  
  // Позвонить
  static void callUser(String recipientId, String callerId, dynamic offer) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('call_user', {
      'recipientId': recipientId,
      'callerId': callerId,
      'offer': offer,
    });
  }
  
  // Ответить на звонок
  static void answerCall(String callerId, dynamic answer) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('answer_call', {
      'callerId': callerId,
      'answer': answer,
    });
  }
  
  // Завершить звонок
  static void endCall(String recipientId) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit('end_call', {
      'recipientId': recipientId,
    });
  }
  
  // Отключиться
  static void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _currentUserId = null;
      print('👋 Socket отключен');
    }
  }
  
  // Проверка подключения
  static bool get isConnected => _socket != null && _socket!.connected;
  
  // Получить текущий userId
  static String? get currentUserId => _currentUserId;
}
