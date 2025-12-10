/// Utility class to detect programming language from file path
class LanguageDetector {
  static const Map<String, String> _extensionToLanguage = {
    // Web
    'html': 'html',
    'htm': 'html',
    'xhtml': 'html',
    'css': 'css',
    'scss': 'scss',
    'sass': 'scss',
    'less': 'less',
    'js': 'javascript',
    'jsx': 'javascript',
    'mjs': 'javascript',
    'cjs': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'json': 'json',
    'jsonc': 'json',
    
    // Mobile
    'dart': 'dart',
    'kt': 'kotlin',
    'kts': 'kotlin',
    'swift': 'swift',
    
    // Backend
    'java': 'java',
    'py': 'python',
    'pyw': 'python',
    'rb': 'ruby',
    'php': 'php',
    'go': 'go',
    'rs': 'rust',
    'cs': 'csharp',
    'fs': 'fsharp',
    'vb': 'vbnet',
    'scala': 'scala',
    'groovy': 'groovy',
    'gradle': 'groovy',
    'pl': 'perl',
    'pm': 'perl',
    'lua': 'lua',
    'r': 'r',
    'R': 'r',
    
    // Systems
    'c': 'c',
    'h': 'c',
    'cpp': 'cpp',
    'hpp': 'cpp',
    'cc': 'cpp',
    'cxx': 'cpp',
    'hxx': 'cpp',
    'hh': 'cpp',
    'm': 'objectivec',
    'mm': 'objectivec',
    'asm': 'x86asm',
    's': 'x86asm',
    
    // Shell
    'sh': 'bash',
    'bash': 'bash',
    'zsh': 'bash',
    'fish': 'bash',
    'ps1': 'powershell',
    'psm1': 'powershell',
    'bat': 'dos',
    'cmd': 'dos',
    
    // Data & Config
    'xml': 'xml',
    'svg': 'xml',
    'yaml': 'yaml',
    'yml': 'yaml',
    'toml': 'ini',
    'ini': 'ini',
    'conf': 'nginx',
    'cfg': 'ini',
    'properties': 'properties',
    'env': 'properties',
    
    // Database
    'sql': 'sql',
    'pgsql': 'pgsql',
    'mysql': 'sql',
    'sqlite': 'sql',
    'graphql': 'graphql',
    'gql': 'graphql',
    
    // Documentation
    'md': 'markdown',
    'markdown': 'markdown',
    'tex': 'latex',
    'latex': 'latex',
    'rst': 'plaintext',
    
    // Other
    'dockerfile': 'dockerfile',
    'makefile': 'makefile',
    'cmake': 'cmake',
    'diff': 'diff',
    'patch': 'diff',
    'log': 'plaintext',
    'txt': 'plaintext',
  };

  static const Map<String, String> _fileNameToLanguage = {
    'dockerfile': 'dockerfile',
    'makefile': 'makefile',
    'cmakelists.txt': 'cmake',
    'gemfile': 'ruby',
    'rakefile': 'ruby',
    'podfile': 'ruby',
    'vagrantfile': 'ruby',
    'fastfile': 'ruby',
    'appfile': 'ruby',
    'brewfile': 'ruby',
    '.gitignore': 'plaintext',
    '.gitattributes': 'plaintext',
    '.gitmodules': 'ini',
    '.dockerignore': 'plaintext',
    '.editorconfig': 'ini',
    '.env': 'properties',
    '.env.local': 'properties',
    '.env.development': 'properties',
    '.env.production': 'properties',
    'package.json': 'json',
    'tsconfig.json': 'json',
    'composer.json': 'json',
    'pubspec.yaml': 'yaml',
    'pubspec.lock': 'yaml',
    'analysis_options.yaml': 'yaml',
    'build.gradle': 'groovy',
    'settings.gradle': 'groovy',
    'build.gradle.kts': 'kotlin',
    'settings.gradle.kts': 'kotlin',
    'pom.xml': 'xml',
    'requirements.txt': 'plaintext',
    'cargo.toml': 'ini',
    'go.mod': 'go',
    'go.sum': 'plaintext',
  };

  /// Detect language from file path
  static String? detectLanguage(String filePath) {
    final fileName = filePath.split('/').last.toLowerCase();
    
    // Check exact filename match
    if (_fileNameToLanguage.containsKey(fileName)) {
      return _fileNameToLanguage[fileName];
    }
    
    // Check extension
    final parts = fileName.split('.');
    if (parts.length > 1) {
      final extension = parts.last.toLowerCase();
      if (_extensionToLanguage.containsKey(extension)) {
        return _extensionToLanguage[extension];
      }
    }
    
    return 'plaintext';
  }

  /// Get display name for a language
  static String getLanguageDisplayName(String? language) {
    if (language == null) return 'Plain Text';
    
    const displayNames = {
      'html': 'HTML',
      'css': 'CSS',
      'scss': 'SCSS',
      'less': 'Less',
      'javascript': 'JavaScript',
      'typescript': 'TypeScript',
      'json': 'JSON',
      'dart': 'Dart',
      'kotlin': 'Kotlin',
      'swift': 'Swift',
      'java': 'Java',
      'python': 'Python',
      'ruby': 'Ruby',
      'php': 'PHP',
      'go': 'Go',
      'rust': 'Rust',
      'csharp': 'C#',
      'fsharp': 'F#',
      'vbnet': 'VB.NET',
      'scala': 'Scala',
      'groovy': 'Groovy',
      'perl': 'Perl',
      'lua': 'Lua',
      'r': 'R',
      'c': 'C',
      'cpp': 'C++',
      'objectivec': 'Objective-C',
      'x86asm': 'Assembly',
      'bash': 'Shell',
      'powershell': 'PowerShell',
      'dos': 'Batch',
      'xml': 'XML',
      'yaml': 'YAML',
      'ini': 'INI',
      'nginx': 'Nginx Config',
      'properties': 'Properties',
      'sql': 'SQL',
      'pgsql': 'PostgreSQL',
      'graphql': 'GraphQL',
      'markdown': 'Markdown',
      'latex': 'LaTeX',
      'dockerfile': 'Dockerfile',
      'makefile': 'Makefile',
      'cmake': 'CMake',
      'diff': 'Diff',
      'plaintext': 'Plain Text',
    };
    
    return displayNames[language] ?? language;
  }

  /// Get file icon based on language/extension
  static String getFileIcon(String? language) {
    const icons = {
      'dart': '🎯',
      'javascript': '📜',
      'typescript': '📘',
      'html': '🌐',
      'css': '🎨',
      'json': '📋',
      'python': '🐍',
      'java': '☕',
      'kotlin': '🔷',
      'swift': '🍎',
      'go': '🐹',
      'rust': '🦀',
      'c': '⚙️',
      'cpp': '⚙️',
      'markdown': '📝',
      'yaml': '⚙️',
      'xml': '📄',
      'sql': '🗃️',
      'bash': '💻',
      'dockerfile': '🐳',
    };
    
    return icons[language] ?? '📄';
  }
}
