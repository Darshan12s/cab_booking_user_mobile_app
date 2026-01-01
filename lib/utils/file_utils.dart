// utils/file_utils.dart
/// Utility functions for file operations
class FileUtils {
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5 MB limit

  /// Format file size from bytes to human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file size is within allowed limit
  static bool isFileSizeValid(int bytes) {
    return bytes <= maxFileSizeInBytes;
  }

  /// Get max file size as formatted string
  static String getMaxFileSizeFormatted() {
    return formatFileSize(maxFileSizeInBytes);
  }

  /// Get max file size in MB as integer
  static int getMaxFileSizeInMB() {
    return (maxFileSizeInBytes / (1024 * 1024)).round();
  }
}
