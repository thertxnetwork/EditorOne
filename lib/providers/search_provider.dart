import 'dart:async';
import 'package:flutter/material.dart';
import '../models/search_result.dart';
import '../services/search_service.dart';

/// Provider for search functionality
class SearchProvider extends ChangeNotifier {
  final SearchService _searchService = SearchService();
  
  String _query = '';
  bool _isSearching = false;
  bool _caseSensitive = false;
  bool _useRegex = false;
  bool _searchInFiles = true;
  List<FileSearchResults> _results = [];
  StreamSubscription? _searchSubscription;

  String get query => _query;
  bool get isSearching => _isSearching;
  bool get caseSensitive => _caseSensitive;
  bool get useRegex => _useRegex;
  bool get searchInFiles => _searchInFiles;
  List<FileSearchResults> get results => _results;
  
  int get totalFiles => _results.length;
  int get totalMatches => _results.fold(0, (sum, r) => sum + r.totalMatches);

  /// Update search query
  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  /// Toggle case sensitivity
  void toggleCaseSensitive() {
    _caseSensitive = !_caseSensitive;
    notifyListeners();
  }

  /// Toggle regex mode
  void toggleRegex() {
    _useRegex = !_useRegex;
    notifyListeners();
  }

  /// Toggle search mode (files vs content)
  void toggleSearchMode() {
    _searchInFiles = !_searchInFiles;
    notifyListeners();
  }

  /// Set search options
  void setOptions({
    bool? caseSensitive,
    bool? useRegex,
    bool? searchInFiles,
  }) {
    if (caseSensitive != null) _caseSensitive = caseSensitive;
    if (useRegex != null) _useRegex = useRegex;
    if (searchInFiles != null) _searchInFiles = searchInFiles;
    notifyListeners();
  }

  /// Search for files by name
  Future<void> searchFilesByName(String directoryPath) async {
    if (_query.isEmpty || _isSearching) return;
    
    cancelSearch();
    _isSearching = true;
    _results = [];
    notifyListeners();

    _searchSubscription = _searchService
        .searchFilesByName(
          directoryPath,
          _query,
          caseSensitive: _caseSensitive,
        )
        .listen(
          (result) {
            _results.add(result);
            notifyListeners();
          },
          onDone: () {
            _isSearching = false;
            notifyListeners();
          },
          onError: (e) {
            _isSearching = false;
            notifyListeners();
          },
        );
  }

  /// Search for text content in files
  Future<void> searchInFilesContent(
    String directoryPath, {
    List<String>? includeExtensions,
    List<String>? excludePatterns,
  }) async {
    if (_query.isEmpty || _isSearching) return;
    
    cancelSearch();
    _isSearching = true;
    _results = [];
    notifyListeners();

    _searchSubscription = _searchService
        .searchInFiles(
          directoryPath,
          _query,
          caseSensitive: _caseSensitive,
          useRegex: _useRegex,
          includeExtensions: includeExtensions,
          excludePatterns: excludePatterns,
        )
        .listen(
          (result) {
            _results.add(result);
            notifyListeners();
          },
          onDone: () {
            _isSearching = false;
            notifyListeners();
          },
          onError: (e) {
            _isSearching = false;
            notifyListeners();
          },
        );
  }

  /// Cancel current search
  void cancelSearch() {
    _searchSubscription?.cancel();
    _searchService.cancelSearch();
    _isSearching = false;
    notifyListeners();
  }

  /// Clear results
  void clearResults() {
    _results = [];
    _query = '';
    notifyListeners();
  }

  /// Search and replace in content
  Future<String> replaceInContent(
    String content,
    String replacement, {
    bool replaceAll = true,
  }) async {
    return _searchService.replaceInContent(
      content,
      _query,
      replacement,
      caseSensitive: _caseSensitive,
      useRegex: _useRegex,
      replaceAll: replaceAll,
    );
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    super.dispose();
  }
}
