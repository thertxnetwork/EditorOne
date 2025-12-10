import 'dart:io';
import 'dart:async';
import '../models/search_result.dart';

/// Service for searching files and text content
class SearchService {
  bool _isCancelled = false;

  /// Cancel the current search
  void cancelSearch() {
    _isCancelled = true;
  }

  /// Search for files by name
  Stream<FileSearchResults> searchFilesByName(
    String directoryPath,
    String query, {
    bool caseSensitive = false,
  }) async* {
    _isCancelled = false;
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return;

    final pattern = caseSensitive ? query : query.toLowerCase();

    await for (final entity in dir.list(recursive: true)) {
      if (_isCancelled) return;
      
      if (entity is File) {
        final fileName = entity.uri.pathSegments.last;
        final matchName = caseSensitive ? fileName : fileName.toLowerCase();
        
        if (matchName.contains(pattern)) {
          yield FileSearchResults(
            filePath: entity.path,
            fileName: fileName,
            results: [],
          );
        }
      }
    }
  }

  /// Search for text content in files
  Stream<FileSearchResults> searchInFiles(
    String directoryPath,
    String query, {
    bool caseSensitive = false,
    bool useRegex = false,
    List<String>? includeExtensions,
    List<String>? excludePatterns,
  }) async* {
    _isCancelled = false;
    final dir = Directory(directoryPath);
    if (!await dir.exists()) return;

    final RegExp? regex = useRegex
        ? RegExp(query, caseSensitive: caseSensitive)
        : null;

    await for (final entity in dir.list(recursive: true)) {
      if (_isCancelled) return;
      
      if (entity is File) {
        final fileName = entity.uri.pathSegments.last;
        
        // Skip hidden files and directories
        if (entity.path.split('/').any((p) => p.startsWith('.'))) continue;
        
        // Check extensions filter
        if (includeExtensions != null && includeExtensions.isNotEmpty) {
          final ext = fileName.split('.').last.toLowerCase();
          if (!includeExtensions.contains(ext)) continue;
        }
        
        // Check exclude patterns
        if (excludePatterns != null) {
          bool shouldExclude = false;
          for (final pattern in excludePatterns) {
            if (entity.path.contains(pattern)) {
              shouldExclude = true;
              break;
            }
          }
          if (shouldExclude) continue;
        }
        
        // Try to read as text
        try {
          final content = await entity.readAsString();
          final results = _searchInContent(
            content,
            query,
            entity.path,
            fileName,
            caseSensitive: caseSensitive,
            regex: regex,
          );
          
          if (results.isNotEmpty) {
            yield FileSearchResults(
              filePath: entity.path,
              fileName: fileName,
              results: results,
            );
          }
        } catch (_) {
          // Skip binary files
        }
      }
    }
  }

  /// Search within a single file's content
  List<SearchResult> searchInContent(
    String content,
    String query,
    String filePath,
    String fileName, {
    bool caseSensitive = false,
    bool useRegex = false,
  }) {
    final regex = useRegex
        ? RegExp(query, caseSensitive: caseSensitive)
        : null;
    
    return _searchInContent(
      content,
      query,
      filePath,
      fileName,
      caseSensitive: caseSensitive,
      regex: regex,
    );
  }

  List<SearchResult> _searchInContent(
    String content,
    String query,
    String filePath,
    String fileName, {
    bool caseSensitive = false,
    RegExp? regex,
  }) {
    final results = <SearchResult>[];
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (regex != null) {
        final matches = regex.allMatches(line);
        for (final match in matches) {
          results.add(SearchResult(
            filePath: filePath,
            fileName: fileName,
            lineNumber: i + 1,
            lineContent: line,
            matchStart: match.start,
            matchEnd: match.end,
          ));
        }
      } else {
        final searchLine = caseSensitive ? line : line.toLowerCase();
        final searchQuery = caseSensitive ? query : query.toLowerCase();
        
        int index = 0;
        while ((index = searchLine.indexOf(searchQuery, index)) != -1) {
          results.add(SearchResult(
            filePath: filePath,
            fileName: fileName,
            lineNumber: i + 1,
            lineContent: line,
            matchStart: index,
            matchEnd: index + query.length,
          ));
          index += query.length;
        }
      }
    }
    
    return results;
  }

  /// Replace text in a file
  Future<String> replaceInContent(
    String content,
    String query,
    String replacement, {
    bool caseSensitive = false,
    bool useRegex = false,
    bool replaceAll = true,
  }) async {
    if (useRegex) {
      final regex = RegExp(query, caseSensitive: caseSensitive);
      if (replaceAll) {
        return content.replaceAll(regex, replacement);
      } else {
        return content.replaceFirst(regex, replacement);
      }
    } else {
      if (caseSensitive) {
        if (replaceAll) {
          return content.replaceAll(query, replacement);
        } else {
          return content.replaceFirst(query, replacement);
        }
      } else {
        final regex = RegExp(
          RegExp.escape(query),
          caseSensitive: false,
        );
        if (replaceAll) {
          return content.replaceAll(regex, replacement);
        } else {
          return content.replaceFirst(regex, replacement);
        }
      }
    }
  }
}
