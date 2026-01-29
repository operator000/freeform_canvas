# Table of Contents
Chapter names are as follows:

- Project Introduction
- `element_ops.dart` and `freeform_canvas_file_ops.dart`: The Exclusive Interfaces for Element and File Data Operations
- freeform_canvas_element.dart: Element Definitions and Structure
- `EditorState`: Collection of Editor Operations
- Rendering Solution Using CustomPaint
- Element Geometry and Hit Testing
- Edit Operation Information Flow
- Editor Component Architecture
- ElementStyle: A Small Feature for Default Element Styles and Style Modifications

# Project Introduction
This project is a **Excalidraw-like Whiteboard Editor** implemented in Flutter, with core features including:

* Decoupling of editor state from rendering, interaction, and display logic
* Elements (Element) and file data (FreeformCanvasFile) are immutable data structures
* Support for multiple interaction methods such as desktop computers, e-ink tablets, tablets, and mobile devices, with the ability to fully customize interaction classes
* The editor has a plugin-based architecture where renderers, interactors, and overlays can be customized separately
* Support for basic fields of .excalidraw files

One of the design goals is:

> **Replicate many of Excalidraw's editing behaviors, support .excalidraw files, adapt to various interaction styles such as e-ink screens, desktop computers, mobile desktops, and tablets, while maintaining the system's high extensibility and customizability.**

# `element_ops.dart` and `freeform_canvas_file_ops.dart`: The Exclusive Interfaces for Element and File Data Operations
## `ElementOps`: Single Element Operation Class
Centrally manages the creation and modification logic of FreeformCanvasElement. In principle, this is the only place where new FreeformCanvasElement instances are allowed to be created.
File: `lib\ops\element_ops.dart`
### Constructor
```dart
  ElementOps._();
```
### Member Functions
```dart
/// **ZH** 复制元素并修改指定字段
///
/// - 当参数值为 `null` 时，将该字段显式设为 null（如果字段可为空）
/// - 如果某字段对该元素类型不存在，则直接忽略该参数
///
/// **EN** Copy the element and modify the specified field
///
/// - When the parameter value is `null`, explicitly set the field to null (if the field is nullable)
/// - If a field does not exist for the element type, ignore the parameter directly
static FreeformCanvasElement copyWith(
  FreeformCanvasElement element, {
  // Common fields
  Object? id = _unset,
  Object? type = _unset,
  Object? index = _unset,
  Object? x = _unset,
  Object? y = _unset,
  Object? width = _unset,
  Object? height = _unset,
  Object? angle = _unset,
  Object? strokeColor = _unset,
  Object? backgroundColor = _unset,
  Object? fillStyle = _unset,
  Object? strokeWidth = _unset,
  Object? strokeStyle = _unset,
  Object? roughness = _unset,
  Object? opacity = _unset,
  Object? locked = _unset,
  Object? groupIds = _unset,
  Object? frameId = _unset,
  Object? boundElements = _unset,
  Object? link = _unset,
  Object? version = _unset,
  Object? versionNonce = _unset,
  Object? seed = _unset,
  Object? roundness = _unset,
  Object? updated = _unset,
  Object? isDeleted = _unset,

  // Text element-specific fields
  Object? text = _unset,
  Object? originalText = _unset,
  Object? fontSize = _unset,
  Object? fontFamily = _unset,
  Object? textAlign = _unset,
  Object? verticalAlign = _unset,
  Object? lineHeight = _unset,
  Object? autoResize = _unset,
  Object? containerId = _unset,

  // Freedraw element-specific fields
  Object? points = _unset,
  Object? pressures = _unset,
  Object? simulatePressure = _unset,

  // Line and arrow element-specific fields
  Object? polygon = _unset,
  Object? startBinding = _unset,
  Object? endBinding = _unset,
  Object? startArrowhead = _unset,
  Object? endArrowhead = _unset,

  // Arrow element-specific fields
  Object? elbowed = _unset,
});

/// **ZH** 根据两点创建草稿元素
///
/// 用于两点拖动型工具（rectangle, ellipse, line, arrow, diamond）
/// [startPoint] 和 [endPoint] 定义元素的边界
///
/// **EN** Create a draft element based on two points
///
/// Used for two-point dragging tools (rectangle, ellipse, line, arrow, diamond)
/// [startPoint] and [endPoint] define the boundaries of the element
static FreeformCanvasElement? createDraftElementFromPoints(
  FreeformCanvasElementType type,
  Offset startPoint,
  Offset endPoint,
);
/// **ZH** 对矩形、椭圆、自由绘制、文本元素进行几何缩放
///
/// 输入两个矩形 [fromRect] 和 [toRect]，其中toRect为fromRect经过某线性变换后的结果。
/// 函数对输入的元素进行完全一致的线性变换，返回新的元素实例。例外：文本元素等比缩放
///
/// **EN** Scale rectangle, ellipse, free drawing and text elements by a linear transformation.
///
/// Given two rectangles [fromRect] and [toRect], where [toRect] is the result of a linear transformation of [fromRect].
/// The function applies a linear transformation to the input element completely, and returns a new element instance.
/// Exception: Text elements are scaled proportionally
static FreeformCanvasElement rectScaleElement(
  FreeformCanvasElement element,
  Rect fromRect,
  Rect toRect,
);
/// **ZH** 对箭头、直线元素进行起点或终点的坐标偏移
///
/// - pointIndex 为整型值，0代表变换起点
///
/// **EN** Offset the start or end point of a line or arrow element
///
/// - pointIndex is an integer value, 0 representing the start point
static FreeformCanvasElement pointsScaleElement(
  FreeformCanvasElement element,
  int pointIndex,
  Offset offset,
);
///**ZH** 从点列表创建freedraw元素
///
///**EN** Create a freedraw element from a list of points
static FreeformCanvasFreedraw createFreedraw(Iterable<Offset> points);
/// **ZH** 向现有的自由绘制草稿元素添加点
///
/// **EN** Add a point to the existing free drawing draft element
static FreeformCanvasFreedraw addPointToFreeDrawDraft(
  FreeformCanvasFreedraw element,
  Offset newCanvasPoint,
);
/// Apply ElementStylePatch to an element. For the definition of ElementStylePatch, see the chapter `# ElementStyle：A Small Feature for Default Element Styles and Style Modifications`
static FreeformCanvasElement applyStylePatch(ElementStylePatch patch, FreeformCanvasElement element);
```
## `FreeformCanvasFileOps`: File Operation Class
File: `freeform_canvas_file_ops.dart`
```dart
/// **ZH** 定义图层（Z 轴）操作
///
/// **EN** Define layer (Z axis) operations
enum ZOrderAction {
  bringToFront,
  sendToBack,
  bringForward,
  sendBackward,
}

