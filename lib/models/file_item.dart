/// Represents a file or directory in the file explorer
class FileItem {
  final String path;
  final String name;
  final bool isDirectory;
  final int size;
  final DateTime? lastModified;
  List<FileItem>? children;
  bool isExpanded;

  FileItem({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.size = 0,
    this.lastModified,
    this.children,
    this.isExpanded = false,
  });

  /// Get the file extension
  String get extension {
    if (isDirectory) return '';
    final parts = name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  /// Check if this is a text file that can be edited
  bool get isEditable {
    const editableExtensions = [
      'txt', 'md', 'markdown', 'json', 'xml', 'yaml', 'yml',
      'dart', 'java', 'kt', 'kts', 'py', 'js', 'ts', 'jsx', 'tsx',
      'html', 'css', 'scss', 'less', 'php', 'rb', 'go', 'rs', 'swift',
      'c', 'cpp', 'h', 'hpp', 'cs', 'sh', 'bash', 'zsh', 'fish',
      'sql', 'graphql', 'toml', 'ini', 'conf', 'cfg', 'env',
      'gitignore', 'dockerignore', 'editorconfig', 'lock',
      'gradle', 'properties', 'pro', 'log', 'csv',
    ];
    return !isDirectory && 
           (editableExtensions.contains(extension) || extension.isEmpty);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}
