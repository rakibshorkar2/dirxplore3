import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../logic/file_operations.dart';
import 'video_player_screen.dart';

class FilesTab extends StatefulWidget {
  const FilesTab({super.key});

  @override
  State<FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<FilesTab> {
  List<FileSystemEntity> _files = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    setState(() {
      final allFiles = dir.listSync();
      if (_selectedCategory == 'All') {
        _files = allFiles;
      } else {
        _files = allFiles.where((f) => FileOperations.getCategory(f.path) == _selectedCategory).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Files'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.refresh),
          onPressed: _loadFiles,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: ['All', 'Videos', 'Audio', 'Documents', 'Archives', 'Other'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 32),
                      color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () {
                        setState(() => _selectedCategory = cat);
                        _loadFiles();
                      },
                      child: Text(cat, style: TextStyle(color: isSelected ? CupertinoColors.white : CupertinoColors.label, fontSize: 13)),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: _files.isEmpty
                  ? const Center(child: Text('No files found'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        final name = file.path.split('/').last;
                        final category = FileOperations.getCategory(file.path);
                        
                        return CupertinoListTile(
                          leading: Icon(_getIconForCategory(category)),
                          title: Text(name),
                          trailing: const Icon(CupertinoIcons.ellipsis_vertical),
                          onTap: () => _handleFileTap(file, category),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Videos': return CupertinoIcons.video_camera;
      case 'Audio': return CupertinoIcons.music_note;
      case 'Documents': return CupertinoIcons.doc_text;
      case 'Archives': return CupertinoIcons.archivebox;
      default: return CupertinoIcons.doc;
    }
  }

  void _handleFileTap(FileSystemEntity file, String category) {
    if (category == 'Videos') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => VideoPlayerScreen(path: file.path)));
    } else if (category == 'Archives') {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Archive Actions'),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Extract Here'),
              onPressed: () async {
                Navigator.pop(context);
                await FileOperations.extractArchive(file.path);
                _loadFiles();
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    } else {
      OpenFilex.open(file.path);
    }
  }
}
