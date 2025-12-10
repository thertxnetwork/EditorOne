import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/file_tree_view.dart';
import '../models/file_item.dart';
import '../services/file_service.dart';

/// Drawer widget for file explorer
class FileExplorerDrawer extends StatelessWidget {
  const FileExplorerDrawer({super.key});
  
  static final FileService _fileService = FileService();

  @override
  Widget build(BuildContext context) {
    final fileExplorer = context.watch<FileExplorerProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, fileExplorer),
            Expanded(
              child: fileExplorer.hasDirectory
                  ? _buildFileTree(context, fileExplorer)
                  : _buildEmptyState(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FileExplorerProvider fileExplorer) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_rounded,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileExplorer.hasDirectory
                      ? fileExplorer.currentDirectory!.split('/').last
                      : 'File Explorer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: fileExplorer.hasDirectory
                    ? () => fileExplorer.refresh()
                    : null,
                tooltip: 'Refresh',
              ),
            ],
          ),
          if (fileExplorer.hasDirectory) ...[
            const SizedBox(height: 8),
            Text(
              fileExplorer.currentDirectory!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileTree(
      BuildContext context, FileExplorerProvider fileExplorer) {
    if (fileExplorer.isLoading && fileExplorer.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        FileTreeView(
          items: fileExplorer.items,
          selectedPath: fileExplorer.selectedItem?.path,
          onItemTap: (item) => _handleItemTap(context, item),
          onItemLongPress: (item) => _showItemOptions(context, item),
          onExpand: (item) => fileExplorer.toggleDirectory(item),
          getChildren: (path) => fileExplorer.getChildren(path),
          isExpanded: (path) => fileExplorer.isExpanded(path),
        ),
        // Floating action buttons at bottom
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'new_file',
                onPressed: () => _showCreateFileDialog(context),
                child: const Icon(Icons.note_add_rounded),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'new_folder',
                onPressed: () => _showCreateFolderDialog(context),
                child: const Icon(Icons.create_new_folder_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No folder open',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _openFolder(context),
            icon: const Icon(Icons.folder_open_rounded),
            label: const Text('Open Folder'),
          ),
        ],
      ),
    );
  }

  Future<void> _openFolder(BuildContext context) async {
    final fileExplorer = context.read<FileExplorerProvider>();
    final settingsProvider = context.read<SettingsProvider>();

    final path = await _fileService.pickDirectory();
    if (path != null) {
      await fileExplorer.openDirectory(path);
      await settingsProvider.setLastOpenedPath(path);
    }
  }

  void _handleItemTap(BuildContext context, FileItem item) {
    final fileExplorer = context.read<FileExplorerProvider>();
    final editorProvider = context.read<EditorProvider>();

    fileExplorer.selectItem(item);

    if (!item.isDirectory && item.isEditable) {
      editorProvider.openFile(item.path);
      Navigator.pop(context); // Close drawer
    }
  }

  void _showItemOptions(BuildContext context, FileItem item) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    item.isDirectory
                        ? Icons.folder_rounded
                        : Icons.description_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (item.lastModified != null)
                          Text(
                            'Modified: ${_formatDate(item.lastModified!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, item);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: colorScheme.error),
              title: Text('Delete', style: TextStyle(color: colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, item);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateFileDialog(BuildContext context) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter file name',
            labelText: 'File name',
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && context.mounted) {
      final success =
          await context.read<FileExplorerProvider>().createFile(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'File created' : 'Failed to create file'),
          ),
        );
      }
    }
  }

  Future<void> _showCreateFolderDialog(BuildContext context) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter folder name',
            labelText: 'Folder name',
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && context.mounted) {
      final success =
          await context.read<FileExplorerProvider>().createDirectory(name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(success ? 'Folder created' : 'Failed to create folder'),
          ),
        );
      }
    }
  }

  Future<void> _showRenameDialog(BuildContext context, FileItem item) async {
    final controller = TextEditingController(text: item.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New name',
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != item.name) {
      if (context.mounted) {
        final success =
            await context.read<FileExplorerProvider>().renameItem(item, newName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Renamed' : 'Failed to rename'),
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, FileItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete "${item.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await context.read<FileExplorerProvider>().deleteItem(item);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Deleted' : 'Failed to delete'),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
