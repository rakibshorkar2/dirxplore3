import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

class FileOperations {
  static String getCategory(String path) {
    final ext = p.extension(path).toLowerCase();
    if (['.mp4', '.mkv', '.mov', '.avi'].contains(ext)) return 'Videos';
    if (['.mp3', '.wav', '.flac', '.m4a'].contains(ext)) return 'Audio';
    if (['.pdf', '.doc', '.docx', '.txt'].contains(ext)) return 'Documents';
    if (['.zip', '.rar', '.7z', '.tar', '.gz'].contains(ext)) return 'Archives';
    return 'Other';
  }

  static Future<void> extractArchive(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final destinationDir = p.withoutExtension(filePath);
    
    for (final file in archive) {
      if (file.isFile) {
        final data = file.content as List<int>;
        final outFile = File('$destinationDir/${file.name}');
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory('$destinationDir/${file.name}').create(recursive: true);
      }
    }
  }
}
