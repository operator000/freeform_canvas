import 'package:flutter/material.dart';


/// **ZH** 元素类型枚举，当前阶段支持的形状类型
/// 
/// **EN** Enumeration of element types, currently supported shape types
enum FreeformCanvasElementType {
  rectangle,
  ellipse,
  text,
  freedraw,
  line,
  arrow,
  diamond,
}
/// **ZH** 有路径点的 element，即 arrow、line、freedraw
/// 
/// **EN** Elements with path points, i.e. arrow, line, freedraw
abstract mixin class ElementWithPoints{
  List<FreeformCanvasPoint> get points;
}

/// **ZH** 所有 FreeformCanvas 元素的基类，包含所有元素共享的通用字段
/// 
///  **EN** The base class for all FreeformCanvas elements, containing common fields shared by all elements
abstract class FreeformCanvasElement {
  /// EN The unique identifier of the element, a 21-character string consisting of a combination 
  /// of letters, numbers, underscores, and hyphens, which can be generated using timestamps, random numbers, etc.
  final String id;

  /// Elelment type
  final FreeformCanvasElementType type;

  /// EN The field that determines the order of element creation, such as 'a0'<'zy'.
  /// It is only valid when inserting an element into a document, otherwise set it to '00'
  final String index;

  /// The position, for freedraw elements, x and y represent the coordinates of the first drawn point; 
  /// for other elements, x and y represent the top left vertex coordinates
  /// Important: For freedraw, x and y do not represent the top left vertex, they need to be calculated by traversing points.
  final double x;
  final double y;
  /// Size
  final double width;
  final double height;

  /// Rotation angle (radians)
  final double angle;

  /// The stroke color, the default is black, #1e1e1e
  final FreeformCanvasColor strokeColor;

  /// The fill color, the default is transparent
  final FreeformCanvasColor backgroundColor;

  /// The fill style, the value is solid (solid)、hachure (45° left and right parallel lines)、cross-hatch (45° cross lines)
  final String fillStyle;

  /// The stroke width, any real number, typical values are 1, 2, 4
  final double strokeWidth;

  /// The stroke style, the value is solid (solid)、dashed (dashed)、dotted (dotted)
  final String strokeStyle;

  /// The roughness of the drawing, 0 means smooth, the larger the value, the more rough, typical values are 0, 1, 2
  final double roughness;

  /// Opacity 0-100
  final double opacity;

  /// Whether the element is locked
  final bool locked;

  /// The group ID list, TODO: Current stage does not support group
  final List<String> groupIds;

  /// The frame ID, TODO: Current stage does not support frame
  final String? frameId;

  /// The bounded element, TODO: Current stage does not support binding
  final List<dynamic>? boundElements;

  /// Hyperlink, TODO: Current stage does not support hyperlink
  final String? link;

  /// Internal version field, TODO: Current stage does not support internal version
  final int? version;
  final int? versionNonce;

  /// Random seed, TODO: Current stage does not support random seed
  final int? seed;

  /// The roundness configuration, the value is:
  /// FreeformCanvasRoundness(type:3)(fixed roundness), FreeformCanvasRoundness(type:2)(variable roundness), null (rectangular)
  /// Only applicable to rectangles, lines, and diamonds,etc
  final FreeformCanvasRoundness? roundness;

  /// The timestamp of the last update
  final int? updated;

  ///EN Whether the element is deleted.Deleted element shouldn't be drawn.
  /// Currently, the deletion of elements in this project is done by directly removing them from the document, rather than using this field.
  final bool isDeleted;

  FreeformCanvasElement({
    required this.id,
    required this.type,
    required this.index,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.angle,
    required this.strokeColor,
    required this.backgroundColor,
    required this.fillStyle,
    required this.strokeWidth,
    required this.strokeStyle,
    required this.roughness,
    required this.opacity,
    required this.locked,
    required this.groupIds,
    this.frameId,
    this.boundElements,
    this.link,
    this.version,
    this.versionNonce,
    this.seed,
    this.roundness,
    this.updated,
    this.isDeleted = false,
  });

