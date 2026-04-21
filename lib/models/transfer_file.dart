class TransferFile {
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final DateTime addedAt;
  
  TransferFile({
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
  
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'size': size,
      'mimeType': mimeType,
      'addedAt': addedAt.toIso8601String(),
    };
  }
  
  factory TransferFile.fromJson(Map<String, dynamic> json) {
    return TransferFile(
      name: json['name'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}