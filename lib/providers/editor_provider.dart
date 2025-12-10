import 'dart:async';
import 'package:flutter/material.dart';
import '../models/editor_file.dart';
import '../services/file_service.dart';
import '../utils/language_detector.dart';

/// Provider for managing open files and editor state
class EditorProvider extends ChangeNotifier {
  final FileService _fileService = FileService();
  
  final List<EditorFile> _openFiles = [];
  int _activeIndex = -1;
  bool _isSaving = false;
  Timer? _autoSaveTimer;

  List<EditorFile> get openFiles => List.unmodifiable(_openFiles);
  int get activeIndex => _activeIndex;
  EditorFile? get activeFile => 
      _activeIndex >= 0 && _activeIndex < _openFiles.length 
          ? _openFiles[_activeIndex] 
          : null;
  bool get hasUnsavedChanges => _openFiles.any((f) => f.isModified);
  bool get isSaving => _isSaving;
  int get fileCount => _openFiles.length;

  /// Open a file
  Future<bool> openFile(String path) async {
    // Check if file is already open
    final existingIndex = _openFiles.indexWhere((f) => f.path == path);
    if (existingIndex != -1) {
      _activeIndex = existingIndex;
      notifyListeners();
      return true;
    }

    // Read the file
    final file = await _fileService.readFile(path);
    if (file == null) return false;

    _openFiles.add(file);
    _activeIndex = _openFiles.length - 1;
    notifyListeners();
    return true;
  }

  /// Create a new untitled file
  void createNewFile() {
    int untitledCount = 1;
    String name = 'Untitled-$untitledCount';
    
    while (_openFiles.any((f) => f.name == name)) {
      untitledCount++;
      name = 'Untitled-$untitledCount';
    }

    final file = EditorFile(
      path: '',
      name: name,
      content: '',
      isModified: true,
    );

    _openFiles.add(file);
    _activeIndex = _openFiles.length - 1;
    notifyListeners();
  }

  /// Close a file
  Future<bool> closeFile(int index) async {
    if (index < 0 || index >= _openFiles.length) return false;

    _openFiles.removeAt(index);
    
    if (_openFiles.isEmpty) {
      _activeIndex = -1;
    } else if (_activeIndex >= index) {
      _activeIndex = (_activeIndex - 1).clamp(0, _openFiles.length - 1);
    }
    
    notifyListeners();
    return true;
  }

  /// Close all files
  Future<bool> closeAllFiles() async {
    _openFiles.clear();
    _activeIndex = -1;
    notifyListeners();
    return true;
  }

  /// Set active file by index
  void setActiveIndex(int index) {
    if (index >= 0 && index < _openFiles.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  /// Update file content
  void updateContent(String content) {
    if (activeFile == null) return;
    
    if (activeFile!.content != content) {
      _openFiles[_activeIndex] = activeFile!.copyWith(
        content: content,
        isModified: true,
      );
      notifyListeners();
    }
  }

  /// Save current file
  Future<bool> saveCurrentFile() async {
    if (activeFile == null) return false;
    
    // If no path, need to save as
    if (activeFile!.path.isEmpty) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    final success = await _fileService.writeFile(
      activeFile!.path,
      activeFile!.content,
    );

    if (success) {
      _openFiles[_activeIndex] = activeFile!.copyWith(isModified: false);
    }

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Save file with new path
  Future<bool> saveFileAs(String path) async {
    if (activeFile == null) return false;

    _isSaving = true;
    notifyListeners();

    final success = await _fileService.writeFile(path, activeFile!.content);

    if (success) {
      final name = _fileService.getFileName(path);
      final language = LanguageDetector.detectLanguage(path);
      _openFiles[_activeIndex] = activeFile!.copyWith(
        path: path,
        name: name,
        language: language,
        isModified: false,
      );
    }

    _isSaving = false;
    notifyListeners();
    return success;
  }

  /// Save all modified files
  Future<int> saveAllFiles() async {
    int savedCount = 0;
    
    for (int i = 0; i < _openFiles.length; i++) {
      if (_openFiles[i].isModified && _openFiles[i].path.isNotEmpty) {
        final success = await _fileService.writeFile(
          _openFiles[i].path,
          _openFiles[i].content,
        );
        if (success) {
          _openFiles[i] = _openFiles[i].copyWith(isModified: false);
          savedCount++;
        }
      }
    }
    
    notifyListeners();
    return savedCount;
  }

  /// Reload file from disk
  Future<bool> reloadFile(int index) async {
    if (index < 0 || index >= _openFiles.length) return false;
    
    final file = _openFiles[index];
    if (file.path.isEmpty) return false;

    final reloadedFile = await _fileService.readFile(file.path);
    if (reloadedFile == null) return false;

    _openFiles[index] = reloadedFile;
    notifyListeners();
    return true;
  }

  /// Start auto-save timer
  void startAutoSave(int intervalSeconds) {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => saveAllFiles(),
    );
  }

  /// Stop auto-save timer
  void stopAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = null;
  }

  /// Get list of unsaved files
  List<EditorFile> getUnsavedFiles() {
    return _openFiles.where((f) => f.isModified).toList();
  }

  /// Check if a specific file is open
  bool isFileOpen(String path) {
    return _openFiles.any((f) => f.path == path);
  }

  /// Get file by path
  EditorFile? getFileByPath(String path) {
    try {
      return _openFiles.firstWhere((f) => f.path == path);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