/// **ZH** 该类用于对 FreeformCanvasFile 进行文件级操作。
///
/// **EN** This class is used to perform file-level operations on FreeformCanvasFile.
class FreeformCanvasFileOps {
  const FreeformCanvasFileOps._();

  /// **ZH** 向文件中添加一个元素（追加到末尾）
  ///
  /// - 渲染顺序由 elements 列表决定
  /// - index 是 base-62 顺序标识，只在这里生成
  ///
  /// **EN** Add an element to the file (append to the end)
  ///
  /// - Rendering order is determined by the elements list
  /// - index is a base-62 order identifier, only generated here
  static FreeformCanvasFile addElement(
    FreeformCanvasFile file,
    FreeformCanvasElement element,
  );
  /// **ZH** 从文件中删除一个元素
  ///
  /// **EN** Remove an element from the file
  static FreeformCanvasFile removeElement(
    FreeformCanvasFile file,
    String elementId,
  );
  ///**ZH** 获取某元素的z轴位置index（即在元素列表中的index）
  ///
  ///**EN** Get the z-axis position index of an element (i.e. the index in the element list)
  static int getZOrderIndex(FreeformCanvasFile file,String elementId);
  /// **ZH** 更新文件中的某一个元素
  ///
  /// **EN** Update an element in the file
  static FreeformCanvasFile updateElement(
    FreeformCanvasFile file,
    String elementId,
    FreeformCanvasElement Function(FreeformCanvasElement old) updater,
  );
  /// **ZH** 调整某一个元素的 Z 轴顺序
  ///
  /// **EN** Adjust the Z-axis order of a single element
  static FreeformCanvasFile moveZOrder(
    FreeformCanvasFile file,
    String elementId,{
    ZOrderAction? action,
    int? index,
  });
  ///**ZH** 通过 id 定位 element
  ///
  ///**EN** Locate an element by id
  static FreeformCanvasElement? findElement(
    FreeformCanvasFile file,
    String elementId,
  );
}
```

# freeform_canvas_element.dart: Element Definitions and Structure
Element creation is delegated to ElementOps. Therefore, this chapter mainly explains the relationships between elements and the meanings of each field, rather than creation methods.
## Field Classes
Data types of custom fields within elements
### `FreeformCanvasElementType`
```dart
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
```
### `FreeformCanvasRoundness`
```dart
/// Roundness configuration
class FreeformCanvasRoundness {
  /// Type, 3 indicates fixed roundness, 2 indicates its width and height scale separately with element dimensions
  final int type;

  FreeformCanvasRoundness({required this.type});
  ...
}
```
### ``
```dart
/// Color
class FreeformCanvasColor{
  final String colorStr;
  final Color color;
  FreeformCanvasColor.fromString(this.colorStr);
  FreeformCanvasColor.fromColor(this.color);
  const FreeformCanvasColor.transparent();
  const FreeformCanvasColor.black();
  bool get isNotTransparent;
  /// Parse color string
  static Color parseColor(String colorStr);
  /// Encode color, transparent colors will be converted to "transparent".
  static String colorToStr(Color color, {bool includeAlpha = false});
}
```
## Element Base Classes
`ElementWithPoints`, mixed into all elements with a points field
```dart
/// **ZH** 有路径点的 element，即 arrow、line、freedraw
///
/// **EN** Elements with path points, i.e. arrow, line, freedraw
abstract mixin class ElementWithPoints{
  List<FreeformCanvasPoint> get points;
}
```
`FreeformCanvasElement`, base class for all element classes
```dart
abstract class FreeformCanvasElement
```
- Constructor:
```dart
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
  });
```
Member Functions
```dart
/// Factory method to create an element from JSON
factory FreeformCanvasElement.fromJson(Map<String, dynamic> json);
Map<String, dynamic> toJson();

/// Get the alpha channel value of the color
int get colorAlpha => (opacity*2.55).round();

/// Get the boundary rectangle of the element
/// (only applicable to some elements, other elements use the ElementOps provided method)
Rect get bounds => Rect.fromLTWH(x, y, width, height);

/// Get the corner radius (return null for elements that do not support corner radius)
double? get cornerRadius => null;

Paint get strokePaint;
Paint get fillPaint;
static FreeformCanvasElementType _parseElementType(String type);
/// copy common fields to JSON
Map<String, dynamic> _baseToJson();
```

## Seven Specific Element Types
```dart
/// Rectangle element
class FreeformCanvasRectangle extends FreeformCanvasElement
/// Text element
class FreeformCanvasText extends FreeformCanvasElement
/// Free drawing element
class FreeformCanvasFreedraw extends FreeformCanvasElement
/// Line element
class FreeformCanvasLine extends FreeformCanvasElement
/// Arrow element
class FreeformCanvasArrow extends FreeformCanvasElement implements FreeformCanvasLine
/// Diamond element
class FreeformCanvasDiamond extends FreeformCanvasElement
```
## Specific Element Class Member Variables and Their Meanings
- All member variables of the above element classes are of type `final`. All element modification operations are implemented using the methods provided by `ElementOps`, including `copyWith`.
### Common Member Variables
```dart
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
```
### Specific Member Variables
#### Text Element
```dart
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
```
#### Free Drawing Element
```dart
/// Path point list (coordinates relative to the starting point)
final List<FreeformCanvasPoint> points;

