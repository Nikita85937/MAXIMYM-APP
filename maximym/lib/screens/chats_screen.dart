import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../data/users_database.dart';
import '../widgets/chat_list_item.dart';
import 'chat_detail_screen.dart';
import 'settings_screen.dart';
import 'user_search_screen.dart';
import 'calls_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Chat> _chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    setState(() {
      _chats = UsersDatabase.getInitialChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Chat> get _filteredChats {
    if (_searchController.text.isEmpty) {
      return _chats;
    }
    return _chats.where((chat) {
      return chat.user.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          chat.user.username.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          chat.lastMessage.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Поиск...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() {}),
              )
            : const Text('Максимум'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              } else if (value == 'calls') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CallsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'calls',
                child: Row(
                  children: [
                    Icon(Icons.call, size: 20),
                    SizedBox(width: 12),
                    Text('Звонки'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Настройки'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildChatList(_filteredChats),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserSearchScreen(),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildChatList(List<Chat> chats) {
    if (chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Нет чатов',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Нажмите + чтобы найти пользователей',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatListItem(
          chat: chat,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(chat: chat),
              ),
            );
          },
        );
      },
    );
  }
}
