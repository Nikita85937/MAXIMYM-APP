import '../models/chat.dart';

class UsersDatabase {
  // Официальный бот Максимум
  static final User officialBot = User(
    id: 'bot_maximum',
    name: 'Максимум',
    username: 'maximum',
    phone: '',
    bio: 'Официальный бот Максимум 🚀\nПомогаю достигать максимальных результатов!',
    isOnline: true,
    isOfficial: true,
  );

  // Реальные пользователи
  static final List<User> allUsers = [
    officialBot,
    User(
      id: 'user_1',
      name: 'Александр Петров',
      username: 'alex_petrov',
      phone: '+7 999 123-45-67',
      bio: 'iOS разработчик | Swift | Москва',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    User(
      id: 'user_2',
      name: 'Мария Иванова',
      username: 'maria_ivanova',
      phone: '+7 999 234-56-78',
      bio: 'Frontend Developer | React | TypeScript',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    User(
      id: 'user_3',
      name: 'Дмитрий Сидоров',
      username: 'dmitry_sidorov',
      phone: '+7 999 345-67-89',
      bio: 'Backend Developer | Python | Django',
      isOnline: true,
      lastSeen: DateTime.now(),
    ),
    User(
      id: 'user_4',
      name: 'Елена Смирнова',
      username: 'elena_smirnova',
      phone: '+7 999 456-78-90',
      bio: 'UX/UI Designer | Figma | Adobe XD',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    User(
      id: 'user_5',
      name: 'Андрей Козлов',
      username: 'andrey_kozlov',
      phone: '+7 999 567-89-01',
      bio: 'DevOps Engineer | Docker | Kubernetes',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    User(
      id: 'user_6',
      name: 'Ольга Новикова',
      username: 'olga_novikova',
      phone: '+7 999 678-90-12',
      bio: 'Product Manager | Agile | Scrum',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
    ),
    User(
      id: 'user_7',
      name: 'Сергей Волков',
      username: 'sergey_volkov',
      phone: '+7 999 789-01-23',
      bio: 'QA Engineer | Автотесты | Selenium',
      isOnline: true,
      lastSeen: DateTime.now(),
    ),
    User(
      id: 'user_8',
      name: 'Анна Соколова',
      username: 'anna_sokolova',
      phone: '+7 999 890-12-34',
      bio: 'Data Scientist | ML | Python',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    User(
      id: 'user_9',
      name: 'Игорь Морозов',
      username: 'igor_morozov',
      phone: '+7 999 901-23-45',
      bio: 'Android Developer | Kotlin | Jetpack',
      isOnline: true,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    User(
      id: 'user_10',
      name: 'Татьяна Лебедева',
      username: 'tatiana_lebedeva',
      phone: '+7 999 012-34-56',
      bio: 'Project Manager | IT | Москва',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(days: 2)),
    ),
    User(
      id: 'user_11',
      name: 'Владимир Орлов',
      username: 'vladimir_orlov',
      phone: '+7 999 123-45-67',
      bio: 'Full-stack Developer | MERN',
      isOnline: true,
      lastSeen: DateTime.now(),
    ),
    User(
      id: 'user_12',
      name: 'Екатерина Павлова',
      username: 'ekaterina_pavlova',
      phone: '+7 999 234-56-78',
      bio: 'Content Manager | SMM | Копирайтинг',
      isOnline: false,
      lastSeen: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  // Поиск пользователя по юзернейму
  static User? findByUsername(String username) {
    // Убираем @ если есть
    final cleanUsername = username.startsWith('@') 
        ? username.substring(1) 
        : username;
    
    try {
      return allUsers.firstWhere(
        (user) => user.username.toLowerCase() == cleanUsername.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Поиск пользователей (по имени или юзернейму)
  static List<User> search(String query) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    return allUsers.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
             user.username.toLowerCase().contains(lowerQuery) ||
             '@${user.username}'.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Получить пользователя по ID
  static User? getUserById(String id) {
    try {
      return allUsers.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Создать начальные чаты (только с ботом)
  static List<Chat> getInitialChats() {
    return [
      Chat(
        id: 'chat_bot',
        user: officialBot,
        lastMessage: 'Привет! Я официальный бот Максимум. Чем могу помочь? 🚀',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 30)),
        unreadCount: 1,
        isPinned: true,
      ),
    ];
  }

  // Проверка доступности юзернейма
  static bool isUsernameAvailable(String username) {
    return findByUsername(username) == null;
  }

  // Валидация юзернейма
  static String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Введите юзернейм';
    }
    if (username.length < 5) {
      return 'Минимум 5 символов';
    }
    if (username.length > 32) {
      return 'Максимум 32 символа';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      return 'Только латиница, цифры и _';
    }
    if (!isUsernameAvailable(username)) {
      return 'Юзернейм уже занят';
    }
    return null;
  }
}
