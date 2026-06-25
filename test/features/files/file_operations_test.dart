import 'package:flutter_test/flutter_test.dart';
import 'package:dirxplore3/src/features/files/logic/file_operations.dart';

void main() {
  group('FileOperations Category Tests', () {
    test('Should categorize mp4 as Videos', () {
      expect(FileOperations.getCategory('movie.mp4'), equals('Videos'));
    });

    test('Should categorize zip as Archives', () {
      expect(FileOperations.getCategory('data.zip'), equals('Archives'));
    });

    test('Should categorize pdf as Documents', () {
      expect(FileOperations.getCategory('book.pdf'), equals('Documents'));
    });

    test('Should categorize mp3 as Audio', () {
      expect(FileOperations.getCategory('song.mp3'), equals('Audio'));
    });

    test('Should categorize unknown extension as Other', () {
      expect(FileOperations.getCategory('random.xyz'), equals('Other'));
    });
  });
}
