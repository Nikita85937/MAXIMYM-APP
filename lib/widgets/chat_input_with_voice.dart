import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';

class ChatInputWithVoice extends StatefulWidget {
  final Function(String, {MessageType type, String? voicePath, int? voiceDuration}) onSendMessage;

  const ChatInputWithVoice({super.key, required this.onSendMessage});

  @override
  State<ChatInputWithVoice> createState() => _ChatInputWithVoiceState();
}

class _ChatInputWithVoiceState extends State<ChatInputWithVoice> {
  final TextEditingController _messageController = TextEditingController();
  final AudioService _audioService = AudioService();
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void dispose() {
    _messageController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final path = await _audioService.startRecording();
    if (path != null) {
      setState(() {
        _isRecording = true;
        _recordingPath = path;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioService.stopRecording();
    if (path != null && _recordingPath != null) {
      final duration = await _audioService.getRecordingDuration(path);
      widget.onSendMessage(
        'Голосовое сообщение',
        type: MessageType.voice,
        voicePath: path,
        voiceDuration: duration,
      );
    }
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
  }

  Future<void> _cancelRecording() async {
    await _audioService.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
  }

  void _sendTextMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      widget.onSendMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _isRecording ? _buildRecordingUI() : _buildInputUI(),
      ),
    );
  }

  Widget _buildInputUI() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.attach_file),
          onPressed: () {},
          color: Colors.grey,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Сообщение',
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendTextMessage(),
              onChanged: (text) => setState(() {}),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_messageController.text.trim().isEmpty)
          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.voiceButtonColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Удерживайте для записи голосового сообщения'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                color: Colors.white,
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendTextMessage,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildRecordingUI() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: _cancelRecording,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Запись...',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_voice, color: Colors.red.shade300),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: _stopRecording,
        ),
      ],
    );
  }
}
