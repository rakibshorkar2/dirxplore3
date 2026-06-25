import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

class DirectoryEntry {
  final String name;
  final String url;
  final bool isDirectory;
  final String? size;
  final String? lastModified;

  DirectoryEntry({
    required this.name,
    required this.url,
    required this.isDirectory,
    this.size,
    this.lastModified,
  });

  @override
  String toString() => 'DirectoryEntry(name: $name, isDirectory: $isDirectory)';
}

class DirectoryCrawler {
  Future<List<DirectoryEntry>> fetchDirectory(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to load directory: ${response.statusCode}');
    }

    final document = parse(response.body);
    final List<DirectoryEntry> entries = [];

    // Common selectors for Apache/Nginx directory listings
    final rows = document.querySelectorAll('tr');
    if (rows.isNotEmpty) {
      // Typically skip the first row (header)
      for (var i = 1; i < rows.length; i++) {
        final entry = _parseRow(rows[i], url);
        if (entry != null) entries.add(entry);
      }
    } else {
      // Fallback for simple lists (e.g. <ul> or <pre>)
      final links = document.querySelectorAll('a');
      for (final link in links) {
        final entry = _parseLink(link, url);
        if (entry != null) entries.add(entry);
      }
    }

    return entries;
  }

  DirectoryEntry? _parseRow(Element row, String baseUrl) {
    final columns = row.querySelectorAll('td');
    if (columns.length < 2) return null;

    final link = columns[1].querySelector('a');
    if (link == null) return null;

    final name = link.text.trim();
    if (name == 'Parent Directory' || name == '..') return null;

    final href = link.attributes['href'];
    if (href == null) return null;

    final fullUrl = _resolveUrl(baseUrl, href);
    final isDirectory = href.endsWith('/');
    
    String? size;
    String? lastModified;

    if (columns.length >= 4) {
      lastModified = columns[2].text.trim();
      size = columns[3].text.trim();
    }

    return DirectoryEntry(
      name: isDirectory ? name.replaceAll('/', '') : name,
      url: fullUrl,
      isDirectory: isDirectory,
      size: size,
      lastModified: lastModified,
    );
  }

  DirectoryEntry? _parseLink(Element link, String baseUrl) {
    final name = link.text.trim();
    if (name == 'Parent Directory' || name == '..' || name.isEmpty) return null;

    final href = link.attributes['href'];
    if (href == null || href.startsWith('?')) return null;

    final fullUrl = _resolveUrl(baseUrl, href);
    final isDirectory = href.endsWith('/');

    return DirectoryEntry(
      name: isDirectory ? name.replaceAll('/', '') : name,
      url: fullUrl,
      isDirectory: isDirectory,
    );
  }

  String _resolveUrl(String baseUrl, String href) {
    if (href.startsWith('http')) return href;
    final baseUri = Uri.parse(baseUrl);
    return baseUri.resolve(href).toString();
  }

  Future<List<DirectoryEntry>> deepScan(String baseUrl, {int maxDepth = 3}) async {
    final List<DirectoryEntry> allFiles = [];
    final List<String> queue = [baseUrl];
    final Set<String> visited = {baseUrl};
    int currentDepth = 0;

    while (queue.isNotEmpty && currentDepth < maxDepth) {
      final int levelSize = queue.length;
      for (int i = 0; i < levelSize; i++) {
        final currentUrl = queue.removeAt(0);
        try {
          final entries = await fetchDirectory(currentUrl);
          for (final entry in entries) {
            if (entry.isDirectory) {
              if (!visited.contains(entry.url)) {
                visited.add(entry.url);
                queue.add(entry.url);
              }
            } else {
              allFiles.add(entry);
            }
          }
        } catch (e) {
          // Skip failing directories
        }
      }
      currentDepth++;
    }
    return allFiles;
  }
}