/// Pressure data, TODO: Ignore for now
final List<double>? pressures;

/// Simulate pressure, TODO: Ignore for now
final bool simulatePressure;
```
#### Line Element
```dart
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
```
#### Arrow Element
```dart
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
```

# `EditorState`: Collection of Editor Operations
## Member Functions and Variables within `EditorState`
### File Management Related
```dart
  final fileState = FileState();
  FreeformCanvasFile? _file;
  FreeformCanvasFile? get file => _file;

  ///**ZH** 文件修改控制，仅对EditAction子类开放
  ///仅在 EditAction.commit & inverse 方法中传递，即仅在该方法和初始化时 _file 可被改变
  ///
  ///**EN** File modification control, only open to EditAction subclasses
  ///Only passed in EditAction.commit & inverse methods,
  ///i.e. _file can be changed only in the initialization and EditAction.commit & inverse methods
  void _modifyFile(FreeformCanvasFile file);
```

### State Management Related
```dart
  final focusState = FocusState();
  final toolState = ToolState(EditorTool.select);

  void switchTool(EditorTool tool);

  FreeformCanvasElement? get focusedElement;

```
### Document Editing Operations
```dart
void commitIntent(EditIntent intent){
  final action = intent.generateAction(this);
  actionState.do_(this, action);
}
void undo(){
  focusState.cancelFocus();
  actionState.undo(this);
}
void redo(){
  focusState.cancelFocus();
  actionState.redo(this);
}
```
*Introduction to the document editing system can be found in other related chapters*

### Preview Operations Related
```dart
//Preview operations: extract the element to the preview layer. Preview does not modify the document, changes to selection automatically cancel and discard the preview.

///**ZH** 新建元素并进入预览模式(将取消 focus )
///
///**EN** Create an element and enter the preview mode (cancel focus)
void newAndEnterPreview(FreeformCanvasElement element);
///**ZH** 确保某文档元素为预览元素并处在预览模式(让 focus 指向预览元素)
///
///**EN** Ensure that a document element is a preview element and in preview mode (let focus point to the preview element)
void ensurePreviewFor(String elementId);
///**ZH** 更新预览元素
///
///**EN** Update the preview element
void updatePreview(FreeformCanvasElement Function(FreeformCanvasElement) updater);
///**ZH** 取消预览模式，预览中的修改不保存。
///
///**EN** Cancel the preview mode, the modifications in the preview are not saved.
void quitPreview();
```

### Others
```dart
  final transformState = TransformState();
  //The transformation status of the canvas, defined:
  //screen = (canvas + pan)*scale
  //canvas = screen/scale - pan
  Offset get pan => transformState.pan;
  set pan(Offset v) => transformState.pan = v;
  double get scale => transformState.scale;
  set scale(double v) => transformState.scale = v;

  // 文本编辑控制
  // Text editor control
  TextEditor? _textEditor;
  TextEditor? get textEditor => _textEditor;
  void enterTextEdit(TextEditor textEditor);
  void commitAndQuitTextEdit();
```
## `xxxState`: State Notification Classes
- `TransformState`
```dart
///Manage and notify zoom and pan information
class TransformState extends ChangeNotifier{
  int count = 0;
  Offset _pan = Offset.zero;
  Offset get pan => _pan;
  set pan(Offset v);

  double _scale = 1;
  double get scale => _scale;
  set scale(double v);
}
```

- `DraftState`
```dart
//Manage and notify draft element information
class DraftState extends ChangeNotifier{
  ///Update counter (used for CustomPaint repaint)
  int count = 0;

  String? _draftId;
  String? get draftId => _draftId;
  set draftId(String? v)；

  FreeformCanvasElement? _draftElement;
  FreeformCanvasElement? get draftElement => _draftElement;
  set draftElement(FreeformCanvasElement? v);

  ///Set all draft information to null
  void removeValue();
  bool isEmpty() => _draftElement==null;
  void notify()；
}
```

- `FileState`
```dart
//Class that only notifies file changes
class FileState extends ChangeNotifier{
  int count = 0;
  void notify();
}
```

- `FocusState`
```dart
///Focus changes and notifies focus element
class FocusState extends ChangeNotifier{
  int count = 0;
  bool _isFocusOnDraft = false;
  String? _focusElementId;
  void notify();
  ///Move focus to draft element
  void focusOnDraft();
  ///Move focus to element within the file
  void focusOnElement(String elementId);

  bool get hasFocus => _isFocusOnDraft || _focusElementId!=null;
  bool get isFocusOnDraft => _isFocusOnDraft;
  bool get isFocusOnElement => _focusElementId!=null;
  String? get focusElementId => _focusElementId;

  ///Cancel focus
  void cancelFocus();
}
```

- `ToolState`
```dart
//Manage and notify current tool type
class ToolState extends ChangeNotifier{
  EditorTool _currentTool;
  ToolState(EditorTool currentTool);
  EditorTool get currentTool => _currentTool;
  set currentTool(EditorTool tool);

  bool get isGenerative => !(
    _currentTool==EditorTool.drag ||
    _currentTool==EditorTool.select ||
    _currentTool==EditorTool.eraser
  );
}
```

- `ActionState`
```dart
///Manage and notify edit operation data
class ActionState{
  ///Points to the last committed action
  int _statePointer = -1;
  ///For undo operations, the callback parameter is null, otherwise the executed action is passed
  final List<void Function(EditAction?)> _listeners = [];
  final List<EditAction> _actionList = [];
  List<EditAction> get actionList => _actionList;

  void addListener(void Function(EditAction?) listener)；
  void removeListener(void Function(EditAction?) listener)；
  void _notifyListeners(EditAction? action)；
  ///Undo the previous operation (if exists)
  void undo(EditorState editorState);
  ///Redo the next operation (if exists)
  void redo(EditorState editorState);
  ///Execute a new operation and discard undone operations
  void do_(EditorState editorState,EditAction action);
}
```

- `TextEditorState`
```dart
/// Manage and notify text editing data
class TextEditorState extends ChangeNotifier{
  TextEditingController? _textController;// Text editing controller
  Offset? _textCanvasPosition;// Text box position (top-left corner, canvas coordinates)

