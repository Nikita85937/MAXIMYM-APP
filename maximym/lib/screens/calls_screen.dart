import 'package:flutter/material.dart';
import '../models/call_history.dart';
import '../data/users_database.dart';
import '../utils/app_theme.dart';
import 'voice_call_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  final List<CallHistory> _callHistory = [];

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  void _loadCallHistory() {
    // Демо история звонков
    setState(() {
      _callHistory.addAll([
        CallHistory(
          id: 'call_1',
          user: UsersDatabase.getUserById('user_1')!,
          type: CallType.outgoing,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          duration: 245,
        ),
        CallHistory(
          id: 'call_2',
          user: UsersDatabase.officialBot,
          type: CallType.incoming,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          duration: 120,
        ),
        CallHistory(
          id: 'call_3',
          user: UsersDatabase.getUserById('user_3')!,
          type: CallType.missed,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          duration: 0,
        ),
        CallHistory(
          id: 'call_4',
          user: UsersDatabase.getUserById('user_2')!,
          type: CallType.incoming,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          duration: 320,
        ),
        CallHistory(
          id: 'call_5',
          user: UsersDatabase.getUserById('user_5')!,
          type: CallType.outgoing,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          duration: 189,
        ),
      ]);
    });
  }

  void _makeCall(CallHistory call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(user: call.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Звонки'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  _callHistory.clear();
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Text('Очистить историю'),
              ),
            ],
          ),
        ],
      ),
      body: _callHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.call,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Нет звонков',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'История голосовых звонков',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _callHistory.length,
              itemBuilder: (context, index) {
                final call = _callHistory[index];
                return _buildCallItem(call);
              },
            ),
    );
  }

  Widget _buildCallItem(CallHistory call) {
    return InkWell(
      onTap: () => _makeCall(call),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          children: [
            // Аватар
            CircleAvatar(
              radius: 24,
              backgroundColor: call.user.isOfficial
                  ? Colors.blue
                  : AppTheme.primaryColor,
              child: call.user.isOfficial
                  ? const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 24,
                    )
                  : Text(
                      call.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          call.user.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: call.isMissed ? Colors.red : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (call.user.isOfficial)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        call.icon,
                        size: 14,
                        color: call.isMissed ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        call.timeText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (call.duration > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '· ${call.durationText}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Кнопка звонка
            IconButton(
              icon: const Icon(
                Icons.call,
                color: AppTheme.primaryColor,
              ),
              onPressed: () => _makeCall(call),
            ),
          ],
        ),
      ),
    );
  }
}
