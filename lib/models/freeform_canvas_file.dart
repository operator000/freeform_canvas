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
  final Map<String, dynamic> files;

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
  final FreeformCanvasColor viewBackgroundColor;
  final int gridSize;
  final int gridStep;
  final bool gridModeEnabled;
  final Map<String, dynamic> lockedMultiSelections;

  FreeformCanvasAppState({
    required this.viewBackgroundColor,
    required this.gridSize,
    required this.gridStep,
    required this.gridModeEnabled,
    required this.lockedMultiSelections,
  });

  factory FreeformCanvasAppState.std(){
    return FreeformCanvasAppState(
      viewBackgroundColor: FreeformCanvasColor.fromString('#ffffff'),
      gridSize: 20,
      gridStep: 5,
      gridModeEnabled: false,
      lockedMultiSelections: {},
    );
  }

  factory FreeformCanvasAppState.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasAppState(
      viewBackgroundColor: json['viewBackgroundColor']==null
        ? FreeformCanvasColor.fromString('#ffffff') 
        : FreeformCanvasColor.fromString(json['viewBackgroundColor'] as String),
      gridSize: json['gridSize'] as int,
      gridStep: json['gridStep'] as int,
      gridModeEnabled: json['gridModeEnabled'] as bool,
      lockedMultiSelections:
          Map<String, dynamic>.from(json['lockedMultiSelections'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'viewBackgroundColor': viewBackgroundColor.colorStr,
      'gridSize': gridSize,
      'gridStep': gridStep,
      'gridModeEnabled': gridModeEnabled,
      'lockedMultiSelections': lockedMultiSelections,
    };
  }
}