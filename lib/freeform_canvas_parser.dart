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
  /// **ZH** 检查 JSON 字符串是否为有效的 .excalidraw 文件
  /// 
  /// **EN** Check if the JSON string is a valid .excalidraw file
  static bool isValidExcalidraw(String jsonString){
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      FreeformCanvasFile.fromJson(json);
    } catch (e) {
      return false;
    }
    return true;
  }

  /// **ZH** 从文件解析 .excalidraw 文件
  /// 
  /// **EN** Parse .excalidraw file from file
  static Future<FreeformCanvasFile> parseFromFile(File file) async {
    final content = await file.readAsString();
    return parseFromString(content);
  }
}