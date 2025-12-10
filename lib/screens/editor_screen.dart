import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
import '../services/file_service.dart';
import 'file_explorer_drawer.dart';
import 'settings_screen.dart';
import 'search_screen.dart';

/// Main editor screen
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FileService _fileService = FileService();
  CodeLineEditingController? _codeController;

  @override
  void initState() {
    super.initState();
    _initCodeController();
  }

  void _initCodeController() {
    _codeController = CodeLineEditingController();
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editorProvider = context.watch<EditorProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    
    // Update controller content when active file changes
    if (editorProvider.activeFile != null && 
        _codeController?.text != editorProvider.activeFile!.content) {
      _codeController?.text = editorProvider.activeFile!.content;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'File explorer',
        ),
        title: Text(
          editorProvider.activeFile?.name ?? 'EditorOne',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          if (editorProvider.activeFile != null) ...[
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: _showSearch,
              tooltip: 'Search',
            ),
            IconButton(
              icon: Icon(
                editorProvider.activeFile!.isModified
                    ? Icons.save_rounded
                    : Icons.save_outlined,
              ),
              onPressed: editorProvider.activeFile!.isModified
                  ? _saveCurrentFile
                  : null,
              tooltip: 'Save',
            ),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_file',
                child: ListTile(
                  leading: Icon(Icons.add_rounded),
                  title: Text('New File'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'open_file',
                child: ListTile(
                  leading: Icon(Icons.file_open_rounded),
                  title: Text('Open File'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'open_folder',
                child: ListTile(
                  leading: Icon(Icons.folder_open_rounded),
                  title: Text('Open Folder'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              if (editorProvider.activeFile != null) ...[
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'save_as',
                  child: ListTile(
                    leading: Icon(Icons.save_as_rounded),
                    title: Text('Save As'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                if (editorProvider.hasUnsavedChanges)
                  const PopupMenuItem(
                    value: 'save_all',
                    child: ListTile(
                      leading: Icon(Icons.save_alt_rounded),
                      title: Text('Save All'),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ),
                const PopupMenuItem(
                  value: 'close_file',
                  child: ListTile(
                    leading: Icon(Icons.close_rounded),
                    title: Text('Close File'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_rounded),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const FileExplorerDrawer(),
      body: Column(
        children: [
          // Tab bar for open files
          if (editorProvider.openFiles.isNotEmpty)
            EditorTabBar(
              files: editorProvider.openFiles,
              activeIndex: editorProvider.activeIndex,
              onTabSelected: (index) => editorProvider.setActiveIndex(index),
              onTabClosed: (index) => _closeFile(index),
            ),
          // Editor content
          Expanded(
            child: editorProvider.activeFile == null
                ? EmptyEditorView(
                    onNewFile: () => editorProvider.createNewFile(),
                    onOpenFile: _openFile,
                    onOpenFolder: _openFolder,
                  )
                : _buildCodeEditor(settingsProvider, colorScheme),
          ),
        ],
      ),
      // Status bar
      bottomNavigationBar: editorProvider.activeFile != null
          ? _buildStatusBar(editorProvider, settingsProvider)
          : null,
    );
  }

  Widget _buildCodeEditor(SettingsProvider settings, ColorScheme colorScheme) {
    final editorProvider = context.read<EditorProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CodeEditor(
      controller: _codeController!,
      style: CodeEditorStyle(
        fontSize: settings.fontSize,
        fontFamily: settings.fontFamily,
        codeTheme: CodeHighlightTheme(
          languages: {},
          theme: isDark ? _getDarkTheme() : _getLightTheme(),
        ),
      ),
      wordWrap: settings.wordWrap,
      showLineNumbers: settings.showLineNumbers,
      onChanged: (code) {
        editorProvider.updateContent(code);
      },
    );
  }

  Map<String, TextStyle> _getDarkTheme() {
    return {
      'root': const TextStyle(backgroundColor: Color(0xFF1E1E1E), color: Color(0xFFD4D4D4)),
      'keyword': const TextStyle(color: Color(0xFF569CD6)),
      'built_in': const TextStyle(color: Color(0xFF4EC9B0)),
      'type': const TextStyle(color: Color(0xFF4EC9B0)),
      'literal': const TextStyle(color: Color(0xFF569CD6)),
      'number': const TextStyle(color: Color(0xFFB5CEA8)),
      'regexp': const TextStyle(color: Color(0xFFD16969)),
      'string': const TextStyle(color: Color(0xFFCE9178)),
      'subst': const TextStyle(color: Color(0xFFD4D4D4)),
      'symbol': const TextStyle(color: Color(0xFFB5CEA8)),
      'class': const TextStyle(color: Color(0xFF4EC9B0)),
      'function': const TextStyle(color: Color(0xFFDCDCAA)),
      'title': const TextStyle(color: Color(0xFFDCDCAA)),
      'params': const TextStyle(color: Color(0xFFD4D4D4)),
      'comment': const TextStyle(color: Color(0xFF6A9955)),
      'doctag': const TextStyle(color: Color(0xFF608B4E)),
      'meta': const TextStyle(color: Color(0xFF9B9B9B)),
      'meta-keyword': const TextStyle(color: Color(0xFF569CD6)),
      'meta-string': const TextStyle(color: Color(0xFFCE9178)),
      'section': const TextStyle(color: Color(0xFFDCDCAA)),
      'tag': const TextStyle(color: Color(0xFF569CD6)),
      'name': const TextStyle(color: Color(0xFF4EC9B0)),
      'attr': const TextStyle(color: Color(0xFF9CDCFE)),
      'attribute': const TextStyle(color: Color(0xFF9CDCFE)),
      'variable': const TextStyle(color: Color(0xFF9CDCFE)),
      'bullet': const TextStyle(color: Color(0xFFD7BA7D)),
      'code': const TextStyle(color: Color(0xFFCE9178)),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
      'formula': const TextStyle(color: Color(0xFFD4D4D4)),
      'link': const TextStyle(color: Color(0xFF569CD6)),
      'quote': const TextStyle(color: Color(0xFF6A9955)),
      'selector-tag': const TextStyle(color: Color(0xFFD7BA7D)),
      'selector-id': const TextStyle(color: Color(0xFF569CD6)),
      'selector-class': const TextStyle(color: Color(0xFFD7BA7D)),
      'selector-attr': const TextStyle(color: Color(0xFF9CDCFE)),
      'selector-pseudo': const TextStyle(color: Color(0xFFD7BA7D)),
      'template-tag': const TextStyle(color: Color(0xFF569CD6)),
      'template-variable': const TextStyle(color: Color(0xFF9CDCFE)),
      'addition': const TextStyle(color: Color(0xFF4EC9B0)),
      'deletion': const TextStyle(color: Color(0xFFD16969)),
    };
  }

  Map<String, TextStyle> _getLightTheme() {
    return {
      'root': const TextStyle(backgroundColor: Color(0xFFFFFFFF), color: Color(0xFF000000)),
      'keyword': const TextStyle(color: Color(0xFF0000FF)),
      'built_in': const TextStyle(color: Color(0xFF267F99)),
      'type': const TextStyle(color: Color(0xFF267F99)),
      'literal': const TextStyle(color: Color(0xFF0000FF)),
      'number': const TextStyle(color: Color(0xFF098658)),
      'regexp': const TextStyle(color: Color(0xFF811F3F)),
      'string': const TextStyle(color: Color(0xFFA31515)),
      'subst': const TextStyle(color: Color(0xFF000000)),
      'symbol': const TextStyle(color: Color(0xFF098658)),
      'class': const TextStyle(color: Color(0xFF267F99)),
      'function': const TextStyle(color: Color(0xFF795E26)),
      'title': const TextStyle(color: Color(0xFF795E26)),
      'params': const TextStyle(color: Color(0xFF000000)),
      'comment': const TextStyle(color: Color(0xFF008000)),
      'doctag': const TextStyle(color: Color(0xFF008000)),
      'meta': const TextStyle(color: Color(0xFF808080)),
      'meta-keyword': const TextStyle(color: Color(0xFF0000FF)),
      'meta-string': const TextStyle(color: Color(0xFFA31515)),
      'section': const TextStyle(color: Color(0xFF795E26)),
      'tag': const TextStyle(color: Color(0xFF800000)),
      'name': const TextStyle(color: Color(0xFF800000)),
      'attr': const TextStyle(color: Color(0xFFFF0000)),
      'attribute': const TextStyle(color: Color(0xFFFF0000)),
      'variable': const TextStyle(color: Color(0xFF001080)),
      'bullet': const TextStyle(color: Color(0xFF098658)),
      'code': const TextStyle(color: Color(0xFFA31515)),
      'emphasis': const TextStyle(fontStyle: FontStyle.italic),
      'strong': const TextStyle(fontWeight: FontWeight.bold),
      'formula': const TextStyle(color: Color(0xFF000000)),
      'link': const TextStyle(color: Color(0xFF0000FF)),
      'quote': const TextStyle(color: Color(0xFF008000)),
      'selector-tag': const TextStyle(color: Color(0xFF800000)),
      'selector-id': const TextStyle(color: Color(0xFF0000FF)),
      'selector-class': const TextStyle(color: Color(0xFF800000)),
      'selector-attr': const TextStyle(color: Color(0xFFFF0000)),
      'selector-pseudo': const TextStyle(color: Color(0xFF800000)),
      'template-tag': const TextStyle(color: Color(0xFF0000FF)),
      'template-variable': const TextStyle(color: Color(0xFF001080)),
      'addition': const TextStyle(color: Color(0xFF267F99)),
      'deletion': const TextStyle(color: Color(0xFF811F3F)),
    };
  }

  Widget _buildStatusBar(EditorProvider editor, SettingsProvider settings) {
    final colorScheme = Theme.of(context).colorScheme;
    final file = editor.activeFile;
    
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            file?.language?.toUpperCase() ?? 'TEXT',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            'Tab: ${settings.tabSize}',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            settings.useSpacesForTab ? 'Spaces' : 'Tabs',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'UTF-8',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    final editorProvider = context.read<EditorProvider>();
    
    switch (action) {
      case 'new_file':
        editorProvider.createNewFile();
        break;
      case 'open_file':
        _openFile();
        break;
      case 'open_folder':
        _openFolder();
        break;
      case 'save_as':
        _saveAs();
        break;
      case 'save_all':
        editorProvider.saveAllFiles();
        _showSnackBar('All files saved');
        break;
      case 'close_file':
        _closeFile(editorProvider.activeIndex);
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
    }
  }

  Future<void> _openFile() async {
    final path = await _fileService.pickFile();
    if (path != null && mounted) {
      final success = await context.read<EditorProvider>().openFile(path);
      if (success) {
        await context.read<SettingsProvider>().addRecentFile(path);
      } else {
        _showSnackBar('Failed to open file');
      }
    }
  }

  Future<void> _openFolder() async {
    final path = await _fileService.pickDirectory();
    if (path != null && mounted) {
      await context.read<FileExplorerProvider>().openDirectory(path);
      await context.read<SettingsProvider>().setLastOpenedPath(path);
      _scaffoldKey.currentState?.openDrawer();
    }
  }

  Future<void> _saveCurrentFile() async {
    final editorProvider = context.read<EditorProvider>();
    
    if (editorProvider.activeFile?.path.isEmpty ?? true) {
      await _saveAs();
    } else {
      final success = await editorProvider.saveCurrentFile();
      if (mounted) {
        _showSnackBar(success ? 'File saved' : 'Failed to save file');
      }
    }
  }

  Future<void> _saveAs() async {
    final path = await _fileService.pickDirectory();
    if (path == null || !mounted) return;
    
    final name = await _showNameDialog('Save As', 'Enter file name');
    if (name == null || name.isEmpty || !mounted) return;
    
    final fullPath = _fileService.joinPaths(path, name);
    final success = await context.read<EditorProvider>().saveFileAs(fullPath);
    
    if (mounted) {
      _showSnackBar(success ? 'File saved' : 'Failed to save file');
    }
  }

  Future<void> _closeFile(int index) async {
    final editorProvider = context.read<EditorProvider>();
    final file = editorProvider.openFiles[index];
    
    if (file.isModified) {
      final shouldSave = await _showSaveDialog(file.name);
      if (shouldSave == null) return; // Cancelled
      
      if (shouldSave && mounted) {
        if (file.path.isEmpty) {
          // Need to save as first
          final path = await _fileService.pickDirectory();
          if (path == null || !mounted) return;
          
          final name = await _showNameDialog('Save As', 'Enter file name');
          if (name == null || name.isEmpty || !mounted) return;
          
          final fullPath = _fileService.joinPaths(path, name);
          await editorProvider.saveFileAs(fullPath);
        } else {
          await editorProvider.saveCurrentFile();
        }
      }
    }
    
    if (mounted) {
      await editorProvider.closeFile(index);
    }
  }

  Future<bool?> _showSaveDialog(String fileName) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: Text('Do you want to save changes to "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Don't Save"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog(String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
