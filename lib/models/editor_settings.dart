import 'package:flutter/material.dart';

/// Represents editor settings
class EditorSettings {
  final double fontSize;
  final String fontFamily;
  final bool showLineNumbers;
  final bool wordWrap;
  final int tabSize;
  final bool useSpacesForTab;
  final bool autoSave;
  final int autoSaveInterval;
  final ThemeMode themeMode;
  final String editorTheme;
  final bool showMinimap;
  final bool highlightCurrentLine;
  final bool showWhitespace;
  final bool bracketMatching;
  final bool autoCloseBrackets;
  final bool autoIndent;
  final String lastOpenedPath;
  final List<String> recentFiles;

  const EditorSettings({
    this.fontSize = 14.0,
    this.fontFamily = 'JetBrains Mono',
    this.showLineNumbers = true,
    this.wordWrap = true,
    this.tabSize = 2,
    this.useSpacesForTab = true,
    this.autoSave = false,
    this.autoSaveInterval = 30,
    this.themeMode = ThemeMode.system,
    this.editorTheme = 'monokai',
    this.showMinimap = false,
    this.highlightCurrentLine = true,
    this.showWhitespace = false,
    this.bracketMatching = true,
    this.autoCloseBrackets = true,
    this.autoIndent = true,
    this.lastOpenedPath = '',
    this.recentFiles = const [],
  });

  EditorSettings copyWith({
    double? fontSize,
    String? fontFamily,
    bool? showLineNumbers,
    bool? wordWrap,
    int? tabSize,
    bool? useSpacesForTab,
    bool? autoSave,
    int? autoSaveInterval,
    ThemeMode? themeMode,
    String? editorTheme,
    bool? showMinimap,
    bool? highlightCurrentLine,
    bool? showWhitespace,
    bool? bracketMatching,
    bool? autoCloseBrackets,
    bool? autoIndent,
    String? lastOpenedPath,
    List<String>? recentFiles,
  }) {
    return EditorSettings(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      showLineNumbers: showLineNumbers ?? this.showLineNumbers,
      wordWrap: wordWrap ?? this.wordWrap,
      tabSize: tabSize ?? this.tabSize,
      useSpacesForTab: useSpacesForTab ?? this.useSpacesForTab,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      themeMode: themeMode ?? this.themeMode,
      editorTheme: editorTheme ?? this.editorTheme,
      showMinimap: showMinimap ?? this.showMinimap,
      highlightCurrentLine: highlightCurrentLine ?? this.highlightCurrentLine,
      showWhitespace: showWhitespace ?? this.showWhitespace,
      bracketMatching: bracketMatching ?? this.bracketMatching,
      autoCloseBrackets: autoCloseBrackets ?? this.autoCloseBrackets,
      autoIndent: autoIndent ?? this.autoIndent,
      lastOpenedPath: lastOpenedPath ?? this.lastOpenedPath,
      recentFiles: recentFiles ?? this.recentFiles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'showLineNumbers': showLineNumbers,
      'wordWrap': wordWrap,
      'tabSize': tabSize,
      'useSpacesForTab': useSpacesForTab,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'themeMode': themeMode.index,
      'editorTheme': editorTheme,
      'showMinimap': showMinimap,
      'highlightCurrentLine': highlightCurrentLine,
      'showWhitespace': showWhitespace,
      'bracketMatching': bracketMatching,
      'autoCloseBrackets': autoCloseBrackets,
      'autoIndent': autoIndent,
      'lastOpenedPath': lastOpenedPath,
      'recentFiles': recentFiles,
    };
  }

  factory EditorSettings.fromJson(Map<String, dynamic> json) {
    return EditorSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      fontFamily: json['fontFamily'] as String? ?? 'JetBrains Mono',
      showLineNumbers: json['showLineNumbers'] as bool? ?? true,
      wordWrap: json['wordWrap'] as bool? ?? true,
      tabSize: json['tabSize'] as int? ?? 2,
      useSpacesForTab: json['useSpacesForTab'] as bool? ?? true,
      autoSave: json['autoSave'] as bool? ?? false,
      autoSaveInterval: json['autoSaveInterval'] as int? ?? 30,
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      editorTheme: json['editorTheme'] as String? ?? 'monokai',
      showMinimap: json['showMinimap'] as bool? ?? false,
      highlightCurrentLine: json['highlightCurrentLine'] as bool? ?? true,
      showWhitespace: json['showWhitespace'] as bool? ?? false,
      bracketMatching: json['bracketMatching'] as bool? ?? true,
      autoCloseBrackets: json['autoCloseBrackets'] as bool? ?? true,
      autoIndent: json['autoIndent'] as bool? ?? true,
      lastOpenedPath: json['lastOpenedPath'] as String? ?? '',
      recentFiles: (json['recentFiles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Available font families for the editor
class EditorFonts {
  static const List<String> availableFonts = [
    'JetBrains Mono',
    'Fira Code',
    'Source Code Pro',
    'Roboto Mono',
    'monospace',
  ];
}

/// Available editor themes
class EditorThemes {
  static const List<String> availableThemes = [
    'monokai',
    'dracula',
    'github',
    'vs',
    'vs2015',
    'atom-one-dark',
    'atom-one-light',
    'androidstudio',
    'agate',
    'nord',
  ];
}
