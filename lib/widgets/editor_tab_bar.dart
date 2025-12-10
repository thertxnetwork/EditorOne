import 'package:flutter/material.dart';
import '../models/editor_file.dart';

/// Tab bar for open files in the editor
class EditorTabBar extends StatelessWidget {
  final List<EditorFile> files;
  final int activeIndex;
  final Function(int) onTabSelected;
  final Function(int) onTabClosed;

  const EditorTabBar({
    super.key,
    required this.files,
    required this.activeIndex,
    required this.onTabSelected,
    required this.onTabClosed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: files.length,
        padding: const EdgeInsets.only(left: 4),
        itemBuilder: (context, index) {
          final file = files[index];
          final isActive = index == activeIndex;
          
          return _EditorTab(
            file: file,
            isActive: isActive,
            onTap: () => onTabSelected(index),
            onClose: () => onTabClosed(index),
          );
        },
      ),
    );
  }
}

class _EditorTab extends StatelessWidget {
  final EditorFile file;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _EditorTab({
    required this.file,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 200,
        ),
        margin: const EdgeInsets.only(top: 4, bottom: 4, right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.surface
              : colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          border: isActive
              ? Border(
                  top: BorderSide(color: colorScheme.primary, width: 2),
                  left: BorderSide(color: colorScheme.outlineVariant),
                  right: BorderSide(color: colorScheme.outlineVariant),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file.isModified)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            Flexible(
              child: Text(
                file.name,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
