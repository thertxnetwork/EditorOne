import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../widgets/search_results_view.dart';

/// Search screen for searching in files
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    
    // Initialize with existing query
    final searchProvider = context.read<SearchProvider>();
    _searchController.text = searchProvider.query;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();
    final fileExplorer = context.watch<FileExplorerProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search in files...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          searchProvider.clearResults();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                searchProvider.setQuery(value);
              },
              onSubmitted: (_) => _performSearch(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.text_fields_rounded,
              color: searchProvider.caseSensitive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Case sensitive',
            onPressed: () => searchProvider.toggleCaseSensitive(),
          ),
          IconButton(
            icon: Icon(
              Icons.code_rounded,
              color: searchProvider.useRegex
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Use regex',
            onPressed: () => searchProvider.toggleRegex(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                // Search mode toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Content'),
                      icon: Icon(Icons.text_snippet_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('File name'),
                      icon: Icon(Icons.insert_drive_file_rounded, size: 18),
                    ),
                  ],
                  selected: {searchProvider.searchInFiles},
                  onSelectionChanged: (selected) {
                    searchProvider.setOptions(searchInFiles: selected.first);
                  },
                ),
                const Spacer(),
                // Search button
                FilledButton.icon(
                  onPressed: fileExplorer.hasDirectory ? _performSearch : null,
                  icon: searchProvider.isSearching
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.search_rounded, size: 18),
                  label: Text(searchProvider.isSearching ? 'Searching...' : 'Search'),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: !fileExplorer.hasDirectory
                ? _buildNoFolderState(colorScheme)
                : SearchResultsView(
                    results: searchProvider.results,
                    isSearching: searchProvider.isSearching,
                    totalMatches: searchProvider.totalMatches,
                    onResultTap: (result) => _openResult(result),
                  ),
          ),
        ],
      ),
      floatingActionButton: searchProvider.isSearching
          ? FloatingActionButton.extended(
              onPressed: () => searchProvider.cancelSearch(),
              icon: const Icon(Icons.cancel_rounded),
              label: const Text('Cancel'),
            )
          : null,
    );
  }

  Widget _buildNoFolderState(ColorScheme colorScheme) {
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
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open a folder to search in files',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch() {
    final searchProvider = context.read<SearchProvider>();
    final fileExplorer = context.read<FileExplorerProvider>();
    
    if (!fileExplorer.hasDirectory) return;
    if (searchProvider.query.isEmpty) return;

    if (searchProvider.searchInFiles) {
      searchProvider.searchInFilesContent(
        fileExplorer.currentDirectory!,
        excludePatterns: ['node_modules', '.git', '.dart_tool', 'build'],
      );
    } else {
      searchProvider.searchFilesByName(fileExplorer.currentDirectory!);
    }
  }

  void _openResult(result) {
    final editorProvider = context.read<EditorProvider>();
    editorProvider.openFile(result.filePath);
    Navigator.pop(context);
  }
}