  TextEditingController? get textController => _textController;
  Offset? get textCanvasPosition => _textCanvasPosition;

  TextEditorState();

  /// Convert TextEditor to Element
  FreeformCanvasText? toElement();
  void setValue(TextEditingController textController,Offset textCanvasPosition);
  void clear();
}
```

# Rendering Solution Using CustomPaint
## Overall Solution
Two CustomPaint components are stacked together using Stack.

Among them, `ActiveLayerPainter` draws dynamic elements, specifically draft elements and selection boxes. Draft elements are further divided into elements being created and elements being modified.

`FreeformCanvasPainter` draws static elements, i.e., elements with low update frequency. Specifically, elements in the file that are not marked as draft.
## Dynamic Element Rendering: `ActiveLayerPainter`
- Class signature
```dart
class ActiveLayerPainter extends CustomPainter {
  final int repaintCounter;
  final FreeformCanvasElement? draftElement;
  final Rect? selectionRect;
  final double scale;
  final Offset pan;

  ActiveLayerPainter({
    required this.scale,
    required this.pan,
    required this.draftElement,//Draft element
    required this.selectionRect,//Selection box
    required this.repaintCounter,//Timer used to trigger repaint
  });
}
```

## Static Element Rendering: `FreeformCanvasPainter`
- Class signature
```dart
class FreeformCanvasPainter extends CustomPainter {
  int dirty;
  final List<FreeformCanvasElement> elements;
  final Color? backgroundColor;
  final String? draftId;
  final double scale;
  final Offset pan;

  FreeformCanvasPainter({
    required this.dirty,//Timer used to trigger repaint
    required this.elements,//All elements in the file
    this.scale = 1,
    this.pan = Offset.zero,
    this.backgroundColor,
    this.draftId,//Id of draft element in the file (this element is not drawn)
  });
}
```

# Element Geometry and Hit Testing
## Element Geometry
`ElementGeomatry`, a utility class for calculating element boundaries, selection boxes, control handles, etc.

File: `painters\element_geomatry.dart`
```dart
///Provides unified calculation of element scaling control points, boundary rectangles, control points, etc.
class ElementGeomatry {
  ElementGeomatry._();
  ///Actual element boundary (without scaling)
  static Rect border(FreeformCanvasElement element);
  ///Element selection box rectangle (without scaling)
  static Rect selectionRect(FreeformCanvasElement element);
  ///Relative positions of element resize handles (without scaling) (rect vertices are the centers of resize handles)
  static Rect resizeHandlePosition(FreeformCanvasElement element);
  ///Element resize handle rectangle
  static Rect resizeHandleRect(Offset centerPoint);
  ///Get the center of element boundary rectangle
  static Offset center(FreeformCanvasElement element);
  ///Rotate point in the opposite direction of element rotation (canvas coordinate system) (used to determine if a point is inside the rotated rectangle)
  static Offset inversedElementRotate(FreeformCanvasElement element,Offset offset);
  ///Rotate point in the same direction as element rotation (canvas coordinate system)
  static Offset correspondedElementRotate(FreeformCanvasElement element,Offset offset);
  ///Get the canvas coordinate of element rotation handle
  static Offset rotateHandlePosition(FreeformCanvasElement element);
  ///Get the radius of element rotation handle
  static double get rotateHandleRadius => 4;
}
```
## Hit Testing
`FreeformCanvasHitTester`: Hit testing only for element lists

Used to determine whether a canvas coordinate point hits an element, with higher-layer elements prioritized.

For elements with fill, hitting inside the element counts as a hit; for elements without fill, hitting the bounding box counts as a hit.

File: `fcanvas_hit_tester.dart`
```dart
/// Hit test result
class HitTestResult {
  /// Hit element ID
  final String elementId;
  HitTestResult(this.elementId);
}
/// Provides geometric hit testing functionality for FreeformCanvas elements
/// Based solely on geometry and bounds judgment
class FreeformCanvasHitTester {
  static HitTestResult? hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
  )
}
```

`ExtendedHitTestResult`: Hit testing for all hittable elements on the canvas, including elements, resize handles, rotation handles, control points.

Objects other than elements are at the highest hit level (not occluded, and do not occlude each other)

File: `extended_hit_tester.dart`
```dart
///Type of hit content
enum HitTestType{
  none,
  element,
  resizeHandle,
  rotateHandle,
  controllPoint,
  secondaryControllPoint,
}
///Resize handle type
enum ResizeHandle{
  tl,
  tr,
  bl,
  br
}
///Unified hit test result for all hittable elements
class ExtendedHitTestResult{
  final HitTestType hitTestType;
  ///Only when `type!=element`, `elementId` is `focusedElementId`
  final String? elementId;
  final ResizeHandle? resizeHandle;
}
///Unified hit testing for all hittable elements, including control points, etc.
class ExtendedHitTester {
  /// focusedElementId: current focused element (this element has control points, etc.)
  ///
  /// Returns the first hit content
  static ExtendedHitTestResult hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
    String? focusedElementId,
  );
}
```

# Edit Operation Information Flow
Edit operations start from user interaction and ultimately affect `EditorState`.

In this process, for atomic modification operations such as modifying colors, element properties, deletion, or direct translation to certain coordinates, the information flow direction is as follows:

Interactor --> InteractionHandler --> EditIntent --> EditAction --> EditorState

- `Interactor` is the starting point of event capture, containing a component that captures mouse, shortcut key, touch, and other events and distributes them to an InteractionHandler;
- `InteractionHandler` is the event processing class after distribution, responsible for mapping a user interaction to specific edit operations;
- `EditIntent` contains a complete description of the edit operation content and execution functions, reverse functions, for subsequent development of redo&undo functionality;
- `EditorState` calls the execution functions provided by `EditIntent` to apply modifications and record Intent.

For long-term modification operations such as translating elements, scaling elements, rotating elements, creating new elements, the information flow direction is as follows:

Interactor --> InteractionHandler --> EditSession --> EditIntent --> EditAction --> EditorState

- `EditSession` is responsible for sequentially applying the information list generated in specific interactions to the preview module in `EditorState`, and finally generating `EditIntent` to submit to `EditorState`
- `EditSession --> EditIntent --> EditAction --> EditorState` is the pure business logic layer, `GestureDetector --> EditorToolController` is the pure UI layer.

The introduction of `EditSession` at this stage is to further decouple the UI layer from business logic. At this point, the Interaction layer can be independently designed separately from the system, which is beneficial for subsequent development of different interaction logic for different devices.

## Base Class Signatures of `InteractionHandler`, `EditAction`, `EditIntent`, and `EditSession`, and Signature of Interaction Data Classes
File: `interaction\edit_intent_and_session\foundamental.dart`
```dart
///**ZH** 单次编辑操作的抽象
///**EN** The abstraction of a single edit operation
abstract class EditIntent {
  EditAction generateAction(EditorState editorState);
}

