import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../utils/app_theme.dart';

class VoiceCallScreen extends StatefulWidget {
  final User user;
  final bool isIncoming;

  const VoiceCallScreen({
    super.key,
    required this.user,
    this.isIncoming = false,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _callTimer;
  int _callDuration = 0;
  CallState _callState = CallState.connecting;
  bool _isMuted = false;
  bool _isSpeaker = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    if (widget.isIncoming) {
      _callState = CallState.ringing;
    } else {
      _simulateConnection();
    }
  }

  void _simulateConnection() {
    // Симуляция подключения
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _callState != CallState.ended) {
        setState(() {
          _callState = CallState.connected;
        });
        _startCallTimer();
      }
    });
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration++;
        });
      }
    });
  }

  void _acceptCall() {
    setState(() {
      _callState = CallState.connected;
    });
    _startCallTimer();
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      _callState = CallState.ended;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeaker = !_isSpeaker;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String get _callStatusText {
    switch (_callState) {
      case CallState.connecting:
        return 'Соединение...';
      case CallState.ringing:
        return 'Входящий звонок...';
      case CallState.connected:
        return _formatDuration(_callDuration);
      case CallState.ended:
        return 'Звонок завершен';
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _endCall,
                  ),
                  const Text(
                    'Голосовой звонок',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const Spacer(),

            // Аватар с пульсацией
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Внешнее кольцо
                    if (_callState == CallState.connecting ||
                        _callState == CallState.ringing)
                      Container(
                        width: 200 + (60 * _pulseController.value),
                        height: 200 + (60 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(0.3 - (0.3 * _pulseController.value)),
                            width: 2,
                          ),
                        ),
                      ),
                    // Среднее кольцо
                    if (_callState == CallState.connecting ||
                        _callState == CallState.ringing)
                      Container(
                        width: 200 + (30 * _pulseController.value),
                        height: 200 + (30 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white
                                .withOpacity(0.5 - (0.5 * _pulseController.value)),
                            width: 2,
                          ),
                        ),
                      ),
                    // Аватар
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.user.isOfficial
                            ? const Icon(
                                Icons.verified,
                                size: 80,
                                color: AppTheme.primaryColor,
                              )
                            : Text(
                                widget.user.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // Имя пользователя
            Text(
              widget.user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Статус звонка
            Text(
              _callStatusText,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            // Кнопки управления
            if (_callState == CallState.connected)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                      label: 'Динамик',
                      onTap: _toggleSpeaker,
                      isActive: _isSpeaker,
                    ),
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: _isMuted ? 'Откл' : 'Микрофон',
                      onTap: _toggleMute,
                      isActive: _isMuted,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            // Кнопки звонка
            Padding(
              padding: const EdgeInsets.all(40),
              child: _buildCallButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButtons() {
    if (_callState == CallState.ringing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Отклонить
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.call_end,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _endCall,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Отклонить',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          // Принять
          Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.call,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _acceptCall,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Принять',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _endCall,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Завершить',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : Colors.white,
              size: 28,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

enum CallState {
  connecting,
  ringing,
  connected,
  ended,
}
