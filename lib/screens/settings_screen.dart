import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/editor_settings.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Appearance Section
        _SectionHeader(title: 'Appearance'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_rounded),
                title: const Text('Theme'),
                subtitle: Text(_getThemeModeText(settings.themeMode)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showThemeDialog(context, settings),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.palette_rounded),
                title: const Text('Editor Theme'),
                subtitle: Text(settings.editorTheme),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showEditorThemeDialog(context, settings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Editor Section
        _SectionHeader(title: 'Editor'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields_rounded),
                title: const Text('Font Family'),
                subtitle: Text(settings.fontFamily),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showFontDialog(context, settings),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.format_size_rounded),
                title: const Text('Font Size'),
                subtitle: Text('${settings.fontSize.toInt()} px'),
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: settings.fontSize,
                    min: 10,
                    max: 32,
                    divisions: 22,
                    label: '${settings.fontSize.toInt()}',
                    onChanged: (value) => settings.setFontSize(value),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.space_bar_rounded),
                title: const Text('Tab Size'),
                subtitle: Text('${settings.tabSize} spaces'),
                trailing: SizedBox(
                  width: 150,
                  child: Slider(
                    value: settings.tabSize.toDouble(),
                    min: 2,
                    max: 8,
                    divisions: 3,
                    label: '${settings.tabSize}',
                    onChanged: (value) => settings.setTabSize(value.toInt()),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.wrap_text_rounded),
                title: const Text('Word Wrap'),
                subtitle: const Text('Wrap long lines'),
                value: settings.wordWrap,
                onChanged: (value) => settings.setWordWrap(value),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.format_list_numbered_rounded),
                title: const Text('Line Numbers'),
                subtitle: const Text('Show line numbers'),
                value: settings.showLineNumbers,
                onChanged: (value) => settings.setShowLineNumbers(value),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.space_bar_rounded),
                title: const Text('Use Spaces for Tab'),
                subtitle: const Text('Insert spaces instead of tab character'),
                value: settings.useSpacesForTab,
                onChanged: (value) => settings.setUseSpacesForTab(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Behavior Section
        _SectionHeader(title: 'Behavior'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.highlight_rounded),
                title: const Text('Highlight Current Line'),
                value: settings.settings.highlightCurrentLine,
                onChanged: (value) => settings.setHighlightCurrentLine(value),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.code_rounded),
                title: const Text('Bracket Matching'),
                subtitle: const Text('Highlight matching brackets'),
                value: settings.settings.bracketMatching,
                onChanged: (value) => settings.setBracketMatching(value),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.auto_fix_high_rounded),
                title: const Text('Auto Close Brackets'),
                subtitle: const Text('Automatically close brackets and quotes'),
                value: settings.settings.autoCloseBrackets,
                onChanged: (value) => settings.setAutoCloseBrackets(value),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile(
                secondary: const Icon(Icons.format_indent_increase_rounded),
                title: const Text('Auto Indent'),
                subtitle: const Text('Automatically indent new lines'),
                value: settings.settings.autoIndent,
                onChanged: (value) => settings.setAutoIndent(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Auto Save Section
        _SectionHeader(title: 'Auto Save'),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.save_rounded),
                title: const Text('Auto Save'),
                subtitle: const Text('Automatically save files'),
                value: settings.autoSave,
                onChanged: (value) => settings.setAutoSave(value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Recent Files Section
        if (settings.recentFiles.isNotEmpty) ...[
          _SectionHeader(title: 'Recent Files'),
          Card(
            child: Column(
              children: [
                ...settings.recentFiles.take(5).map((path) => ListTile(
                      leading: const Icon(Icons.description_rounded),
                      title: Text(
                        path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        path,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      dense: true,
                    )),
                ListTile(
                  leading: Icon(Icons.clear_all_rounded, color: colorScheme.error),
                  title: Text('Clear Recent Files',
                      style: TextStyle(color: colorScheme.error)),
                  onTap: () => _showClearRecentFilesDialog(context, settings),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // About Section
        _SectionHeader(title: 'About'),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.info_rounded),
                title: const Text('EditorOne'),
                subtitle: const Text('Version 1.0.0'),
              ),
              const Divider(height: 1, indent: 56),
              const ListTile(
                leading: Icon(Icons.code_rounded),
                title: Text('Built with Flutter'),
                subtitle: Text('A lightweight code editor'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System default';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_getThemeModeText(mode)),
              value: mode,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  settings.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditorThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editor Theme'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: EditorThemes.availableThemes.length,
            itemBuilder: (context, index) {
              final theme = EditorThemes.availableThemes[index];
              return RadioListTile<String>(
                title: Text(theme),
                value: theme,
                groupValue: settings.editorTheme,
                onChanged: (value) {
                  if (value != null) {
                    settings.setEditorTheme(value);
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showFontDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: EditorFonts.availableFonts.map((font) {
            return RadioListTile<String>(
              title: Text(font, style: TextStyle(fontFamily: font)),
              value: font,
              groupValue: settings.fontFamily,
              onChanged: (value) {
                if (value != null) {
                  settings.setFontFamily(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showClearRecentFilesDialog(
      BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Files'),
        content: const Text(
            'Are you sure you want to clear the recent files list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settings.clearRecentFiles();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}
