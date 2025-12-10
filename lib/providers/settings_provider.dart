import 'package:flutter/material.dart';
import '../models/editor_settings.dart';
import '../services/settings_service.dart';

/// Provider for managing editor settings
class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  EditorSettings _settings = const EditorSettings();
  bool _isLoading = true;

  EditorSettings get settings => _settings;
  bool get isLoading => _isLoading;
  
  // Quick access getters
  double get fontSize => _settings.fontSize;
  String get fontFamily => _settings.fontFamily;
  bool get showLineNumbers => _settings.showLineNumbers;
  bool get wordWrap => _settings.wordWrap;
  int get tabSize => _settings.tabSize;
  bool get useSpacesForTab => _settings.useSpacesForTab;
  ThemeMode get themeMode => _settings.themeMode;
  String get editorTheme => _settings.editorTheme;
  bool get autoSave => _settings.autoSave;
  List<String> get recentFiles => _settings.recentFiles;
  String get lastOpenedPath => _settings.lastOpenedPath;

  /// Initialize settings
  Future<void> init() async {
    await _settingsService.init();
    _settings = await _settingsService.loadSettings();
    _isLoading = false;
    notifyListeners();
  }

  /// Update settings
  Future<void> updateSettings(EditorSettings newSettings) async {
    _settings = newSettings;
    await _settingsService.saveSettings(_settings);
    notifyListeners();
  }

  /// Update individual settings
  Future<void> setFontSize(double size) async {
    await updateSettings(_settings.copyWith(fontSize: size));
  }

  Future<void> setFontFamily(String family) async {
    await updateSettings(_settings.copyWith(fontFamily: family));
  }

  Future<void> setShowLineNumbers(bool show) async {
    await updateSettings(_settings.copyWith(showLineNumbers: show));
  }

  Future<void> setWordWrap(bool wrap) async {
    await updateSettings(_settings.copyWith(wordWrap: wrap));
  }

  Future<void> setTabSize(int size) async {
    await updateSettings(_settings.copyWith(tabSize: size));
  }

  Future<void> setUseSpacesForTab(bool use) async {
    await updateSettings(_settings.copyWith(useSpacesForTab: use));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await updateSettings(_settings.copyWith(themeMode: mode));
  }

  Future<void> setEditorTheme(String theme) async {
    await updateSettings(_settings.copyWith(editorTheme: theme));
  }

  Future<void> setAutoSave(bool enabled) async {
    await updateSettings(_settings.copyWith(autoSave: enabled));
  }

  Future<void> setHighlightCurrentLine(bool highlight) async {
    await updateSettings(_settings.copyWith(highlightCurrentLine: highlight));
  }

  Future<void> setBracketMatching(bool matching) async {
    await updateSettings(_settings.copyWith(bracketMatching: matching));
  }

  Future<void> setAutoCloseBrackets(bool close) async {
    await updateSettings(_settings.copyWith(autoCloseBrackets: close));
  }

  Future<void> setAutoIndent(bool indent) async {
    await updateSettings(_settings.copyWith(autoIndent: indent));
  }

  Future<void> setLastOpenedPath(String path) async {
    await updateSettings(_settings.copyWith(lastOpenedPath: path));
  }

  Future<void> addRecentFile(String path) async {
    final recentFiles = List<String>.from(_settings.recentFiles);
    recentFiles.remove(path);
    recentFiles.insert(0, path);
    if (recentFiles.length > 20) {
      recentFiles.removeRange(20, recentFiles.length);
    }
    await updateSettings(_settings.copyWith(recentFiles: recentFiles));
  }

  Future<void> clearRecentFiles() async {
    await updateSettings(_settings.copyWith(recentFiles: []));
  }
}
