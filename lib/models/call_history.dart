import 'chat.dart';

enum CallType {
  incoming,
  outgoing,
  missed,
}

class CallHistory {
  final String id;
  final User user;
  final CallType type;
  final DateTime timestamp;
  final int duration; // в секундах, 0 если пропущен

  CallHistory({
    required this.id,
    required this.user,
    required this.type,
    required this.timestamp,
    this.duration = 0,
  });

  String get durationText {
    if (duration == 0) return 'Пропущен';
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get timeText {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин. назад';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} ч. назад';
    }
    if (difference.inDays == 1) {
      return 'Вчера';
    }
    return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
  }

  IconData get icon {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_missed;
    }
  }

  bool get isMissed => type == CallType.missed;
}