  /// Factory method to create an element from JSON
  factory FreeformCanvasElement.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = _parseElementType(typeString);

    switch (type) {
      case FreeformCanvasElementType.rectangle:
        return FreeformCanvasRectangle.fromJson(json);
      case FreeformCanvasElementType.ellipse:
        return FreeformCanvasEllipse.fromJson(json);
      case FreeformCanvasElementType.text:
        return FreeformCanvasText.fromJson(json);
      case FreeformCanvasElementType.freedraw:
        return FreeformCanvasFreedraw.fromJson(json);
      case FreeformCanvasElementType.line:
        return FreeformCanvasLine.fromJson(json);
      case FreeformCanvasElementType.arrow:
        return FreeformCanvasArrow.fromJson(json);
      case FreeformCanvasElementType.diamond:
        return FreeformCanvasDiamond.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();

  /// Get the alpha channel value of the color
  int get colorAlpha => (opacity*2.55).round();

  /// Get the boundary rectangle of the element 
  /// (only applicable to some elements, other elements use the ElementOps provided method)
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  /// Get the corner radius (return null for elements that do not support corner radius)
  double? get cornerRadius => null;

  Paint get strokePaint {
    final paint = Paint()
      ..color = strokeColor.color.withAlpha(colorAlpha)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    return paint;
  }

  Paint get fillPaint {
    final paint = Paint()
      ..color = backgroundColor.color.withAlpha(colorAlpha)
      ..style = PaintingStyle.fill;

    return paint;
  }

  static FreeformCanvasElementType _parseElementType(String type) {
    switch (type) {
      case 'rectangle':
        return FreeformCanvasElementType.rectangle;
      case 'ellipse':
        return FreeformCanvasElementType.ellipse;
      case 'text':
        return FreeformCanvasElementType.text;
      case 'freedraw':
        return FreeformCanvasElementType.freedraw;
      case 'line':
        return FreeformCanvasElementType.line;
      case 'arrow':
        return FreeformCanvasElementType.arrow;
      case 'diamond':
        return FreeformCanvasElementType.diamond;
      default:
        throw ArgumentError('Unknown element type: $type');
    }
  }

  /// copy common fields to JSON
  Map<String, dynamic> _baseToJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'angle': angle,
      'strokeColor': strokeColor.colorStr,
      'backgroundColor': backgroundColor.colorStr,
      'fillStyle': fillStyle,
      'strokeWidth': strokeWidth,
      'strokeStyle': strokeStyle,
      'roughness': roughness,
      'opacity': opacity,
      'groupIds': groupIds,
      'frameId': frameId,
      'index': index,
      'roundness': null,
      'seed': seed,
      'version': version,
      'versionNonce': versionNonce,
      'isDeleted': isDeleted,
      'boundElements': boundElements,
      'updated': updated,
      'link': link,
      'locked': locked,
    };
  }
}