abstract class EditAction{
  ///执行编辑
  ///Execute the edit
  void commit(EditorState editorState,void Function(FreeformCanvasFile) modifyFile);
  ///撤销编辑
  ///Undo the edit
  void inverse(EditorState editorState,void Function(FreeformCanvasFile) modifyFile){}
}

///**ZH** 由ui层触发的一次长线编辑行为的抽象，典型成员函数包含onStart、onUpdate、onEnd，
///内部应该调用commitEdit将编辑结果以Intent形式提交。
///
///该类旨在隔离ui和编辑操作，以适配不同设备的不同交互逻辑。
///
///对于一次性编辑行为，直接调用`editorState.commitIntent`即可
///
///**EN** The abstract class of a long line editing behavior triggered by the ui layer, typical member functions include onStart, onUpdate, onEnd.
///Internally, it should call commitEdit to submit the editing result as an Intent.
///
///This class is designed to isolate ui and editing operations to accommodate different interaction logic for different devices.
///
///For one-time editing behavior, call `editorState.commitIntent` directly
abstract class EditSession{}
```
File: `lib\interaction_handlers\interaction_handler.dart`

(This file exports all InteractionHandler subclasses.)
```dart
///All interaction processes received by Interactor are handled by this class, which should directly interact with EditorState.commitIntent and EditSessions.
class InteractionHandler {
  void onScaleStart(InputStartEvent event,EditorState editorState){}
  void onScaleUpdate(InputUpdateEvent event,EditorState editorState){}
  void onScaleEnd(InputEndEvent event,EditorState editorState){}
}

class InputStartEvent{
  final Offset localPoint;

  InputStartEvent({required this.localPoint});
}

class InputUpdateEvent{
  final Offset localPoint;
  final Offset panDelta;
  final double scale;

  InputUpdateEvent({required this.localPoint, required this.panDelta, required this.scale});
}

class InputEndEvent{
  InputEndEvent();
}
```

## Signatures of Each Subclass of `EditSession`
File: `interaction\edit_intent_and_session\edit_sessions.dart`
```dart
///Drag element
class ElementDragSession extends EditSession{
  final EditorState editorState;
  final String elementId;
  ElementDragSession({
    required this.editorState,
    required this.elementId,
  });

  void onStart(Offset canvasPoint);
  void onUpdate(Offset canvasDelta);
  void onEnd();
}
///Resize element
class RectResizeSession extends EditSession{
  final EditorState editorState;
  final ResizeHandle resizeHandle;
  RectResizeSession({required this.resizeHandle,required this.editorState});

  void onStart(Offset canvasPoint);
  void onUpdate(Offset canvasDelta);
  void onEnd();
}
///Rotate element
class RotateSession extends EditSession{
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasPoint, EditorState editorState);
  void onEnd(EditorState editorState);
}
///Two-point creation of new element
class TwoPointCreateSession extends EditSession{
  final FreeformCanvasElementType type;
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasDelta, EditorState editorState);
  void onEnd(EditorState editorState);
}
///Create freedraw element
class CreateFreedrawSession extends EditSession{
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasPoint, EditorState editorState);
  void onEnd(EditorState editorState);
}
///Eraser
class EraserSession extends EditSession{
  void onUpdate(Offset canvasPoint, EditorState editorState);
}
```

## Signatures of Various Subclasses of `EditIntent` and `EditAction`
File: `interaction\edit_intent_and_session\intents.dart`

Omitted commit, inverse function signatures. All final fields are required parameters in the constructor.
```dart
///Element overall translation
class DragEditIntent extends EditIntent{
  final String elementId;
  final Offset offset;
}
class DragEditAction extends EditAction{
  final String elementId;
  final Offset offset;
  final FreeformCanvasElement oldElement;
}

///Element rectangular scaling
class RectScaleElementIntent extends EditIntent{
  final String elementId;
  final Rect startRect;
  final Rect endRect;
}
class RectScaleElementAction extends EditAction{
  final String elementId;
  final Rect startRect;
  final Rect endRect;
}

