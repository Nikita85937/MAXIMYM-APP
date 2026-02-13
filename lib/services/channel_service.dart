import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/channel.dart';
import 'auth_service.dart';

class ChannelService {
  static const String _channelsKey = 'channels';
  static const String _subscribedChannelsKey = 'subscribed_channels';
  
  // Создать канал
  static Future<Channel> createChannel({
    required String name,
    required String username,
    String? description,
  }) async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Необходима авторизация');
    }
    
    // Проверка юзернейма
    final existingChannels = await getAllChannels();
    final usernameTaken = existingChannels.any(
      (c) => c.username.toLowerCase() == username.toLowerCase(),
    );
    
    if (usernameTaken) {
      throw Exception('Юзернейм @$username уже занят');
    }
    
    final channel = Channel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      username: username,
      description: description,
      ownerId: currentUser.id,
      createdAt: DateTime.now(),
    );
    
    // Сохранение
    existingChannels.add(channel);
    await _saveAllChannels(existingChannels);
    
    // Автоподписка создателя
    await subscribeToChannel(channel.id);
    
    return channel;
  }
  
  // Получить все каналы
  static Future<List<Channel>> getAllChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final channelsJson = prefs.getString(_channelsKey);
    
    if (channelsJson != null) {
      final List<dynamic> channelsList = json.decode(channelsJson);
      return channelsList.map((c) => Channel.fromJson(c)).toList();
    }
    
    return [];
  }
  
  // Сохранить все каналы
  static Future<void> _saveAllChannels(List<Channel> channels) async {
    final prefs = await SharedPreferences.getInstance();
    final channelsJson = json.encode(channels.map((c) => c.toJson()).toList());
    await prefs.setString(_channelsKey, channelsJson);
  }
  
  // Подписаться на канал
  static Future<void> subscribeToChannel(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedJson = prefs.getString(_subscribedChannelsKey);
    
    List<String> subscribed = [];
    if (subscribedJson != null) {
      subscribed = List<String>.from(json.decode(subscribedJson));
    }
    
    if (!subscribed.contains(channelId)) {
      subscribed.add(channelId);
      await prefs.setString(_subscribedChannelsKey, json.encode(subscribed));
      
      // Увеличить счетчик подписчиков
      await _incrementSubscribers(channelId);
    }
  }
  
  // Отписаться от канала
  static Future<void> unsubscribeFromChannel(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedJson = prefs.getString(_subscribedChannelsKey);
    
    if (subscribedJson != null) {
      List<String> subscribed = List<String>.from(json.decode(subscribedJson));
      subscribed.remove(channelId);
      await prefs.setString(_subscribedChannelsKey, json.encode(subscribed));
      
      // Уменьшить счетчик подписчиков
      await _decrementSubscribers(channelId);
    }
  }
  
  // Получить подписанные каналы
  static Future<List<Channel>> getSubscribedChannels() async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedJson = prefs.getString(_subscribedChannelsKey);
    
    if (subscribedJson == null) return [];
    
    final List<String> subscribedIds = List<String>.from(json.decode(subscribedJson));
    final allChannels = await getAllChannels();
    
    return allChannels.where((c) => subscribedIds.contains(c.id)).toList();
  }
  
  // Проверить подписку
  static Future<bool> isSubscribed(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final subscribedJson = prefs.getString(_subscribedChannelsKey);
    
    if (subscribedJson == null) return false;
    
    final List<String> subscribed = List<String>.from(json.decode(subscribedJson));
    return subscribed.contains(channelId);
  }
  
  // Увеличить подписчиков
  static Future<void> _incrementSubscribers(String channelId) async {
    final channels = await getAllChannels();
    final index = channels.indexWhere((c) => c.id == channelId);
    
    if (index != -1) {
      channels[index] = channels[index].copyWith(
        subscribersCount: channels[index].subscribersCount + 1,
      );
      await _saveAllChannels(channels);
    }
  }
  
  // Уменьшить подписчиков
  static Future<void> _decrementSubscribers(String channelId) async {
    final channels = await getAllChannels();
    final index = channels.indexWhere((c) => c.id == channelId);
    
    if (index != -1) {
      final newCount = (channels[index].subscribersCount - 1).clamp(0, double.infinity).toInt();
      channels[index] = channels[index].copyWith(
        subscribersCount: newCount,
      );
      await _saveAllChannels(channels);
    }
  }
  
  // Поиск каналов
  static Future<List<Channel>> searchChannels(String query) async {
    final allChannels = await getAllChannels();
    
    if (query.isEmpty) return allChannels;
    
    final lowerQuery = query.toLowerCase();
    return allChannels.where((channel) {
      return channel.name.toLowerCase().contains(lowerQuery) ||
             channel.username.toLowerCase().contains(lowerQuery) ||
             (channel.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
  
  // Удалить канал
  static Future<void> deleteChannel(String channelId) async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) throw Exception('Необходима авторизация');
    
    final channels = await getAllChannels();
    final channel = channels.firstWhere((c) => c.id == channelId);
    
    if (channel.ownerId != currentUser.id) {
      throw Exception('Только владелец может удалить канал');
    }
    
    channels.removeWhere((c) => c.id == channelId);
    await _saveAllChannels(channels);
    
    // Удалить из подписок
    await unsubscribeFromChannel(channelId);
  }
  
  // Обновить канал
  static Future<Channel> updateChannel({
    required String channelId,
    String? name,
    String? description,
  }) async {
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) throw Exception('Необходима авторизация');
    
    final channels = await getAllChannels();
    final index = channels.indexWhere((c) => c.id == channelId);
    
    if (index == -1) throw Exception('Канал не найден');
    
    final channel = channels[index];
    if (channel.ownerId != currentUser.id) {
      throw Exception('Только владелец может редактировать канал');
    }
    
    final updatedChannel = channel.copyWith(
      name: name,
      description: description,
    );
    
    channels[index] = updatedChannel;
    await _saveAllChannels(channels);
    
    return updatedChannel;
  }
}
