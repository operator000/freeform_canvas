import 'dart:convert';
import 'dart:io';

import 'models/freeform_canvas_file.dart';

class FreeformCanvasParser {
  /// **ZH** 从 JSON 字符串解析 .excalidraw 文件
  ///
  /// **EN** Parse .excalidraw file from JSON string
  static FreeformCanvasFile parseFromString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FreeformCanvasFile.fromJson(json);
    } catch (e) {
      throw FormatException('Failed to parse .excalidraw JSON: $e');
    }
  }

  /// **ZH** 从 JSON 文件解析 .excalidraw 文件
  /// 
  /// **EN** Parse .excalidraw file from JSON file
  static Future<FreeformCanvasFile> parseFromFile(String filePath) async {
    final content = await File(filePath).readAsString();
    return parseFromString(content);
  }
}