///Element rectangular scaling
class RotateElementIntent extends EditIntent{
  final String elementId;
  final double angleDelta;
}
class RotateElementAction extends EditAction{
  final String elementId;
  final double angleDelta;
  final double originalangle;
}
///Create new element
class ElementCreateIntent extends EditIntent{
  final FreeformCanvasElement element;
}
class ElementCreateAction extends EditAction{
  final FreeformCanvasElement element;
}
///Delete element
class ElementDeleteIntent extends EditIntent{
  final String id;
}
class ElementDeleteAction extends EditAction{
  final String id;
  //No specified index insertion, so directly backup the file
  final FreeformCanvasFile oldFile;
}
///Update element style-related fields
class StyleUpdateIntent extends EditIntent{
  final String id;
  final ElementStylePatch patch;
}
class StyleUpdateAction extends EditAction{
  final FreeformCanvasElement oldElement;
  final ElementStylePatch patch;
}
///Change element order
class MoveZOrderIntent extends EditIntent{
  final String id;
  final ZOrderAction zOrderAction;
}
class MoveZOrderAction extends EditAction{
  final String id;
  final int originalZOrder;
  final ZOrderAction zOrderAction;
}
```

## Signatures of Each Subclass of `InteractionHandler`
All subclass member functions are the same as the base class. Class names are as follows.
```dart
/// Eraser operation
class EraserHandler extends InteractionHandler{}
/// Translation operation
class TransformHandler extends InteractionHandler{}
/// Handler for stepping translation operations, suitable for regular writing
class SteppingTransformHandler extends InteractionHandler{}
class SelectHandler extends InteractionHandler{}
/// Text editing tool
class TextCreateHandler extends InteractionHandler{}
/// Free drawing tool
class FreeDrawHandler implements InteractionHandler{}
/// Two-point creation tool
class TwoPointCreationHandler implements InteractionHandler{}


```

## Corresponding Methods in `EditorState`
```dart
void commitIntent(EditIntent intent);
void undo();
void redo();
```

# Editor Component Architecture
The difference between this chapter and `Edit Operation Information Flow` is that this chapter mainly discusses the modular design of the editor as a whole containing UI and business logic, while `Edit Operation Information Flow` mainly discusses the processing of **edit operation events**.

Different devices such as e-ink screens, Windows, mobile phones, and tablets have different interaction logic, UI styles, and operation sets. Using a simple configuration structure is difficult to implement and involves too many changes. Therefore, the editor adopts a highly modular design. EditorState serves as an invariant, providing core editor operations, saving editor state, and issuing event notifications.

## Component Categories of the Editor
1. Renderer, `renderer`, responsible for rendering the file.
2. Interactor, `interactor`, responsible for handling main screen user input, mapping events to edit operations
3. Overlays, `overlays`, typical examples include toolbars and additional tool buttons. Theoretically, any other small components can be placed in the interaction layer, with the interaction layer on top.

Components are assembled in `FreeformCanvasViewer`. The above components are placed in a Stack, with the stacking order as shown in the following source code fragment:
```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: Axis.horizontal,
      children: overlayWidgets,
    ),
    Expanded(
      child: SizedBox.expand(
        child: Stack(
          children: [
            ...widget.renderer.buildcanvas(context, _editorState),
            widget.interactor.build(context, _editorState),
            widget.renderer.buildTextfield(context, _editorState),
            Positioned(
              child: Inspector(
                editorState: _editorState,
              )
            ),
          ],
        ),
      ),
    ),
  ],
);
```
## `FreeformCanvasViewer` Class and Component Base Classes
File: `freeform_canvas_viewer.dart`
```dart
/// FreeformCanvas editor component
///
/// Provides viewing and editing functionality for FreeformCanvas files, serving as the core component of the editor.
class FreeformCanvasViewer extends StatefulWidget {
  final EditorState? editorState;
  final FreeformCanvasFile? file;
  final String? jsonString;
  final Renderer renderer;
  final Interactor interactor;
  final List<Overlays> overlays;

  const FreeformCanvasViewer({
    super.key,
    this.file,
    this.jsonString,
    this.editorState,
    this.renderer = const CanvasRenderer(),
    this.interactor = const MouseKeyboardInteractor(),
    this.overlays = const[],
  }) : assert(file != null || jsonString != null,
            'Must provide file or jsonString');
}
```
File: `lib\application\foundamental.dart`
```dart
abstract class Overlays{
  const Overlays();
  List<Widget> builder(BuildContext context,EditorState editorState);
}
///**ZH** 将任意组件封装为Overlays
///
///**EN** Wrap any component as Overlays
class OverlaysAny extends Overlays{
  List<Widget> Function(BuildContext context,EditorState editorState) builder_;
  OverlaysAny({required this.builder_});
  @override
  List<Widget> builder(BuildContext context, EditorState editorState) {
    return builder_(context,editorState);
  }
}

///**ZH** 编辑器的interactor组件，负责将用户交互映射至编辑操作。
///
///**EN** The editor's interactor component, which maps user interactions to edit operations.
abstract class Interactor {
  Widget build(BuildContext context,EditorState editorState);
  List<Widget> buildOverlay(BuildContext context,EditorState editorState);

  const Interactor();
}
/// **ZH** 编辑器的渲染器组件，负责渲染画布和文本编辑框。
///
/// **EN** The editor's renderer component, which renders the canvas and text field.
abstract class Renderer {
  ///canvas默认分动静两层，无硬性要求
  List<Widget> buildcanvas(BuildContext context,EditorState editorState);
  Widget buildTextfield(BuildContext context,EditorState editorState);

  const Renderer();
}
```
## Two Sets of Component Instances
Currently there are two sets of components, one for Windows mouse-keyboard interaction scenarios, and one for e-ink screen scenarios.
### Windows Mouse-Keyboard Interaction Scenario
This set is conventional, borrowing UI and operation logic from Excalidraw. With mouse-keyboard interaction, numerous shortcut keys are set, which is convenient for Excalidraw enthusiasts (me).
However, not all shortcut keys and operation functions have been implemented.

The entry class is as follows.
```dart
///**ZH** 适配电脑桌面的画布编辑器组件，在 Windows11 上验证无误。
///
///**EN** Canvas editor component adapted to desktops. Verified on Windows11.
class WindowsFreeformCanvas extends StatefulWidget{
  final FreeformCanvasFile? file;
  final String? jsonString;

  final void Function(FreeformCanvasFile file)? onSave;

  const WindowsFreeformCanvas({
    super.key,
    this.file,
    this.jsonString,
    this.onSave
  }) : assert(file != null || jsonString != null,
            'Must provide file or jsonString');
  @override
  State<WindowsFreeformCanvas> createState() => _WindowsFreeformCanvasState();
}

