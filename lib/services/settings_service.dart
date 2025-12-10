import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/editor_settings.dart';

/// Service for managing editor settings and preferences
class SettingsService {
  static const String _settingsKey = 'editor_settings';
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<EditorSettings> loadSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = _prefs?.getString(_settingsKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return EditorSettings.fromJson(json);
      } catch (e) {
        return const EditorSettings();
      }
    }
    return const EditorSettings();
  }

  Future<void> saveSettings(EditorSettings settings) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await _prefs?.setString(_settingsKey, jsonString);
  }

  Future<void> addRecentFile(EditorSettings settings, String path) async {
    final recentFiles = List<String>.from(settings.recentFiles);
    recentFiles.remove(path);
    recentFiles.insert(0, path);
    // Keep only the last 20 files
    if (recentFiles.length > 20) {
      recentFiles.removeRange(20, recentFiles.length);
    }
    final newSettings = settings.copyWith(recentFiles: recentFiles);
    await saveSettings(newSettings);
  }

  Future<void> clearRecentFiles() async {
    final settings = await loadSettings();
    final newSettings = settings.copyWith(recentFiles: []);
    await saveSettings(newSettings);
  }
}
