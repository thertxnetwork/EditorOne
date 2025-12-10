/// Represents a file in the editor
class EditorFile {
  final String path;
  final String name;
  String content;
  bool isModified;
  final String? language;

  EditorFile({
    required this.path,
    required this.name,
    this.content = '',
    this.isModified = false,
    this.language,
  });

  /// Get the file extension
  String get extension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Create a copy of this file
  EditorFile copyWith({
    String? path,
    String? name,
    String? content,
    bool? isModified,
    String? language,
  }) {
    return EditorFile(
      path: path ?? this.path,
      name: name ?? this.name,
      content: content ?? this.content,
      isModified: isModified ?? this.isModified,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EditorFile && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
