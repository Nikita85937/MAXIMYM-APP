import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';

class VoiceMessageBubble extends StatefulWidget {
  final Message message;

  const VoiceMessageBubble({super.key, required this.message});

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  void _togglePlayback() async {
    if (widget.message.voicePath == null) return;

    await _audioService.playAudio(
      widget.message.voicePath!,
      (isPlaying) {
        setState(() {
          _isPlaying = isPlaying;
        });
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: widget.message.isOutgoing
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.message.isOutgoing
                  ? AppTheme.chatBubbleOutgoing
                  : AppTheme.chatBubbleIncoming,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.message.isOutgoing ? Colors.white : Colors.black87,
                  ),
                  onPressed: _togglePlayback,
                ),
                Container(
                  width: 150,
                  height: 30,
                  child: CustomPaint(
                    painter: WaveformPainter(
                      color: widget.message.isOutgoing ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(widget.message.voiceDuration ?? 0),
                  style: TextStyle(
                    color: widget.message.isOutgoing ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barWidth = 3.0;
    final barSpacing = 2.0;
    final barCount = (size.width / (barWidth + barSpacing)).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + barSpacing);
      final height = (size.height * 0.3) + (size.height * 0.4 * ((i % 3) / 3));
      final y = (size.height - height) / 2;

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y + height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