class _WindowsFreeformCanvasState extends State<WindowsFreeformCanvas> {
  final renderer = CanvasRenderer();
  final interactor = MouseKeyboardInteractor();
  final toolbar = WindowsToolbar();
  @override
  Widget build(BuildContext context) {
    return FreeformCanvasViewer(
      file: widget.file,
      jsonString: widget.jsonString,
      renderer: renderer,
      interactor: interactor,
      overlays: [
        toolbar,
        if(widget.onSave!=null)
          OverlaysAny(builder_: (_,editorState){
            return [BasicButton2UI(
              onPointed: (){
                widget.onSave!(editorState.file!);
              },
              icon: Icons.save,
              message: 'save'
            )];
          })
      ],
    );
  }
}
```

The three major components of this part are as follows.

File: `lib\overlays\modern_toolbar.dart`
```dart
class ModernToolbar extends StatefulWidget{
  final ToolState toolState;
  final void Function(EditorTool tool) onSelect;
}
//下面三个类为本Overlay按钮使用的按钮风格组件，用于自定义新的按钮
// The following three classes are button styles used by the buttons in this Overlay,
// and can be used to customize new buttons

///**ZH** WindowsToolbar所使用的按钮外观组件，无selected状态，只有按下和抬起之分
///
///**EN** The button appearance used by WindowsToolbar with pressed and released status
class BasicButton2UI extends StatefulWidget{
  final void Function() onPointed;
  final IconData icon;
  final String message;

  const BasicButton2UI({super.key, required this.onPointed, required this.icon, required this.message});
}
///WindowsToolbar所使用的按钮外观组件，有selected和!selected之分
///
///**EN** The button appearance used by WindowsToolbar, with selected and !selected status
class BasicButtonUI extends StatelessWidget{
  final IconData iconData;
  final String message;
  final bool isSelected;

  const BasicButtonUI({super.key, required this.iconData, required this.message, required this.isSelected});
}
```
File: `lib\application\canvas_renderer.dart`
```dart
class CanvasRenderer extends Renderer{
  @override
  List<Widget> buildcanvas(BuildContext context,EditorState editorState){
    return [
      StaticLayerRendererWidget(editorState: editorState),
      ActiveLayerRendererWidget(editorState: editorState),
    ];
  }
  @override
  Widget buildTextfield(BuildContext context, EditorState editorState) {
    return TextfieldWidget(editorState: editorState);
  }

  const CanvasRenderer();
}
```
`TextfieldWidget` `StaticLayerRendererWidget` `ActiveLayerRendererWidget` are all defined in this file.

File: `lib\application\mouse_keyboard_interactor.dart`
```dart
class MouseKeyboardInteractor extends Interactor{
  @override
  Widget build(BuildContext context, EditorState editorState) {
    return MouseKeyboardInteractorWidget(editorState: editorState);
  }

  const MouseKeyboardInteractor();

  @override
  List<Widget> buildOverlay(BuildContext context, EditorState editorState) {
    return [];
  }
}
```

### E-ink Screen Scenario
This set has many optimizations for e-ink screens, with significant changes.

`renderer`: The static layer uses bitmap caching to avoid a large amount of repaint work; many unnecessary repaints have been optimized, and diff functionality is planned to be added for incremental drawing as much as possible.
The dynamic layer directly reduces the frame rate, making the lag less noticeable.

`interactor` component is optimized for writing, but only applicable to devices with a stylus or other secondary input that can be recognized by hardware; capacitive pens may not work.
In freedraw tool, touch interaction is disabled by default. After enabling touch interaction, you can directly drag with your hand, and when the pen touches, it returns to freedraw tool. The default tool is set to drag, which is more suitable for writing environments.

`toolbar` uses higher-contrast highlight indicators.

The entry class is as follows.
File: `lib\e_ink_freeform_canvas.dart`
```dart
///**ZH** 适配墨水屏的画布编辑器组件，在 Bigme S6 上验证无误。
///
///**EN** Canvas editor component adapted to e-ink screens. Verified on Bigme S6.
class EInkFreeformCanvas extends StatefulWidget{
  final FreeformCanvasFile? file;
  final String? jsonString;

  final void Function(FreeformCanvasFile file)? onSave;

  const EInkFreeformCanvas({
    super.key,
    this.file,
    this.jsonString,
    this.onSave
  }) : assert(file != null || jsonString != null,
            'Must provide file or jsonString');
  @override
  State<EInkFreeformCanvas> createState() => _EInkFreeformCanvasState();
}

class _EInkFreeformCanvasState extends State<EInkFreeformCanvas> {
  final renderer = EInkScreenRenderer();
  final interactor = StylusAwareInteractor();
  final toolbar = EInkToolbar();
  @override
  Widget build(BuildContext context) {
    return FreeformCanvasViewer(
      file: widget.file,
      jsonString: widget.jsonString,
      renderer: renderer,
      interactor: interactor,
      overlays: [
        toolbar,
        if(widget.onSave!=null)
          OverlaysAny(builder_: (_,editorState){
            return [BasicButton2UI(
              onPointed: (){
                widget.onSave!(editorState.file!);
              },
              icon: Icons.save,
              message: 'save'
            )];
          })
      ],
    );
  }
}
```

The class signatures are as follows.

File: `lib\application\e_ink_screen_renderer.dart`
```dart
///**ZH** 针对墨水屏适配的渲染模式，static层使用做bitmap缓存、降分辨率，
///active层降帧率处理，分析EditIntent尽量做增量绘制，一切为了提升流畅度
///
///**EN** The renderer specified for the e-ink screen, static layer uses bitmap caching and down-sampling,
/// active layer reduces frame rate and analyzes EditIntent to do as much incremental drawing as possible
class EInkScreenRenderer extends Renderer{
  final notifier = UpdateDelayNotifier();
  @override
  List<Widget> buildcanvas(BuildContext context,EditorState editorState){
    return [
      CachedStaticLayerRendererWidget(editorState: editorState),
      ActiveLayerRendererWidget(editorState: editorState),
    ];
  }

