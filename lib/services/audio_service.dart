import 'dart:io';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  Future<bool> checkPermissions() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> startRecording() async {
    try {
      if (!await checkPermissions()) {
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filename = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${directory.path}/$filename';

      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(),
          path: _currentRecordingPath!,
        );
        _isRecording = true;
        return _currentRecordingPath;
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
    return null;
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _isRecording = false;
      return path;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _recorder.stop();
      _isRecording = false;
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cancelling recording: $e');
    }
  }

  Future<int?> getRecordingDuration(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      
      // Примерная оценка длительности
      final fileSize = await file.length();
      // Примерно 1 секунда = 12KB для m4a
      return (fileSize / 12000).round();
    } catch (e) {
      print('Error getting duration: $e');
      return null;
    }
  }

  Future<void> playAudio(String path, Function(bool) onPlayingChanged) async {
    try {
      if (_isPlaying) {
        await stopAudio();
        return;
      }

      _isPlaying = true;
      onPlayingChanged(true);

      await _player.play(DeviceFileSource(path));

      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        onPlayingChanged(false);
      });
    } catch (e) {
      print('Error playing audio: $e');
      _isPlaying = false;
      onPlayingChanged(false);
    }
  }

  Future<void> stopAudio() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
