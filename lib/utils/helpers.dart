/// Format file size for display
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

/// Format date for display
String formatDate(DateTime? date) {
  if (date == null) return '';
  final now = DateTime.now();
  final diff = now.difference(date);
  
  if (diff.inDays == 0) {
    if (diff.inHours == 0) {
      return '${diff.inMinutes}m ago';
    }
    return '${diff.inHours}h ago';
  }
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  
  return '${date.day}/${date.month}/${date.year}';
}

/// Truncate string with ellipsis
String truncateString(String str, int maxLength) {
  if (str.length <= maxLength) return str;
  return '${str.substring(0, maxLength - 3)}...';
}

/// Get file icon based on extension
String getFileIconForExtension(String extension) {
  const iconMap = {
    'dart': '🎯',
    'js': '📜',
    'jsx': '📜',
    'ts': '📘',
    'tsx': '📘',
    'html': '🌐',
    'htm': '🌐',
    'css': '🎨',
    'scss': '🎨',
    'json': '📋',
    'xml': '📄',
    'yaml': '⚙️',
    'yml': '⚙️',
    'py': '🐍',
    'java': '☕',
    'kt': '🔷',
    'kts': '🔷',
    'swift': '🍎',
    'go': '🐹',
    'rs': '🦀',
    'c': '⚙️',
    'cpp': '⚙️',
    'h': '⚙️',
    'hpp': '⚙️',
    'md': '📝',
    'txt': '📄',
    'sql': '🗃️',
    'sh': '💻',
    'bash': '💻',
    'gradle': '🐘',
    'dockerfile': '🐳',
    'png': '🖼️',
    'jpg': '🖼️',
    'jpeg': '🖼️',
    'gif': '🖼️',
    'svg': '🖼️',
    'pdf': '📕',
    'zip': '📦',
    'tar': '📦',
    'gz': '📦',
    'apk': '📱',
    'exe': '⚡',
  };
  
  return iconMap[extension.toLowerCase()] ?? '📄';
}