  @override
  Widget buildTextfield(BuildContext context, EditorState editorState) {
    return TextfieldWidget(editorState: editorState);
  }
}
```
`StaticLayerRendererWidget` `ActiveLayerRendererWidget` are defined in this file, `TextfieldWidget` is defined in `lib\application\canvas_renderer.dart`

File: `lib\application\stylus_aware_interactor.dart`
```dart
///**ZH** 交互器。适配有硬件支持触控笔的屏幕，以触控笔为高优先级，适合书写
///
///**EN** Interactor. Adapted to screens with hardware support for touchpads, with touchpads as the highest priority.
///Suitable for writing situations.
class StylusAwareInteractor extends Interactor{
  final notifier = TouchDeviceSwitchNotifier();
  @override
  Widget build(BuildContext context, EditorState editorState) {
    return StylusAwareInteractorWidget(editorState: editorState,notifier: notifier);
  }
  @override
  List<Widget> buildOverlay(BuildContext context, EditorState editorState){
    return [
      TouchDeviceSwitch(notifier: notifier),
    ];
  }
}
```
File: `lib\overlays\e_ink_toolbar.dart`
```dart
class EInkToolbar extends Overlays{}
//下面三个类为本Overlay按钮使用的按钮风格组件，用于自定义新的按钮
// The following three classes are button styles used by the buttons in this Overlay,
// and can be used to customize new buttons

///**ZH** EInkToolbar undo/redo 功能所使用的长按按钮外观组件，长按会被多次触发
///
///**EN** The appearance of the long-press button used in the undo/redo function of EInkToolbar,
///which will be triggered multiple times when long-pressing
class LongpressButtonUI extends StatefulWidget{
  final void Function() onPressed;
  final IconData icon;
  final String message;

  const LongpressButtonUI({super.key, required this.onPressed, required this.icon, required this.message});
}

///EInkToolbar所使用的按钮外观组件，无selected状态，只有按下和抬起之分
///
///**EN** The button appearance used by EInkToolbar with pressed and released status
class BasicButton2UI extends StatefulWidget{
  final void Function() onPointed;
  final IconData icon;
  final String message;

  const BasicButton2UI({super.key, required this.onPointed, required this.icon, required this.message});
}
///EInkToolbar所使用的按钮外观组件，有selected和!selected之分
///
///**EN** The button appearance used by EInkToolbar, with selected and !selected status
class BasicButtonUI extends StatelessWidget{
  final IconData iconData;
  final String message;
  final bool isSelected;
  const BasicButtonUI({super.key, required this.iconData, required this.message, required this.isSelected});
}
```


## Example Usage of Open System and Overlays Injection: Save Button
The editor does not provide save functionality. Therefore, save functionality needs to be injected from outside. The plugin-based structure of Overlays, Interactor, renderer, and FreeformCanvasViewer allows all internal states of the editor to be exposed. Overlays can insert a button in the most convenient way and access EditorState internal state and operate EditorState.

The code for implementing save functionality through external injection is as follows.

- Editor component instance code
```dart
FreeformCanvasViewer(
  file: widget.file,
  jsonString: widget.jsonString,
  renderer: renderer,
  interactor: interactor,
  overlays: [
    toolbar,
    if(widget.onSave!=null)
      OverlaysAny(builder_: (_,editorState){//Place where save button is injected
        return [BasicButton2UI(
          onPointed: (){
            widget.onSave!(editorState.file!);
          },
          icon: Icons.save,
          message: 'save'
        )];
      })
  ],
)
```

- Code for rendering the save button
```dart
List<Widget> overlayWidgets = [];
for(var ol in widget.overlays){
  overlayWidgets.addAll(ol.builder(context,_editorState));
}
overlayWidgets.add(Container(width: 1,height: 20,color: Colors.black,));
overlayWidgets.addAll(widget.interactor.buildOverlay(context, _editorState));
```
```dart
Wrap(//Render at the top of the editor
  crossAxisAlignment: WrapCrossAlignment.center,
  direction: Axis.horizontal,
  children: overlayWidgets,
)
```

# ElementStyle: A Small Feature for Default Element Styles and Style Modifications
The `ElementStyle` class is a collection of fields related to element drawing styles, including fonts, colors, etc., used for default value functionality and integration of similar field modifications in EditIntent.

The base class is defined as follows. The meanings of member variables are the same as the corresponding fields within the element.

File: `lib\models\element_style.dart`
```dart
///Fields describing element styles within the element as a set of data
class ElementStyle {
  FreeformCanvasColor strokeColor = FreeformCanvasColor.black();
  FreeformCanvasColor backgroundColor = FreeformCanvasColor.transparent();
  String fillStyle = "solid";
  double strokeWidth = 1;
  String strokeStyle = "solid";
  double roughness = 0;
  double opacity = 100;
  FreeformCanvasRoundness? roundness;
  double fontSize = 16;
  int fontFamily = 5;
  String textAlign = 'left';
}

sealed class PatchValue<T>{
  const PatchValue();
}
class Set<T> extends PatchValue<T>{
  final T? value;
  const Set(this.value);
}
class Unset<T> extends PatchValue<T>{
  const Unset();
}

class ElementStylePatch {
  /** Corresponds one-to-one with fields in ElementStyle */

  const ElementStylePatch({
    this.strokeColor,
    this.backgroundColor,
    this.fillStyle,
    this.strokeWidth,
    this.strokeStyle,
    this.roughness,
    this.opacity,
    this.roundness = const Unset<FreeformCanvasRoundness>(),
    this.fontSize,
    this.fontFamily,
    this.textAlign,
  });

  bool get isEmpty;
}
///Extension to apply Patch to ElementStyle
extension ElementStyleApply on ElementStyle{
  void applyPatch(ElementStylePatch patch);
}
```

# TODOs
Line, arrow two-point drag editing
Line, arrow support multi-point modification
Support images