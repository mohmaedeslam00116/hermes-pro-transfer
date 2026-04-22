/// File utilities for formatting file sizes, names, and paths
class FileUtils {
  /// Format bytes to human readable size string
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }

  /// Format transfer speed
  static String formatSpeed(double bytesPerSecond) {
    return '${formatFileSize(bytesPerSecond.toInt())}/s';
  }

  /// Get file extension from filename
  static String getExtension(String filename) {
    final dot = filename.lastIndexOf('.');
    if (dot == -1 || dot == filename.length - 1) return '';
    return filename.substring(dot + 1).toLowerCase();
  }

  /// Get file icon based on extension
  static String getFileIcon(String filename) {
    final ext = getExtension(filename);
    
    // Images
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'].contains(ext)) {
      return '🖼️';
    }
    // Videos
    if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
      return '🎬';
    }
    // Audio
    if (['mp3', 'wav', 'flac', 'aac', 'ogg'].contains(ext)) {
      return '🎵';
    }
    // Documents
    if (['pdf', 'doc', 'docx', 'txt', 'rtf'].contains(ext)) {
      return '📄';
    }
    // Spreadsheets
    if (['xls', 'xlsx', 'csv'].contains(ext)) {
      return '📊';
    }
    // Archives
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return '📦';
    }
    // Code
    if (['dart', 'js', 'ts', 'py', 'java', 'kt', 'swift'].contains(ext)) {
      return '💻';
    }
    
    return '📁';
  }

  /// Truncate filename for display
  static String truncateName(String filename, {int maxLength = 30}) {
    if (filename.length <= maxLength) return filename;
    
    final ext = getExtension(filename);
    final name = filename.substring(0, filename.length - ext.length - 1);
    
    return '${name.substring(0, maxLength - 3 - ext.length - 1)}...$ext';
  }

  /// Calculate estimated time remaining
  static String estimateTime(int remainingBytes, double speed) {
    if (speed <= 0) return '--:--';
    
    final seconds = (remainingBytes / speed).round();
    
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    
    final hours = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '$hours:${mins.toString().padLeft(2, '0')}h';
  }
}

/// Date/Time formatting utilities (renamed to avoid conflict with dart:ui DateUtils)
class HermesDateUtils {
  /// Format duration for display
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  /// Format timestamp to relative time
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inDays > 30) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  /// Format time for transfer display (MM:SS or HH:MM:SS)
  static String formatTransferTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Network utilities
class NetworkUtils {
  /// Validate IP address
  static bool isValidIpAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  /// Check if port is valid
  static bool isValidPort(int port) {
    return port > 0 && port < 65536;
  }

  /// Format IP and port for display
  static String formatAddress(String ip, int port) {
    return '$ip:$port';
  }
}

/// Validation utilities
class ValidationUtils {
  /// Validate filename
  static bool isValidFilename(String filename) {
    if (filename.isEmpty) return false;
    if (filename.contains('/') || filename.contains('\\')) return false;
    return true;
  }

  /// Check if string is valid URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Sanitize filename for safe storage
  static String sanitizeFilename(String filename) {
    // Remove invalid characters for cross-platform
    var sanitized = filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .trim();
    
    // Remove control characters (ASCII 0-31)
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F]'), '');
    
    // Limit length to 255 (max filename length on most filesystems)
    if (sanitized.length > 255) {
      final ext = FileUtils.getExtension(sanitized);
      if (ext.isNotEmpty) {
        final nameWithoutExt = sanitized.substring(0, sanitized.length - ext.length - 1);
        sanitized = '${nameWithoutExt.substring(0, 255 - ext.length - 1)}.$ext';
      } else {
        sanitized = sanitized.substring(0, 255);
      }
    }
    
    // Ensure filename is not empty after sanitization
    if (sanitized.isEmpty) {
      sanitized = 'unnamed_file';
    }
    
    return sanitized;
  }
}
