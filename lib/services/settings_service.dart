import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat.dart';

class SettingsService {
  static const String _keyName = 'user_name';
  static const String _keyUsername = 'user_username';
  static const String _keyPhone = 'user_phone';
  static const String _keyBio = 'user_bio';
  static const String _keyAvatar = 'user_avatar';
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keySound = 'sound_enabled';
  static const String _keyTheme = 'theme';

  Future<UserSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return UserSettings(
      name: prefs.getString(_keyName) ?? 'Пользователь',
      username: prefs.getString(_keyUsername) ?? 'user${DateTime.now().millisecondsSinceEpoch % 100000}',
      phone: prefs.getString(_keyPhone) ?? '+7 999 123-45-67',
      bio: prefs.getString(_keyBio) ?? 'Доступен',
      avatarPath: prefs.getString(_keyAvatar),
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      soundEnabled: prefs.getBool(_keySound) ?? true,
      theme: prefs.getString(_keyTheme) ?? 'light',
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_keyName, settings.name);
    await prefs.setString(_keyUsername, settings.username);
    await prefs.setString(_keyPhone, settings.phone);
    await prefs.setString(_keyBio, settings.bio);
    if (settings.avatarPath != null) {
      await prefs.setString(_keyAvatar, settings.avatarPath!);
    }
    await prefs.setBool(_keyNotifications, settings.notificationsEnabled);
    await prefs.setBool(_keySound, settings.soundEnabled);
    await prefs.setString(_keyTheme, settings.theme);
  }

  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
