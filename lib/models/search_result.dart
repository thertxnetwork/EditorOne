/// Represents a search result
class SearchResult {
  final String filePath;
  final String fileName;
  final int lineNumber;
  final String lineContent;
  final int matchStart;
  final int matchEnd;

  SearchResult({
    required this.filePath,
    required this.fileName,
    required this.lineNumber,
    required this.lineContent,
    required this.matchStart,
    required this.matchEnd,
  });

  /// Get the matched text
  String get matchedText => lineContent.substring(matchStart, matchEnd);

  @override
  String toString() {
    return '$fileName:$lineNumber - ${lineContent.trim()}';
  }
}

/// Represents a collection of search results grouped by file
class FileSearchResults {
  final String filePath;
  final String fileName;
  final List<SearchResult> results;

  FileSearchResults({
    required this.filePath,
    required this.fileName,
    required this.results,
  });

  int get totalMatches => results.length;
}
