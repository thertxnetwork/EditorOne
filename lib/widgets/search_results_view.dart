import 'package:flutter/material.dart';
import '../models/search_result.dart';

/// Widget for displaying search results
class SearchResultsView extends StatelessWidget {
  final List<FileSearchResults> results;
  final Function(SearchResult) onResultTap;
  final bool isSearching;
  final int totalMatches;

  const SearchResultsView({
    super.key,
    required this.results,
    required this.onResultTap,
    this.isSearching = false,
    this.totalMatches = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isSearching && results.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Text(
                '$totalMatches results in ${results.length} files',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (isSearching) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final fileResult = results[index];
              return _FileResultItem(
                fileResult: fileResult,
                onResultTap: onResultTap,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FileResultItem extends StatefulWidget {
  final FileSearchResults fileResult;
  final Function(SearchResult) onResultTap;

  const _FileResultItem({
    required this.fileResult,
    required this.onResultTap,
  });

  @override
  State<_FileResultItem> createState() => _FileResultItemState();
}

class _FileResultItemState extends State<_FileResultItem> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_right_rounded,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.description_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.fileResult.fileName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.fileResult.totalMatches}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded && widget.fileResult.results.isNotEmpty)
          ...widget.fileResult.results.map((result) => _SearchResultLine(
                result: result,
                onTap: () => widget.onResultTap(result),
              )),
      ],
    );
  }
}

class _SearchResultLine extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultLine({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 24),
            SizedBox(
              width: 40,
              child: Text(
                '${result.lineNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: _buildHighlightedText(result, colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _buildHighlightedText(SearchResult result, ColorScheme colorScheme) {
    final line = result.lineContent;
    final start = result.matchStart;
    final end = result.matchEnd;

    return TextSpan(
      style: TextStyle(
        fontSize: 12,
        fontFamily: 'monospace',
        color: colorScheme.onSurface,
      ),
      children: [
        TextSpan(text: line.substring(0, start)),
        TextSpan(
          text: line.substring(start, end),
          style: TextStyle(
            backgroundColor: colorScheme.primaryContainer,
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextSpan(text: line.substring(end)),
      ],
    );
  }
}
