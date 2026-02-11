class User {
  final String id;
  final String name;
  final String username; // Юзернейм как в Telegram
  final String phone;
  final String bio;
  final String? avatarPath;
  final bool isOnline;
  final DateTime? lastSeen;
  final bool isOfficial; // Для официального бота

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.phone,
    this.bio = '',
    this.avatarPath,
    this.isOnline = false,
    this.lastSeen,
    this.isOfficial = false,
  });

  String get displayUsername => '@$username';
  
  String get lastSeenText {
    if (isOnline) return 'в сети';
    if (lastSeen == null) return 'был(а) давно';
    
    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inMinutes < 60) return '${difference.inMinutes} мин. назад';
    if (difference.inHours < 24) return '${difference.inHours} ч. назад';
    if (difference.inDays < 7) return '${difference.inDays} д. назад';
    return 'был(а) давно';
  }
}

class Chat {
  final String id;
  final User user;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isPinned;

  Chat({
    required this.id,
    required this.user,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isPinned = false,
  });

  String get timeText {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);
    
    if (difference.inMinutes < 1) return 'только что';
    if (difference.inHours < 1) return '${difference.inMinutes} мин.';
    if (difference.inDays < 1) return '${lastMessageTime.hour}:${lastMessageTime.minute.toString().padLeft(2, '0')}';
    if (difference.inDays < 7) {
      final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
      return days[lastMessageTime.weekday - 1];
    }
    return '${lastMessageTime.day}.${lastMessageTime.month}';
  }
}

enum MessageType {
  text,
  voice,
  image,
}

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isOutgoing;
  final bool isRead;
  final MessageType type;
  final String? voicePath;
  final int? voiceDuration;
  final String? imagePath;

  Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isOutgoing,
    this.isRead = false,
    this.type = MessageType.text,
    this.voicePath,
    this.voiceDuration,
    this.imagePath,
  });
}

class UserSettings {
  final String name;
  final String username;
  final String phone;
  final String bio;
  final String? avatarPath;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final String theme;

  UserSettings({
    required this.name,
    required this.username,
    required this.phone,
    this.bio = '',
    this.avatarPath,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.theme = 'light',
  });

  UserSettings copyWith({
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? avatarPath,
    bool? notificationsEnabled,
    bool? soundEnabled,
    String? theme,
  }) {
    return UserSettings(
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      theme: theme ?? this.theme,
    );
  }
}
