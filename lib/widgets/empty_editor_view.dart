import 'package:flutter/material.dart';

/// Empty state widget for when no file is open
class EmptyEditorView extends StatelessWidget {
  final VoidCallback? onOpenFile;
  final VoidCallback? onOpenFolder;
  final VoidCallback? onNewFile;

  const EmptyEditorView({
    super.key,
    this.onOpenFile,
    this.onOpenFolder,
    this.onNewFile,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code_rounded,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'EditorOne',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A lightweight code editor',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              if (onNewFile != null)
                _ActionButton(
                  icon: Icons.add_rounded,
                  label: 'New File',
                  onPressed: onNewFile!,
                ),
              if (onOpenFile != null)
                _ActionButton(
                  icon: Icons.file_open_rounded,
                  label: 'Open File',
                  onPressed: onOpenFile!,
                ),
              if (onOpenFolder != null)
                _ActionButton(
                  icon: Icons.folder_open_rounded,
                  label: 'Open Folder',
                  onPressed: onOpenFolder!,
                ),
            ],
          ),
          const SizedBox(height: 48),
          _KeyboardShortcuts(),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _KeyboardShortcuts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          _ShortcutItem(
            shortcut: 'Swipe from left',
            description: 'Open file explorer',
          ),
          _ShortcutItem(
            shortcut: 'Long press tab',
            description: 'Close file',
          ),
          _ShortcutItem(
            shortcut: 'Search icon',
            description: 'Find in project',
          ),
        ],
      ),
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final String shortcut;
  final String description;

  const _ShortcutItem({
    required this.shortcut,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Text(
              shortcut,
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
