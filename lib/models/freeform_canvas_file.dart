import 'dart:ui';

import 'freeform_canvas_element.dart';

/// FreeformCanvas 文件顶层结构
///
/// 对应 JSON 中的顶层对象，包含文件元数据和元素列表
class FreeformCanvasFile {
  final String type;
  final int version;
  final String? source;
  final List<FreeformCanvasElement> elements;
  final FreeformCanvasAppState appState;
  final Map<String, dynamic> files; // 方案B忽略，但保留字段

  FreeformCanvasFile({
    required this.type,
    required this.version,
    this.source,
    required this.elements,
    required this.appState,
    required this.files,
  });

  factory FreeformCanvasFile.fromJson(Map<String, dynamic> json) {
    // 过滤掉已删除的元素
    final elementsJson = json['elements'] as List<dynamic>? ?? [];
    final elements = elementsJson
        .where((element) => (element['isDeleted'] as bool?) != true)
        .map((element) => FreeformCanvasElement.fromJson(element))
        .toList();

    return FreeformCanvasFile(
      type: json['type'] as String,
      version: json['version'] as int,
      source: json['source'] as String?,
      elements: elements,
      appState: FreeformCanvasAppState.fromJson(
        json['appState'] as Map<String, dynamic>? ?? {},
      ),
      files: Map<String, dynamic>.from(json['files'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'version': version,
      'source': source,
      'elements': elements.map((e) => e.toJson()).toList(),
      'appState': appState.toJson(),
      'files': files,
    };
  }

  @override
  String toString() => 'FreeformCanvasFile(type: $type, version: $version, elements: ${elements.length})';
}

/// 画布级状态
///
/// 包含背景色、网格等全局设置
class FreeformCanvasAppState {
  final Color viewBackgroundColor;
  final int? gridSize;
  final int? gridStep;
  final bool? gridModeEnabled;
  final Map<String, dynamic> lockedMultiSelections;

  FreeformCanvasAppState({
    required this.viewBackgroundColor,
    this.gridSize,
    this.gridStep,
    this.gridModeEnabled,
    required this.lockedMultiSelections,
  });

  factory FreeformCanvasAppState.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasAppState(
      viewBackgroundColor: _parseColor(json['viewBackgroundColor'] as String?),
      gridSize: json['gridSize'] as int?,
      gridStep: json['gridStep'] as int?,
      gridModeEnabled: json['gridModeEnabled'] as bool?,
      lockedMultiSelections:
          Map<String, dynamic>.from(json['lockedMultiSelections'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewBackgroundColor': viewBackgroundColor,
      'gridSize': gridSize,
      'gridStep': gridStep,
      'gridModeEnabled': gridModeEnabled,
      'lockedMultiSelections': lockedMultiSelections,
    };
  }
}
/// 解析颜色字符串
Color _parseColor(String? colorStr) {
  if (colorStr==null || colorStr == 'transparent') {
    return Color(0x00ffffff);
  }

  // 移除 # 前缀
  String hex = colorStr.startsWith('#') ? colorStr.substring(1) : colorStr;

  // 处理 3 位简写格式
  if (hex.length == 3) {
    hex = hex.split('').map((c) => c * 2).join();
  }

  // 添加 alpha 通道（如果缺失）
  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  return Color(int.parse(hex, radix: 16));
}