import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/chat.dart';
import '../services/settings_service.dart';
import '../data/users_database.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  UserSettings? _settings;
  bool _isLoading = true;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _settings = settings;
      _nameController.text = settings.name;
      _usernameController.text = settings.username;
      _bioController.text = settings.bio;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && _settings != null) {
      final newSettings = _settings!.copyWith(avatarPath: image.path);
      await _settingsService.saveSettings(newSettings);
      setState(() {
        _settings = newSettings;
      });
    }
  }

  void _validateUsername(String username) {
    setState(() {
      if (username == _settings?.username) {
        _usernameError = null;
      } else {
        _usernameError = UsersDatabase.validateUsername(username);
      }
    });
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;
    
    // Проверка юзернейма
    if (_usernameController.text != _settings!.username) {
      final error = UsersDatabase.validateUsername(_usernameController.text);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
        return;
      }
    }

    final newSettings = _settings!.copyWith(
      name: _nameController.text,
      username: _usernameController.text,
      bio: _bioController.text,
    );

    await _settingsService.saveSettings(newSettings);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Настройки сохранены')),
      );
      setState(() {
        _settings = newSettings;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          
          // Аватар
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppTheme.primaryColor,
                    backgroundImage: _settings?.avatarPath != null
                        ? FileImage(File(_settings!.avatarPath!))
                        : null,
                    child: _settings?.avatarPath == null
                        ? Text(
                            _settings?.name[0].toUpperCase() ?? 'М',
                            style: const TextStyle(
                              fontSize: 48,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Личные данные
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ЛИЧНЫЕ ДАННЫЕ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _buildTextField(
            controller: _nameController,
            label: 'Имя',
            icon: Icons.person,
          ),
          _buildTextField(
            controller: _usernameController,
            label: 'Юзернейм',
            icon: Icons.alternate_email,
            prefix: '@',
            errorText: _usernameError,
            onChanged: _validateUsername,
          ),
          _buildTextField(
            controller: _bioController,
            label: 'О себе',
            icon: Icons.info_outline,
            maxLines: 3,
          ),
          _buildInfoTile(
            label: 'Телефон',
            value: _settings?.phone ?? '',
            icon: Icons.phone,
          ),
          
          const SizedBox(height: 20),
          
          // Настройки уведомлений
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'УВЕДОМЛЕНИЯ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _buildSwitchTile(
            title: 'Уведомления',
            subtitle: 'Получать push-уведомления',
            icon: Icons.notifications,
            value: _settings?.notificationsEnabled ?? true,
            onChanged: (value) async {
              if (_settings != null) {
                final newSettings = _settings!.copyWith(notificationsEnabled: value);
                await _settingsService.saveSettings(newSettings);
                setState(() {
                  _settings = newSettings;
                });
              }
            },
          ),
          _buildSwitchTile(
            title: 'Звук',
            subtitle: 'Звук уведомлений',
            icon: Icons.volume_up,
            value: _settings?.soundEnabled ?? true,
            onChanged: (value) async {
              if (_settings != null) {
                final newSettings = _settings!.copyWith(soundEnabled: value);
                await _settingsService.saveSettings(newSettings);
                setState(() {
                  _settings = newSettings;
                });
              }
            },
          ),
          
          const SizedBox(height: 20),
          
          // О приложении
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'О ПРИЛОЖЕНИИ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          _buildInfoTile(
            label: 'Версия',
            value: '1.0.0',
            icon: Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
    String? errorText,
    Function(String)? onChanged,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Icon(icon, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (prefix != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, right: 4),
                        child: Text(
                          prefix,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: label,
                          border: InputBorder.none,
                        ),
                        maxLines: maxLines,
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      errorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