/// 矩形元素
class FreeformCanvasRectangle extends FreeformCanvasElement {
  FreeformCanvasRectangle({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.rectangle);

  factory FreeformCanvasRectangle.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasRectangle(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    return json;
  }

  @override
  double? get cornerRadius {
    if (roundness == null) return null;

    if (roundness!.type == 2) {
      // 可缩放圆角：使用最小边的15%
      final minSide = width < height ? width : height;
      return minSide * 0.15;
    } else {
      // 固定圆角 (type == 3)
      return 8.0;
    }
  }
}

/// 椭圆元素
class FreeformCanvasEllipse extends FreeformCanvasElement {
  FreeformCanvasEllipse({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.ellipse);

  factory FreeformCanvasEllipse.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasEllipse(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() => _baseToJson();
}

/// 文本元素
class FreeformCanvasText extends FreeformCanvasElement {
  /// Current displayed text
  final String text;

  /// In this project, the value always equals to text.
  final String? originalText;

  /// Small-16 Medium-20 Large-28 Extra Large-36
  final double fontSize;

  /// Font enumeration, 5-Excalifont; 6-Nunito; 7-Lilita One; 8-Comic Shanns
  final int fontFamily;

  /// Text alignment: left / center / right
  final String textAlign;

  /// Vertical alignment: top / middle / bottom
  final String verticalAlign;

  /// Line height
  final double lineHeight;

  /// Whether to automatically adjust the size, unsupported
  final bool autoResize;

  /// Container binding ID, unsupported
  final String? containerId;

  FreeformCanvasText({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    required this.text,
    this.originalText,
    required this.fontSize,
    required this.fontFamily,
    required this.textAlign,
    required this.verticalAlign,
    required this.lineHeight,
    required this.autoResize,
    this.containerId,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.text);

  factory FreeformCanvasText.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasText(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      text: json['text'] as String,
      originalText: json['originalText'] as String?,
      fontSize: (json['fontSize'] as num).toDouble(),
      fontFamily: json['fontFamily'] as int? ?? 1,
      textAlign: json['textAlign'] as String? ?? 'left',
      verticalAlign: json['verticalAlign'] as String? ?? 'top',
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.25,
      autoResize: json['autoResize'] as bool? ?? false,
      containerId: json['containerId'] as String?,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    json.addAll({
      'text': text,
      'originalText': originalText,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'textAlign': textAlign,
      'verticalAlign': verticalAlign,
      'lineHeight': lineHeight,
      'autoResize': autoResize,
      'containerId': containerId,
    });
    return json;
  }
}

/// 路径点（相对坐标）
class FreeformCanvasPoint {
  final double x;
  final double y;

  FreeformCanvasPoint(this.x, this.y);

  factory FreeformCanvasPoint.fromJson(List<dynamic> json) {
    return FreeformCanvasPoint(
      (json[0] as num).toDouble(),
      (json[1] as num).toDouble(),
    );
  }

  List<double> toJson() => [x, y];

  FreeformCanvasPoint copyWith({
    double? x,
    double? y,
  }) {
    return FreeformCanvasPoint(
      x ?? this.x,
      y ?? this.y,
    );
  }

  /// 转换为绝对坐标（相对于元素位置）
  Offset toAbsolute(double baseX, double baseY) {
    return Offset(baseX + x, baseY + y);
  }

  @override
  String toString() => 'Point($x, $y)';
}

/// 自由绘制元素
class FreeformCanvasFreedraw extends FreeformCanvasElement with ElementWithPoints {
  @override
  final List<FreeformCanvasPoint> points;

  /// Pressure data, TODO: Ignore for now
  final List<double>? pressures;

  /// Simulate pressure, TODO: Ignore for now
  final bool simulatePressure;

  FreeformCanvasFreedraw({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    required this.points,
    this.pressures,
    required this.simulatePressure,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.freedraw);

  factory FreeformCanvasFreedraw.fromJson(Map<String, dynamic> json) {
    final pointsJson = json['points'] as List<dynamic>? ?? [];
    final points = pointsJson
        .map((p) => FreeformCanvasPoint.fromJson(List<dynamic>.from(p)))
        .toList();

    return FreeformCanvasFreedraw(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      points: points,
      pressures: json['pressures'] != null
          ? List<double>.from(json['pressures'] as List)
          : null,
      simulatePressure: json['simulatePressure'] as bool? ?? true,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    json.addAll({
      'points': points.map((p) => p.toJson()).toList(),
      'pressures': pressures,
      'simulatePressure': simulatePressure,
    });
    return json;
  }
}

/// 直线元素
class FreeformCanvasLine extends FreeformCanvasElement with ElementWithPoints {
  @override
  final List<FreeformCanvasPoint> points;

  /// Whether it is a closed polygon
  final bool polygon;

  /// Start binding, ignore for now
  final dynamic startBinding;

  /// End binding, ignore for now
  final dynamic endBinding;

  /// Start arrowhead, ignore for now
  final String? startArrowhead;

  /// End arrowhead, ignore for now
  final String? endArrowhead;

  FreeformCanvasLine({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    required this.points,
    this.polygon = false,
    this.startBinding,
    this.endBinding,
    this.startArrowhead,
    this.endArrowhead,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.line);

  factory FreeformCanvasLine.fromJson(Map<String, dynamic> json) {
    final pointsJson = json['points'] as List<dynamic>? ?? [];
    final points = pointsJson
        .map((p) => FreeformCanvasPoint.fromJson(List<dynamic>.from(p)))
        .toList();

    return FreeformCanvasLine(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      points: points,
      polygon: json['polygon'] as bool? ?? false,
      startBinding: json['startBinding'],
      endBinding: json['endBinding'],
      startArrowhead: json['startArrowhead'] as String?,
      endArrowhead: json['endArrowhead'] as String?,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    json.addAll({
      'points': points.map((p) => p.toJson()).toList(),
      'polygon': polygon,
      'startBinding': startBinding,
      'endBinding': endBinding,
      'startArrowhead': startArrowhead,
      'endArrowhead': endArrowhead,
    });
    return json;
  }
}

/// 箭头元素
class FreeformCanvasArrow extends FreeformCanvasElement with ElementWithPoints implements FreeformCanvasLine {
  /// Ignore for now
  final bool elbowed;
  @override
  final List<FreeformCanvasPoint> points;

  /// Whether it is a closed polygon
  @override
  final bool polygon;

  /// Start binding, ignore for now
  @override
  final dynamic startBinding;

  /// End binding, ignore for now
  @override
  final dynamic endBinding;

  /// Start arrowhead, ignore for now
  @override
  final String? startArrowhead;

  /// End arrowhead, ignore for now
  @override
  final String? endArrowhead;

  FreeformCanvasArrow({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    required this.points,
    this.polygon = false,
    this.startBinding,
    this.endBinding,
    this.startArrowhead,
    this.endArrowhead,
    this.elbowed = false,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.arrow);

  factory FreeformCanvasArrow.fromJson(Map<String, dynamic> json) {
    final pointsJson = json['points'] as List<dynamic>? ?? [];
    final points = pointsJson
        .map((p) => FreeformCanvasPoint.fromJson(List<dynamic>.from(p)))
        .toList();

    return FreeformCanvasArrow(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      points: points,
      polygon: json['polygon'] as bool? ?? false,
      startBinding: json['startBinding'],
      endBinding: json['endBinding'],
      startArrowhead: json['startArrowhead'] as String?,
      endArrowhead: json['endArrowhead'] as String?,
      elbowed: json['elbowed'] as bool? ?? false,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    json.addAll({
      'points': points.map((p) => p.toJson()).toList(),
      'polygon': polygon,
      'startBinding': startBinding,
      'endBinding': endBinding,
      'startArrowhead': startArrowhead,
      'endArrowhead': endArrowhead,
      'elbowed':elbowed,
    });
    return json;
  }
}

/// 菱形元素
class FreeformCanvasDiamond extends FreeformCanvasElement {
  FreeformCanvasDiamond({
    required super.id,
    required super.index,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    required super.angle,
    required super.strokeColor,
    required super.backgroundColor,
    required super.fillStyle,
    required super.strokeWidth,
    required super.strokeStyle,
    required super.roughness,
    required super.opacity,
    required super.locked,
    required super.groupIds,
    super.frameId,
    super.boundElements,
    super.link,
    super.version,
    super.versionNonce,
    super.seed,
    super.updated,
    super.roundness,
    super.isDeleted,
  }) : super(type: FreeformCanvasElementType.diamond);

  factory FreeformCanvasDiamond.fromJson(Map<String, dynamic> json) {
    return FreeformCanvasDiamond(
      id: json['id'] as String,
      index: json['index'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      angle: (json['angle'] as num).toDouble(),
      strokeColor: FreeformCanvasColor.fromString(json['strokeColor'] as String),
      backgroundColor: FreeformCanvasColor.fromString(json['backgroundColor'] as String),
      fillStyle: json['fillStyle'] as String,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeStyle: json['strokeStyle'] as String,
      roughness: (json['roughness'] as num).toDouble(),
      opacity: (json['opacity'] as num).toDouble(),
      locked: json['locked'] as bool? ?? false,
      groupIds: List<String>.from(json['groupIds'] as List? ?? []),
      frameId: json['frameId'] as String?,
      boundElements: json['boundElements'] as List<dynamic>?,
      link: json['link'] as String?,
      version: json['version'] as int?,
      versionNonce: json['versionNonce'] as int?,
      seed: json['seed'] as int?,
      updated: json['updated'] as int?,
      roundness: json['roundness'] != null
          ? FreeformCanvasRoundness.fromJson(json['roundness'])
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = _baseToJson();
    return json;
  }

  /// 获取菱形的圆角半径
  /// 返回 (topBottomRadius, leftRightRadius)，如果无圆角返回 null
  (double, double)? get diamondCornerRadii {
    if (roundness == null) return null;

    final roundnessType = roundness!.type;
    double topBottomRadius;
    double leftRightRadius;

    if (roundnessType == 2) {
      // 可缩放圆角：圆角半径为对应边的一定比例
      topBottomRadius = width * 0.15; // 上下顶点使用宽度的15%
      leftRightRadius = height * 0.15; // 左右顶点使用高度的15%
    } else {
      // 固定圆角 (type == 3)
      topBottomRadius = 8.0;
      leftRightRadius = 8.0;

      // 当菱形变小时，圆角需要跟着变小
      // 上下顶点的圆角不超过宽度的一定比例
      final maxTopBottomRadius = width * 0.4;
      topBottomRadius = topBottomRadius < maxTopBottomRadius ? topBottomRadius : maxTopBottomRadius;

      // 左右顶点的圆角不超过高度的一定比例
      final maxLeftRightRadius = height * 0.4;
      leftRightRadius = leftRightRadius < maxLeftRightRadius ? leftRightRadius : maxLeftRightRadius;
    }

    return (topBottomRadius, leftRightRadius);
  }
}

/// 圆角配置
class FreeformCanvasRoundness {
  /// 类型，3 表示固定圆角，2 表示其宽高随元素宽高分别缩放
  final int type;

  FreeformCanvasRoundness({required this.type});

  factory FreeformCanvasRoundness.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return FreeformCanvasRoundness(type: json['type'] as int);
    }
    return FreeformCanvasRoundness(type: 3);
  }

  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) {
    return (other is FreeformCanvasRoundness) && other.type==type;
  }

  @override
  int get hashCode => type.hashCode;

}
/// 颜色
class FreeformCanvasColor{
  final String colorStr;
  final Color color;
  FreeformCanvasColor.fromString(this.colorStr)
    :color = FreeformCanvasColor.parseColor(colorStr);
  FreeformCanvasColor.fromColor(this.color)
    :colorStr = FreeformCanvasColor.colorToStr(color);
  const FreeformCanvasColor.transparent()
    :colorStr = 'transparent',color = Colors.transparent;
  const FreeformCanvasColor.black()
    :colorStr = '#1e1e1e',color = Colors.black;

  bool get isNotTransparent => colorStr != 'transparent';

  // 解析颜色字符串
  static Color parseColor(String colorStr) {
    if (colorStr == 'transparent') {
      return Colors.transparent;
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
  static String colorToStr(Color color, {bool includeAlpha = false}) {
    final int alpha = (color.a*255).round() & 0xff;
    if(alpha==0){
      return 'transparent';
    }
    final int red = (color.r*255).round() & 0xff;
    final int green = (color.g * 255.0).round() & 0xff;
    final int blue = (color.b*255).round() & 0xff;

    if (includeAlpha) {
      return '#${alpha.toRadixString(16).padLeft(2, '0')}'
          '${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    } else {
      return '#'
          '${red.toRadixString(16).padLeft(2, '0')}'
          '${green.toRadixString(16).padLeft(2, '0')}'
          '${blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
  }
}