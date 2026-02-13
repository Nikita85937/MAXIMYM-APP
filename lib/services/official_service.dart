import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/channel.dart';

class OfficialService {
  static const String _officialInitKey = 'official_initialized';
  
  // Официальный бот
  static User get officialBot => User(
    id: 'bot_maximum_official',
    name: 'Максимум',
    username: 'maximum',
    bio: 'Официальный бот мессенджера Максимум 🚀',
    registeredAt: DateTime(2024, 1, 1),
    isOnline: true,
  );
  
  // Официальный канал
  static Channel get officialChannel => Channel(
    id: 'channel_maximum_official',
    name: 'Максимум',
    username: 'maximum_official',
    description: 'Официальный канал мессенджера Максимум 🚀\n\nНовости, обновления и анонсы',
    ownerId: 'bot_maximum_official',
    createdAt: DateTime(2024, 1, 1),
    subscribersCount: 0,
    isPublic: true,
    isVerified: true,
  );
  
  // Инициализация официальных сущностей
  static Future<void> initializeOfficial() async {
    final prefs = await SharedPreferences.getInstance();
    final initialized = prefs.getBool(_officialInitKey) ?? false;
    
    if (initialized) return;
    
    // Добавляем бота в список пользователей
    await _addOfficialBot();
    
    // Создаем официальный канал
    await _createOfficialChannel();
    
    // Автоподписка на официальный канал
    await _autoSubscribeToOfficialChannel();
    
    // Отмечаем что инициализация выполнена
    await prefs.setBool(_officialInitKey, true);
  }
  
  static Future<void> _addOfficialBot() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('all_users');
    
    List<User> users = [];
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      users = usersList.map((u) => User.fromJson(u)).toList();
    }
    
    // Проверяем есть ли уже бот
    final botExists = users.any((u) => u.id == officialBot.id);
    if (!botExists) {
      users.add(officialBot);
      final updatedJson = json.encode(users.map((u) => u.toJson()).toList());
      await prefs.setString('all_users', updatedJson);
    }
  }
  
  static Future<void> _createOfficialChannel() async {
    final prefs = await SharedPreferences.getInstance();
    final channelsJson = prefs.getString('channels');
    
    List<Channel> channels = [];
    if (channelsJson != null) {
      final List<dynamic> channelsList = json.decode(channelsJson);
      channels = channelsList.map((c) => Channel.fromJson(c)).toList();
    }
    
    // Проверяем есть ли уже канал
    final channelExists = channels.any((c) => c.id == officialChannel.id);
    if (!channelExists) {
      channels.add(officialChannel);
      final updatedJson = json.encode(channels.map((c) => c.toJson()).toList());
      await prefs.setString('channels', updatedJson);
    }
  }
  
  static Future<void> _autoSubscribeToOfficialChannel() async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedJson = prefs.getString('subscribed_channels');
    
    List<String> subscribed = [];
    if (subscribedJson != null) {
      subscribed = List<String>.from(json.decode(subscribedJson));
    }
    
    // Автоподписка на официальный канал
    if (!subscribed.contains(officialChannel.id)) {
      subscribed.add(officialChannel.id);
      await prefs.setString('subscribed_channels', json.encode(subscribed));
      
      // Увеличиваем счетчик подписчиков
      await _incrementOfficialChannelSubscribers();
    }
  }
  
  static Future<void> _incrementOfficialChannelSubscribers() async {
    final prefs = await SharedPreferences.getInstance();
    final channelsJson = prefs.getString('channels');
    
    if (channelsJson != null) {
      final List<dynamic> channelsList = json.decode(channelsJson);
      List<Channel> channels = channelsList.map((c) => Channel.fromJson(c)).toList();
      
      final index = channels.indexWhere((c) => c.id == officialChannel.id);
      if (index != -1) {
        channels[index] = channels[index].copyWith(
          subscribersCount: channels[index].subscribersCount + 1,
        );
        
        final updatedJson = json.encode(channels.map((c) => c.toJson()).toList());
        await prefs.setString('channels', updatedJson);
      }
    }
  }
  
  // Проверка является ли пользователь официальным ботом
  static bool isOfficialBot(String userId) {
    return userId == officialBot.id;
  }
  
  // Проверка является ли канал официальным
  static bool isOfficialChannel(String channelId) {
    return channelId == officialChannel.id;
  }
  
  // Получить приветственное сообщение от бота
  static String getWelcomeMessage(String userName) {
    return '''
Привет, $userName! 👋

Добро пожаловать в Максимум! 🚀

Я официальный бот. Вот что ты можешь делать:

📢 Подписывайся на каналы
💬 Общайся с друзьями
🎤 Отправляй голосовые сообщения
📞 Совершай звонки

Не забудь подписаться на наш официальный канал @maximum_official для получения новостей!

Удачи! ✨
''';
  }
}
