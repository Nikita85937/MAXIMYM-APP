class User {
  final String id;
  final String name;
  final String username;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final DateTime registeredAt;
  final bool isOnline;

  User({
    required this.id,
    required this.name,
    required this.username,
    this.phone,
    this.bio,
    this.avatarUrl,
    required this.registeredAt,
    this.isOnline = false,
  });

  User copyWith({
    String? id,
    String? name,
    String? username,
    String? phone,
    String? bio,
    String? avatarUrl,
    DateTime? registeredAt,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      registeredAt: registeredAt ?? this.registeredAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'phone': phone,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'registeredAt': registeredAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      phone: json['phone'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      registeredAt: DateTime.parse(json['registeredAt']),
      isOnline: json['isOnline'] ?? false,
    );
  }

  String getInitials() {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
