import 'package:flutter/material.dart';
import '../models/channel.dart';
import '../services/channel_service.dart';
import '../services/official_service.dart';
import '../utils/app_theme.dart';
import 'create_channel_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  List<Channel> _channels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() => _isLoading = true);
    
    final channels = await ChannelService.getSubscribedChannels();
    
    setState(() {
      _channels = channels;
      _isLoading = false;
    });
  }

  void _createChannel() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateChannelScreen()),
    );
    
    if (result != null) {
      _loadChannels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Каналы'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createChannel,
            tooltip: 'Создать канал',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _channels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Нет каналов',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _createChannel,
                        child: const Text('Создать канал'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _channels.length,
                  itemBuilder: (context, index) {
                    final channel = _channels[index];
                    final isOfficial = OfficialService.isOfficialChannel(channel.id);
                    
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOfficial
                            ? Colors.blue
                            : AppTheme.primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.campaign,
                          color: isOfficial ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            channel.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isOfficial || channel.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${channel.username}'),
                          if (channel.description != null)
                            Text(
                              channel.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(
                        '${channel.subscribersCount} подписчиков',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      onTap: () {
                        // Открыть канал
                      },
                    );
                  },
                ),
    );
  }
}
