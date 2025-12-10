import 'package:flutter/material.dart';
import '../models/file_item.dart';
import '../utils/helpers.dart';

/// A widget that displays the file tree structure
class FileTreeView extends StatelessWidget {
  final List<FileItem> items;
  final Function(FileItem) onItemTap;
  final Function(FileItem)? onItemLongPress;
  final Function(FileItem)? onExpand;
  final Function(String)? getChildren;
  final Function(String)? isExpanded;
  final String? selectedPath;
  final int depth;

  const FileTreeView({
    super.key,
    required this.items,
    required this.onItemTap,
    this.onItemLongPress,
    this.onExpand,
    this.getChildren,
    this.isExpanded,
    this.selectedPath,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: depth > 0,
      physics: depth > 0 ? const NeverScrollableScrollPhysics() : null,
      padding: depth == 0 ? const EdgeInsets.symmetric(vertical: 8) : EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _FileTreeItem(
          item: item,
          onTap: () => onItemTap(item),
          onLongPress: onItemLongPress != null ? () => onItemLongPress!(item) : null,
          onExpand: onExpand != null ? () => onExpand!(item) : null,
          children: getChildren?.call(item.path),
          isExpanded: isExpanded?.call(item.path) ?? false,
          isSelected: selectedPath == item.path,
          depth: depth,
          getChildren: getChildren,
          isExpandedCheck: isExpanded,
          onItemTap: onItemTap,
          onItemLongPress: onItemLongPress,
          onExpandChild: onExpand,
        );
      },
    );
  }
}

class _FileTreeItem extends StatelessWidget {
  final FileItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onExpand;
  final List<FileItem>? children;
  final bool isExpanded;
  final bool isSelected;
  final int depth;
  final Function(String)? getChildren;
  final Function(String)? isExpandedCheck;
  final Function(FileItem) onItemTap;
  final Function(FileItem)? onItemLongPress;
  final Function(FileItem)? onExpandChild;

  const _FileTreeItem({
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.onExpand,
    this.children,
    required this.isExpanded,
    required this.isSelected,
    required this.depth,
    this.getChildren,
    this.isExpandedCheck,
    required this.onItemTap,
    this.onItemLongPress,
    this.onExpandChild,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: item.isDirectory ? onExpand : onTap,
          onLongPress: onLongPress,
          child: Container(
            padding: EdgeInsets.only(
              left: 8 + (depth * 16),
              right: 8,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer.withOpacity(0.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (item.isDirectory)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 4),
                _getIcon(colorScheme),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && children != null && children!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              children: children!.map((child) {
                return _FileTreeItem(
                  item: child,
                  onTap: () => onItemTap(child),
                  onLongPress: onItemLongPress != null
                      ? () => onItemLongPress!(child)
                      : null,
                  onExpand: onExpandChild != null
                      ? () => onExpandChild!(child)
                      : null,
                  children: getChildren?.call(child.path),
                  isExpanded: isExpandedCheck?.call(child.path) ?? false,
                  isSelected: false,
                  depth: depth + 1,
                  getChildren: getChildren,
                  isExpandedCheck: isExpandedCheck,
                  onItemTap: onItemTap,
                  onItemLongPress: onItemLongPress,
                  onExpandChild: onExpandChild,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _getIcon(ColorScheme colorScheme) {
    if (item.isDirectory) {
      return Icon(
        isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
        size: 20,
        color: colorScheme.primary,
      );
    }

    final icon = getFileIconForExtension(item.extension);
    return Text(icon, style: const TextStyle(fontSize: 16));
  }
}
