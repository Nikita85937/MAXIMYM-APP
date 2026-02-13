class Channel {
  final String id;
  final String name;
  final String username; // @channel_name
  final String? description;
  final String? avatarUrl;
  final String ownerId;
  final DateTime createdAt;
  final int subscribersCount;
  final bool isPublic;
  final bool isVerified;

  Channel({
    required this.id,
    required this.name,
    required this.username,
    this.description,
    this.avatarUrl,
    required this.ownerId,
    required this.createdAt,
    this.subscribersCount = 0,
    this.isPublic = true,
    this.isVerified = false,
  });

  Channel copyWith({
    String? id,
    String? name,
    String? username,
    String? description,
    String? avatarUrl,
    String? ownerId,
    DateTime? createdAt,
    int? subscribersCount,
    bool? isPublic,
    bool? isVerified,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      subscribersCount: subscribersCount ?? this.subscribersCount,
      isPublic: isPublic ?? this.isPublic,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'description': description,
      'avatarUrl': avatarUrl,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'subscribersCount': subscribersCount,
      'isPublic': isPublic,
      'isVerified': isVerified,
    };
  }

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      description: json['description'],
      avatarUrl: json['avatarUrl'],
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      subscribersCount: json['subscribersCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      isVerified: json['isVerified'] ?? false,
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
