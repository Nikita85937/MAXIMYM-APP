import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_message_bubble.dart';
import '../widgets/chat_input_with_voice.dart';
import '../utils/app_theme.dart';
import 'voice_call_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
  }

  void _loadInitialMessages() {
    setState(() {
      _messages.addAll([
        Message(
          id: '1',
          text: 'Привет! 👋',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isOutgoing: false,
        ),
        Message(
          id: '2',
          text: 'Привет! Как дела?',
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
          isOutgoing: true,
          isRead: true,
        ),
        Message(
          id: '3',
          text: widget.chat.lastMessage,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isOutgoing: false,
        ),
      ]);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage(String text, {MessageType type = MessageType.text, String? voicePath, int? voiceDuration}) {
    if (text.trim().isEmpty && type == MessageType.text) return;

    setState(() {
      _messages.add(Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        timestamp: DateTime.now(),
        isOutgoing: true,
        type: type,
        voicePath: voicePath,
        voiceDuration: voiceDuration,
      ));
    });

    _scrollToBottom();

    if (widget.chat.user.isOfficial && type == MessageType.text) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add(Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: _getBotResponse(text),
            timestamp: DateTime.now(),
            isOutgoing: false,
          ));
        });
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getBotResponse(String message) {
    final text = message.toLowerCase();
    if (text.contains('привет') || text.contains('здравствуй')) {
      return 'Привет! Готов помочь тебе достичь максимума! 💪';
    } else if (text.contains('как дела')) {
      return 'Отлично! Работаю на полную мощность! ⚡';
    } else if (text.contains('помощь') || text.contains('помоги')) {
      return 'Конечно помогу! Расскажи, что тебе нужно? 🤔';
    } else if (text.contains('спасибо')) {
      return 'Всегда рад помочь! 😊';
    } else {
      return 'Интересно! Расскажи подробнее 🚀';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: widget.chat.user.isOfficial 
                  ? Colors.blue 
                  : AppTheme.primaryColor,
              child: widget.chat.user.isOfficial
                  ? const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      widget.chat.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.chat.user.name,
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.chat.user.isOfficial)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    widget.chat.user.lastSeenText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VoiceCallScreen(user: widget.chat.user),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showDate = index == 0 ||
                      !_isSameDay(_messages[index - 1].timestamp, message.timestamp);

                  return Column(
                    children: [
                      if (showDate) _buildDateSeparator(message.timestamp),
                      message.type == MessageType.voice
                          ? VoiceMessageBubble(message: message)
                          : MessageBubble(message: message),
                    ],
                  );
                },
              ),
            ),
          ),
          ChatInputWithVoice(onSendMessage: _sendMessage),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    String dateText;

    if (_isSameDay(date, now)) {
      dateText = 'Сегодня';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = 'Вчера';
    } else {
      dateText = DateFormat('d MMMM yyyy', 'ru').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
