import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/file_item.dart';
import '../models/editor_file.dart';
import '../utils/language_detector.dart';

/// Service for file system operations
class FileService {
  /// Pick a directory
  Future<String?> pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }

  /// Pick a file
  Future<String?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    return result?.files.single.path;
  }

  /// Pick multiple files
  Future<List<String>?> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    return result?.files.map((f) => f.path!).toList();
  }

  /// Read file contents
  Future<EditorFile?> readFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;
      
      final content = await file.readAsString();
      final name = path.basename(filePath);
      final language = LanguageDetector.detectLanguage(filePath);
      
      return EditorFile(
        path: filePath,
        name: name,
        content: content,
        language: language,
      );
    } catch (e) {
      // File might be binary or unreadable
      return null;
    }
  }

  /// Write file contents
  Future<bool> writeFile(String filePath, String content) async {
    try {
      final file = File(filePath);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new file
  Future<bool> createFile(String filePath, [String content = '']) async {
    try {
      final file = File(filePath);
      if (await file.exists()) return false;
      
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      
      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a new directory
  Future<bool> createDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) return false;
      await dir.create(recursive: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a file or directory
  Future<bool> delete(String itemPath) async {
    try {
      final type = await FileSystemEntity.type(itemPath);
      if (type == FileSystemEntityType.directory) {
        await Directory(itemPath).delete(recursive: true);
      } else if (type == FileSystemEntityType.file) {
        await File(itemPath).delete();
      } else {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Rename a file or directory
  Future<bool> rename(String oldPath, String newPath) async {
    try {
      final type = await FileSystemEntity.type(oldPath);
      if (type == FileSystemEntityType.directory) {
        await Directory(oldPath).rename(newPath);
      } else if (type == FileSystemEntityType.file) {
        await File(oldPath).rename(newPath);
      } else {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// List directory contents
  Future<List<FileItem>> listDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return [];
      
      final entities = await dir.list().toList();
      final items = <FileItem>[];
      
      for (final entity in entities) {
        final name = path.basename(entity.path);
        // Skip hidden files
        if (name.startsWith('.')) continue;
        
        final stat = await entity.stat();
        final isDirectory = entity is Directory;
        
        items.add(FileItem(
          path: entity.path,
          name: name,
          isDirectory: isDirectory,
          size: stat.size,
          lastModified: stat.modified,
        ));
      }
      
      // Sort: directories first, then files, alphabetically
      items.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
      
      return items;
    } catch (e) {
      return [];
    }
  }

  /// Get file/directory info
  Future<FileItem?> getItemInfo(String itemPath) async {
    try {
      final type = await FileSystemEntity.type(itemPath);
      if (type == FileSystemEntityType.notFound) return null;
      
      final stat = await FileStat.stat(itemPath);
      final name = path.basename(itemPath);
      final isDirectory = type == FileSystemEntityType.directory;
      
      return FileItem(
        path: itemPath,
        name: name,
        isDirectory: isDirectory,
        size: stat.size,
        lastModified: stat.modified,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if path exists
  Future<bool> exists(String itemPath) async {
    try {
      return await FileSystemEntity.type(itemPath) != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }

  /// Get parent directory
  String getParentPath(String itemPath) {
    return path.dirname(itemPath);
  }

  /// Join paths
  String joinPaths(String parent, String child) {
    return path.join(parent, child);
  }

  /// Get file name from path
  String getFileName(String filePath) {
    return path.basename(filePath);
  }

  /// Get file extension
  String getExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceFirst('.', '');
  }
}
