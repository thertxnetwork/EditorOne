import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';

/// Provider for managing file explorer state
class FileExplorerProvider extends ChangeNotifier {
  final FileService _fileService = FileService();
  
  String? _currentDirectory;
  List<FileItem> _items = [];
  final Map<String, List<FileItem>> _expandedDirectories = {};
  bool _isLoading = false;
  String? _error;
  FileItem? _selectedItem;

  String? get currentDirectory => _currentDirectory;
  List<FileItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  FileItem? get selectedItem => _selectedItem;
  bool get hasDirectory => _currentDirectory != null;

  /// Open a directory
  Future<void> openDirectory(String path) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _fileService.listDirectory(path);
      _currentDirectory = path;
      _expandedDirectories.clear();
      _selectedItem = null;
    } catch (e) {
      _error = 'Failed to open directory: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh current directory
  Future<void> refresh() async {
    if (_currentDirectory == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _fileService.listDirectory(_currentDirectory!);
      
      // Refresh expanded directories
      for (final path in _expandedDirectories.keys.toList()) {
        _expandedDirectories[path] = await _fileService.listDirectory(path);
      }
    } catch (e) {
      _error = 'Failed to refresh: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle directory expansion
  Future<void> toggleDirectory(FileItem item) async {
    if (!item.isDirectory) return;

    if (item.isExpanded) {
      item.isExpanded = false;
      _expandedDirectories.remove(item.path);
    } else {
      _isLoading = true;
      notifyListeners();

      try {
        final children = await _fileService.listDirectory(item.path);
        item.children = children;
        item.isExpanded = true;
        _expandedDirectories[item.path] = children;
      } catch (e) {
        _error = 'Failed to expand directory: $e';
      }

      _isLoading = false;
    }

    notifyListeners();
  }

  /// Get children for a directory
  List<FileItem>? getChildren(String path) {
    return _expandedDirectories[path];
  }

  /// Check if directory is expanded
  bool isExpanded(String path) {
    return _expandedDirectories.containsKey(path);
  }

  /// Select an item
  void selectItem(FileItem? item) {
    _selectedItem = item;
    notifyListeners();
  }

  /// Navigate to parent directory
  Future<void> goToParent() async {
    if (_currentDirectory == null) return;
    
    final parent = _fileService.getParentPath(_currentDirectory!);
    if (parent != _currentDirectory) {
      await openDirectory(parent);
    }
  }

  /// Create a new file
  Future<bool> createFile(String name, [String content = '']) async {
    if (_currentDirectory == null) return false;
    
    final path = _fileService.joinPaths(_currentDirectory!, name);
    final success = await _fileService.createFile(path, content);
    
    if (success) {
      await refresh();
    }
    
    return success;
  }

  /// Create a new directory
  Future<bool> createDirectory(String name) async {
    if (_currentDirectory == null) return false;
    
    final path = _fileService.joinPaths(_currentDirectory!, name);
    final success = await _fileService.createDirectory(path);
    
    if (success) {
      await refresh();
    }
    
    return success;
  }

  /// Delete an item
  Future<bool> deleteItem(FileItem item) async {
    final success = await _fileService.delete(item.path);
    
    if (success) {
      await refresh();
      if (_selectedItem?.path == item.path) {
        _selectedItem = null;
      }
    }
    
    return success;
  }

  /// Rename an item
  Future<bool> renameItem(FileItem item, String newName) async {
    final parent = _fileService.getParentPath(item.path);
    final newPath = _fileService.joinPaths(parent, newName);
    
    final success = await _fileService.rename(item.path, newPath);
    
    if (success) {
      await refresh();
    }
    
    return success;
  }

  /// Close current directory
  void closeDirectory() {
    _currentDirectory = null;
    _items = [];
    _expandedDirectories.clear();
    _selectedItem = null;
    notifyListeners();
  }

  /// Get the full path for a relative path
  String getFullPath(String relativePath) {
    if (_currentDirectory == null) return relativePath;
    return _fileService.joinPaths(_currentDirectory!, relativePath);
  }
}
