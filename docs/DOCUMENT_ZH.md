# 目录
章节名称如下：

- 项目介绍
- `element_ops.dart`和`freeform_canvas_file_ops.dart`：元素和文件数据操作的唯一接口
- freeform_canvas_element.dart:元素定义及结构
- `EditorState`：编辑器操作集合
- 使用CustomPaint的绘制方案
- 元素几何和命中测试
- 编辑操作信息流
- 编辑器组件架构
- ElementStyle：一个小功能，元素风格默认风格和风格修改

# 项目介绍
本项目是在 Flutter 中实现的 **类 Excalidraw 白板编辑器**，核心特征包括：

* 编辑器状态与渲染、交互、显示逻辑解耦
* 元素（Element）和文件数据（FreeformCanvasFile）是不可变数据结构
* 支持电脑桌面、墨水屏平板、平板、手机等多种交互方式，并可重头自定义交互类
* 编辑器具有插件式结构，渲染器、交互器、覆盖层可分别自定义
* 支持.excalidraw文件的基本字段

设计目标之一是：

> **还原诸多 Excalidraw 的编辑行为、支持.excalidraw文件，适配墨水屏、电脑桌面、手机桌面、平板等诸多交互风格，同时保持系统极高的可拓展、可定制。**

# `element_ops.dart`和`freeform_canvas_file_ops.dart`：元素和文件数据操作的唯一接口
## `ElementOps`：单元素操作类
集中管理 FreeformCanvasElement 的创建和修改逻辑，原则上这是唯一允许创建新 FreeformCanvasElement 实例的地方。
文件`lib\ops\element_ops.dart`
### 构造函数
```dart
  ElementOps._();
```
### 成员函数
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
/// **ZH** 对元素进行缩放操作（基于控制点位移的算法）
/// - 被拖动点根据 handleOffset 移动
///
/// **EN** Scale element based on control point displacement
/// Scale element based on dragged handle and offset
static FreeformCanvasElement handleScaleElement(
  FreeformCanvasElement initialElement,
  ResizeHandle handle,
  Offset handleOffset,
)
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
/// 对元素应用ElementStylePatch。后者定义见章节`# ElementStyle：一个小功能，元素风格默认风格和风格修改`
static FreeformCanvasElement applyStylePatch(ElementStylePatch patch, FreeformCanvasElement element);
/// **ZH** 修改与元素文本相关的字段，同时会重新计算宽高。
/// 
/// **EN** Modify the fields related to the element's text and recalculate the width and height.
static FreeformCanvasText textElementModify(FreeformCanvasText element,{
  // Object? width = _unset,
  // Object? height = _unset,

  Object? text = _unset,
  // Object? originalText = _unset,
  Object? fontSize = _unset,
  Object? fontFamily = _unset,
  Object? textAlign = _unset,
  Object? verticalAlign = _unset,
  Object? lineHeight = _unset,
  // Object? autoResize = _unset,
  // Object? containerId = _unset,
});
```
## `FreeformCanvasFileOps`：文件操作类
文件`freeform_canvas_file_ops.dart`
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
  ///**ZH** 创建一个空文件
  ///
  ///**EN** Create an empty file
  static FreeformCanvasFile emptyFile();
}
```

# freeform_canvas_element.dart:元素定义及结构
元素创建交由ElementOps实现，因此本章主要讲解各元素关系及其各字段含义，而非创建方式。
## 字段类
元素内各自定字段的数据类型
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
/// 圆角配置
class FreeformCanvasRoundness {
  /// 类型，3 表示固定圆角，2 表示其宽高随元素宽高分别缩放
  final int type;

  FreeformCanvasRoundness({required this.type});
  ...
}
```
### ``
```dart
/// 颜色
class FreeformCanvasColor{
  final String colorStr;
  final Color color;
  FreeformCanvasColor.fromString(this.colorStr);
  FreeformCanvasColor.fromColor(this.color);
  const FreeformCanvasColor.transparent();
  const FreeformCanvasColor.black();
  bool get isNotTransparent;
  /// 解析颜色字符串
  static Color parseColor(String colorStr);
  /// 编码颜色，透明颜色将转为"transparent"。
  static String colorToStr(Color color, {bool includeAlpha = false});
}
```
## 元素基类
`ElementWithPoints`，被所有含points字段的元素混入
```dart
/// **ZH** 有路径点的 element，即 arrow、line、freedraw
/// 
/// **EN** Elements with path points, i.e. arrow, line, freedraw
abstract mixin class ElementWithPoints{
  List<FreeformCanvasPoint> get points;
}
```
`FreeformCanvasElement`，所有元素类的基类
```dart
abstract class FreeformCanvasElement
```
- 构造函数：
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
成员函数
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

## 七种具体元素
```dart
/// 矩形元素
class FreeformCanvasRectangle extends FreeformCanvasElement
/// 文本元素
class FreeformCanvasText extends FreeformCanvasElement
/// 自由绘制元素
class FreeformCanvasFreedraw extends FreeformCanvasElement
/// 直线元素
class FreeformCanvasLine extends FreeformCanvasElement
/// 箭头元素
class FreeformCanvasArrow extends FreeformCanvasElement implements FreeformCanvasLine
/// 菱形元素
class FreeformCanvasDiamond extends FreeformCanvasElement
```
## 具体元素类成员变量及含义
- 上述所有元素类成员变量均为`final`类型，一切元素修改操作使用`ElementOps`提供的方法实现，包括`copyWith`。
### 共有成员变量
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
### 特有成员变量
#### 文本元素
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
#### 自由绘制元素
```dart
/// 路径点列表（相对于起点的坐标）
final List<FreeformCanvasPoint> points;

/// Pressure data, TODO: Ignore for now
final List<double>? pressures;

/// Simulate pressure, TODO: Ignore for now
final bool simulatePressure;
```
#### 直线元素
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
#### 箭头元素
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

# 文本编辑相对于其它元素编辑的特殊性
文本编辑的交互方式和其它元素不同。其它元素以手势的抬起为结束，并且和拖动、缩放等操作互斥，和后续手势之间相互独立。文本元素编辑的退出是单击其它位置、按ESC键等，并且中间允许缩放平移行为。

为其它元素相关操作设计的单次编辑操作流程由`EditSession`子类管理，它对接UI层`InteractionHandler`子类（有onStart、onUpdate、onEnd回调），一次交互一个 Handler 是基本设计，文本编辑不适合该流程。
在 freeform canvas 中，文本编辑被视为一种 editor-level 的编辑模式，`EditorState.textEditorState.enterTextEdit`和`EditorState.textEditorState.quitTextEdit`作为接口触发编辑操作，`TextEditData`用于存储编辑时数据，包括临时元素、TextController等，`TextEditWidget`为渲染文本框、处理输入的组件。

下面给出`TextEditData`类签名，编辑操作见其余章节。

##  `TextEditData`类签名
文件`lib\models\text_editing_data.dart`
```dart
///**ZH** 文本编辑数据
///
///**EN** Text editing data
class TextEditData{
  final TextEditingController textController;
  final FreeformCanvasText behalfElement;
  ///isVirtual==true: The element is not in the file
  final bool isVirtual;

  TextEditData({
    required this.textController,
    required this.behalfElement,
    required this.isVirtual,
  });
  /// Used when creating new text elements.
  void dispose();
  factory TextEditData.newText({
    required Offset textCanvasPosition,
    required Color? textColor,
    double fontSize = 36,
    double lineHeight = 1.25,
  });
  /// Used when modifing a specific element in the file.
  factory TextEditData.fromElement({required FreeformCanvasText element});
}
```

# `EditorState`：编辑器操作集合
## `EditorState`内的成员函数和变量
### 文件管理相关
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

### 状态管理相关
```dart
  final focusState = FocusState();
  final toolState = ToolState(EditorTool.select);

  void switchTool(EditorTool tool);

  FreeformCanvasElement? get focusedElement;

```
### 文档编辑操作
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
*文档编辑系统的介绍见其它相关章节*

### 预览操作相关
```dart
//预览操作：将元素提取到预览层。预览不修改文档，改变选择自动取消和抛弃预览。
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

### 其余
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
  // Text edit control
  final textEditorState = TextEditorState();
  void enterTextEdit(TextEditData data);
  ///**ZH** 退出文本编辑并视情况保存元素
  ///
  ///**EN** Exit text editing and save the element as needed
  void quitTextEdit() => textEditorState.quitTextEdit(this);
```
## `xxxState`：状态通知类
- `TransformState`
```dart
///管理与通知缩放平移信息
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
//管理与通知草稿元素信息
class DraftState extends ChangeNotifier{
  ///更新计数（用于CustomPaint重绘）
  int count = 0;

  String? _draftId;
  String? get draftId => _draftId;
  set draftId(String? v)；

  FreeformCanvasElement? _draftElement;
  FreeformCanvasElement? get draftElement => _draftElement;
  set draftElement(FreeformCanvasElement? v);

  ///将所有草稿信息设为null
  void removeValue();
  bool isEmpty() => _draftElement==null;
  void notify()；
}
```

- `FileState`
```dart
//仅仅通知文件更改的类
class FileState extends ChangeNotifier{
  int count = 0;
  void notify();
}
```

- `FocusState`
```dart
///焦点更改与通知焦点元素
class FocusState extends ChangeNotifier{
  int count = 0;
  bool _isFocusOnDraft = false;
  String? _focusElementId;
  void notify();
  ///将焦点移至草稿元素
  void focusOnDraft();
  ///将焦点移至文件内元素
  void focusOnElement(String elementId);

  bool get hasFocus => _isFocusOnDraft || _focusElementId!=null;
  bool get isFocusOnDraft => _isFocusOnDraft;
  bool get isFocusOnElement => _focusElementId!=null;
  String? get focusElementId => _focusElementId;

  ///取消焦点
  void cancelFocus();
}
```

- `ToolState`
```dart
//管理与通知当前工具类型
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
///管理与通知编辑操作数据
class ActionState{
  ///指向最后一个commit完的action
  int _statePointer = -1;
  ///对于撤回操作，回调传参为null，否则传参被执行的action
  final List<void Function(EditAction?)> _listeners = [];
  final List<EditAction> _actionList = [];
  List<EditAction> get actionList => _actionList;
  
  void addListener(void Function(EditAction?) listener)；
  void removeListener(void Function(EditAction?) listener)；
  void _notifyListeners(EditAction? action)；
  ///撤销上一个操作（如果存在）
  void undo(EditorState editorState);
  ///重做下一个操作（如果存在）
  void redo(EditorState editorState);
  ///执行新操作并抛弃被撤销的操作
  void do_(EditorState editorState,EditAction action);
}
```

- `TextEditorState`
```dart
///**ZH** 管理与通知缩放平移信息
///
///**EN** Manage and notify zoom and pan information
class TransformState extends ChangeNotifier{
  int count = 0;
  //画布变换状态，定义：
  //screen = (canvas + pan)*scale
  //canvas = screen/scale - pan
  Offset _pan = Offset.zero;
  Offset get pan => _pan;
  set pan(Offset v){
    if(_pan!=v){
      _pan=v;
      count++;
      notifyListeners();
    }
  }
  double _scale = 1;
  double get scale => _scale;
  set scale(double v){
    if(_scale!=v){
      _scale = v;
      count++;
      notifyListeners();
    }
  }
}

///**ZH** 管理与通知文本编辑数据
///
///**EN** Manage and notify text editing data
class TextEditorState extends ChangeNotifier{
  TextEditData? __textEditData;
  TextEditData? get textEditData => __textEditData;
  set _textEditData(TextEditData? v);
  TextEditorState();
  //Core operations:
  void enterTextEdit(TextEditData data,EditorState editorState);
  void quitTextEdit(EditorState editorState);

  @override void dispose();
}
```

# 使用CustomPaint的绘制方案
## 总体方案
两个CustomPaint组件通过Stack叠加在一起。

其中`ActiveLayerPainter`绘制动态元素，具体为草稿元素、选中框。草稿元素又细分为新建中的元素、修改中的元素。

`FreeformCanvasPainter`绘制静态元素，也就是更新频率低的元素。具体为在文件中且未被标记为draft的元素。
## 动态元素绘制:`ActiveLayerPainter`
- 类签名
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
    required this.draftElement,//草稿元素
    required this.selectionRect,//选择框
    required this.repaintCounter,//用于触发重绘的计时器
  });
}
```

## 静态元素绘制：`FreeformCanvasPainter`
- 类签名
```dart
class FreeformCanvasPainter extends CustomPainter {
  int dirty;
  final List<FreeformCanvasElement> elements;
  final FreeformCanvasAppState appState;
  final Color? backgroundColor;
  final String? draftId;
  final EditorState editorState;

  FreeformCanvasPainter({
    required this.dirty,//用于触发重绘的计时器
    required this.elements,//文件中的所有元素
    required this.appState,
    required this.editorState,
    this.backgroundColor,
    this.draftId,//文件中的draft元素的id（不绘制该元素）
  });
}
```

# 元素几何和命中测试
## 元素几何
`ElementGeometry`，计算元素边界、选择框、控制手柄等的工具类

文件`painters\element_geometry.dart`
```dart
///提供元素缩放控制点、边界矩形、控制点等的统一计算
class ElementGeometry {
  ElementGeometry._();
  ///元素实际边界（不含缩放）
  static Rect border(FreeformCanvasElement element);
  ///元素选择框矩形（不含缩放）
  static Rect selectionRect(FreeformCanvasElement element);
  ///元素缩放手柄的相对位置（不含缩放）（rect顶点处为缩放手柄中心）
  static Rect resizeHandlePosition(FreeformCanvasElement element);
  static double get resizeHandleDiameter => 8;
  ///**ZH** 元素缩放手柄矩形，画布坐标系。手柄大小随scale变化。
  ///
  ///**EN** Resize handle rectangle in the canvas coordinate system. The handle size changes with scale.
  static Rect resizeHandleRect(Offset centerPoint,double scale)
  ///获取元素边界矩形中心
  static Offset center(FreeformCanvasElement element);
  ///以与元素旋转方向相反的方向旋转点（canvas坐标系）（用来判断某点是否在旋转后的矩形内）
  static Offset inversedElementRotate(FreeformCanvasElement element,Offset offset);
  ///以与元素旋转方向相同的方向旋转点（canvas坐标系）
  static Offset correspondedElementRotate(FreeformCanvasElement element,Offset offset);
  ///获取元素旋转手柄在canvas坐标系下的坐标
  static Offset rotateHandlePosition(FreeformCanvasElement element);
  ///获取元素旋转手柄的半径
  static double get rotateHandleRadius => 4;
  ///**ZH** 根据相关字段计算文本宽高，返回（宽，高）
  ///
  ///**EN** Calculate the width and height of text based on related fields, return (width, height)
  static (double, double) layoutText({
    required String text,
    required double fontSize,
    required int fontFamily,
    required String textAlign,
    required String verticalAlign,
    required double lineHeight,
  })
  ///**ZH** 计算元素列表的边界，canvas坐标系
  ///
  ///**EN** Calculate the boundary of the element list in the canvas coordinate system
  static Rect calculateBoundary(List<FreeformCanvasElement> elements)
}
```
## 命中测试
`FreeformCanvasHitTester`：仅仅对元素列表进行的元素命中测试

用以判断某canvas坐标点是否命中某元素，层级靠上的元素优先命中。

有填充的元素命中元素内记作命中，无填充的元素命中边界框记作命中。

文件`fcanvas_hit_tester.dart`
```dart
/// 命中测试结果
class HitTestResult {
  /// 被命中的元素ID
  final String elementId;
  HitTestResult(this.elementId);
}
/// 提供对 FreeformCanvas 元素的几何命中测试功能
/// 仅基于几何形状和 bounds 判断
class FreeformCanvasHitTester {
  static HitTestResult? hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
  )
}
```

`ExtendedHitTestResult`：对画布内所有可命中元素的命中测试，包含元素、缩放手柄、旋转手柄、控制点。

除元素外的对象处于被命中的最高层级（不被遮挡，互相也不遮挡）

文件`extended_hit_tester.dart`
```dart
///命中内容的类型
enum HitTestType{
  none,
  element,
  resizeHandle,
  rotateHandle,
  controllPoint,
  secondaryControllPoint,
}
///缩放手柄类型
enum ResizeHandle{
  tl,
  tr,
  bl,
  br
}
///对所有可命中元素的统一命中测试结果
class ExtendedHitTestResult{
  final HitTestType hitTestType;
  ///当且仅当`type!=element`时，`elementId`为`focusedElementId`
  final String? elementId;
  final ResizeHandle? resizeHandle;
}
///对所有可命中元素的统一命中测试,包含控制点等
class ExtendedHitTester {
  /// focusedElementId： 当前聚焦元素（该元素拥有控制点等）
  ///
  /// 返回第一个命中的内容
  static ExtendedHitTestResult hitTest(
    Offset worldPoint,
    List<FreeformCanvasElement> elements,
    String? focusedElementId,
  );
}
```

# 编辑操作信息流
编辑操作起于 user interaction ，最终作用于`EditorState`。

该过程中，对于原子修改操作如修改颜色、元素属性、删除或直接平移到某坐标，信息流动方向如下：

Interactor --> InteractionHandler --> EditIntent --> EditAction --> EditorState

- 其中`Interactor`为事件捕获起点，包含一个组件，捕获鼠标、快捷键、触摸等事件并分发给某一个InteractionHandler；
- `InteractionHandler`为分发后的事件处理类，负责将某 user interaction 映射到具体的编辑操作；
- `EditIntent`包含编辑操作内容的全部描述和执行函数、逆转函数，用以后续开发redo&undo功能；
- `EditorState`调用`EditIntent`提供的执行函数应用修改并记录Intent。

对于长线修改操作如平移元素、缩放元素、旋转元素、新建元素，信息流动方向如下：

Interactor --> InteractionHandler --> EditSession --> EditIntent --> EditAction --> EditorState

- 其中`EditSession`负责将特定交互中产生的信息列表依次应用于`EditorState`中预览模块，并在最后生成`EditIntent`提交到`EditorState`
- 其中`EditSession --> EditIntent --> EditAction --> EditorState`为纯业务逻辑层，`GestureDetector --> EditorToolController`为纯UI层。

该阶段`EditSession`的引入是为了进一步解耦UI层和业务逻辑，此时可以将Interaction层从系统中独立出来单独设计，有利于后续针对不同设备开发不同交互逻辑。

## `InteractionHandler`,`EditAction`,`EditIntent`和`EditSession`基类签名，以及交互数据类签名
文件`interaction\edit_intent_and_session\fundamental.dart`
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
文件`lib\interaction_handlers\interaction_handler.dart`

(该文件export所有InteractionHandler子类。)
```dart
///所有Interactor接收到的一次交互过程交由该类处理，该类应该直接与EditorState.commitIntent和EditSessions交互。
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

## `EditSession`的各子类签名
文件`interaction\edit_intent_and_session\edit_sessions.dart`
```dart
///拖动元素
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
///缩放元素
class HandleResizeSession extends EditSession{
  final EditorState editorState;
  final ResizeHandle resizeHandle;
  HandleResizeSession({required this.resizeHandle,required this.editorState});

  void onStart(Offset canvasPoint);
  void onUpdate(Offset canvasDelta);
  void onEnd();
}
///旋转元素
class RotateSession extends EditSession{
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasPoint, EditorState editorState);
  void onEnd(EditorState editorState);
}
///两点式创建新元素
class TwoPointCreateSession extends EditSession{
  final FreeformCanvasElementType type;
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasDelta, EditorState editorState);
  void onEnd(EditorState editorState);
}
///创建freedraw元素
class CreateFreedrawSession extends EditSession{
  void onStart(Offset canvasPoint, EditorState editorState);
  void onUpdate(Offset canvasPoint, EditorState editorState);
  void onEnd(EditorState editorState);
}
///橡皮擦
class EraserSession extends EditSession{
  void onUpdate(Offset canvasPoint, EditorState editorState);
}
///文本编辑。文本编辑操作为长线操作，尽管本Session仅处理触发。
///Text editing. Text editing operations are long-line operations, even though this Session only handles triggering.
class TextEditSession extends EditSession{
  void onTrigger(Offset canvasPoint, EditorState editorState);
}
```

## `EditIntent`，`EditAction`的各类子签名
文件`interaction\edit_intent_and_session\intents.dart`

省略commit,inverse函数签名，所有final字段均为构造函数中的required参数。
```dart
///元素整体平移
class DragEditIntent extends EditIntent{
  final String elementId;
  final Offset offset;
}
class DragEditAction extends EditAction{
  final String elementId;
  final Offset offset;
  final FreeformCanvasElement oldElement;
}

///元素手柄缩放
class HandleScaleElementIntent extends EditIntent{
  final String elementId;
  final ResizeHandle startHandle;
  final Offset offset;
}
class HandleScaleElementAction extends EditAction{
  final String elementId;
  final ResizeHandle startHandle;
  final Offset offset;
  final FreeformCanvasElement oldElement;
}

///元素旋转
class RotateElementIntent extends EditIntent{
  final String elementId;
  final double angleDelta;
}
class RotateElementAction extends EditAction{
  final String elementId;
  final double angleDelta;
  final double originalangle;
}
///新建元素
class ElementCreateIntent extends EditIntent{
  final FreeformCanvasElement element;
}
class ElementCreateAction extends EditAction{
  final FreeformCanvasElement element;
}
///删除元素
class ElementDeleteIntent extends EditIntent{
  final String id;
}
class ElementDeleteAction extends EditAction{
  final String id;
  //没有做指定index插入，因此直接备份文件
  final FreeformCanvasFile oldFile;
}
///更新元素style相关字段
class StyleUpdateIntent extends EditIntent{
  final String id;
  final ElementStylePatch patch;
}
class StyleUpdateAction extends EditAction{
  final FreeformCanvasElement oldElement;
  final ElementStylePatch patch;
}
///更改元素顺序
class MoveZOrderIntent extends EditIntent{
  final String id;
  final ZOrderAction zOrderAction;
}
class MoveZOrderAction extends EditAction{
  final String id;
  final int originalZOrder;
  final ZOrderAction zOrderAction;
}
///修改文本元素
///Modify text element
class TextUpdateIntent extends EditIntent{
  final FreeformCanvasText updatedElement;
}
class TextUpdateAction extends EditAction{
  final FreeformCanvasText updatedElement;
  final FreeformCanvasText oldElement;
}
```

## `InteractionHandler`的各子类签名
各子类成员函数均和基类一样，类名如下。
```dart
/// 橡皮擦操作
class EraserHandler extends InteractionHandler{}
/// 平移操作
class TransformHandler extends InteractionHandler{}
///步进执行平移操作的handler，适用于规整书写时
class SteppingTransformHandler extends InteractionHandler{}
class SelectHandler extends InteractionHandler{}
///文本编辑工具
class TextEditHandler extends InteractionHandler{}
/// 自由绘制工具
class FreeDrawHandler implements InteractionHandler{}
/// 两点新建工具
class TwoPointCreationHandler implements InteractionHandler{}


```

## `EditorState`中的对应方法
```dart
void commitIntent(EditIntent intent);
void undo();
void redo();
```

# 编辑器组件架构
本章与`编辑操作信息流`的区别在于，本章主要讲含ui和业务逻辑的编辑器作为整体的模块化设计，`编辑操作信息流`主要讲**编辑操作事件**的处理。

墨水屏、Windows、手机、平板等不同设备交互逻辑不同、ui风格不同、操作集合不同。使用简单的配置结构不好实现，并且变动过多，因此编辑器采取高度模块化的设计。EditorState作为不变量，提供编辑器核心操作和保存编辑器状态、进行事件通知。

## 编辑器的组件类别
1. 渲染器，`renderer`，负责将文件渲染出来。
2. 交互器，`interactor`，负责处理主要的屏幕用户输入，将事件映射到编辑操作
3. 覆盖层，`overlays`，典型为工具栏、额外工具按钮。理论上任意其余小组件可以放在交互层，交互层在最上面

组件在`FreeformCanvasViewer`中完成组装，上述组件均放到一个Stack中，层叠顺序见下面源码片段：
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
## `FreeformCanvasViewer`类和组件基类
文件`freeform_canvas_viewer.dart`
```dart
/// FreeformCanvas 编辑器组件
///
/// 提供 FreeformCanvas 文件的查看、编辑功能，是编辑器的核心组件。
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
文件`lib\application\fundamental.dart`
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
## 两套组件实例
目前有两套组件，一套为Windows键鼠交互场景，一套为墨水屏场景。
### Windows键鼠交互场景
这一套中规中矩，ui和操作逻辑上借鉴Excalidraw，由于有键鼠交互，设置了诸多快捷键，对于Excalidraw爱好者（我）很方便。
但未实现所有快捷键、操作功能。

入口类如下。
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
  late FreeformCanvasFile? file;
  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return FreeformCanvasViewer(
      file: file,
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

这部分的三大组件如下。

文件`lib\overlays\modern_toolbar.dart`
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
文件`lib\application\canvas_renderer.dart`
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
    return TextEditWidget(editorState: editorState);
  }

  const CanvasRenderer();
}
```
`TextEditWidget` 在lib\application\renderers\text_edit_widget.dart定义
`StaticLayerRendererWidget` `ActiveLayerRendererWidget` 在本文件定义。

文件`lib\application\mouse_keyboard_interactor.dart`
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

### 墨水屏场景
这一套针对墨水屏做了不少优化，改动也极大。

`renderer`静态层使用位图做缓存，避免大量重绘工作；优化了不少不必要的重绘，并预计增加diff功能，尽量做增量绘制。
动态层直接降帧率，看着卡顿感不那么明显。

`interactor`组件针对书写做了优化，但是仅适用于有手写笔等第二输入且硬件上可识别的，电容笔似乎不行。
freedraw工具下默认禁用触屏交互，允许触屏交互后可以直接用手拖动，落笔就返回freedraw工具。默认工具设置为drag，也是更多适配书写环境。

`toolbar`换了对比度更强的高亮标识。

入口类如下。
文件`lib\e_ink_freeform_canvas.dart`
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
  late FreeformCanvasFile? file;
  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return FreeformCanvasViewer(
      file: file,
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

各类签名如下。

文件`lib\application\e_ink_screen_renderer.dart`
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
    return TextEditWidget(editorState: editorState);
  }
}
```
`TextEditWidget` 在lib\application\renderers\text_edit_widget.dart定义
`StaticLayerRendererWidget` `ActiveLayerRendererWidget` 在本文件定义。

文件`lib\application\stylus_aware_interactor.dart`
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
文件`lib\overlays\e_ink_toolbar.dart`
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


## 开放系统和Overlays注入的示例用法：保存按钮
编辑器不提供保存功能。因此保存功能需要从外部注入。而Overlays，Interactor，renderer，FreeformCanvasViewer的插件式结构允许将编辑器内部状态全部暴露。Overlays可以用最方便的方式插入一个按钮，并获取EditorState内部状态和操作EditorState。

通过外部注入实现保存功能的代码如下。

- 编辑器组件实例代码
```dart
FreeformCanvasViewer(
  file: widget.file,
  jsonString: widget.jsonString,
  renderer: renderer,
  interactor: interactor,
  overlays: [
    toolbar,
    if(widget.onSave!=null)
      OverlaysAny(builder_: (_,editorState){//注入save按钮的地方
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

- save按钮被渲染的代码
```dart
List<Widget> overlayWidgets = [];
for(var ol in widget.overlays){
  overlayWidgets.addAll(ol.builder(context,_editorState));
}
overlayWidgets.add(Container(width: 1,height: 20,color: Colors.black,));
overlayWidgets.addAll(widget.interactor.buildOverlay(context, _editorState));
```
```dart
Wrap(//在编辑器顶端渲染
  crossAxisAlignment: WrapCrossAlignment.center,
  direction: Axis.horizontal,
  children: overlayWidgets,
)
```

# ElementStyle：一个小功能，元素风格默认风格和风格修改
`ElementStyle`类是有关元素绘制风格的字段集合，包含字体、颜色等，用于默认值功能和EditIntent同类字段修改整合。

基类定义如下。成员变量的含义与元素内对应字段含义相同

文件`lib\models\element_style.dart`
```dart
///元素字段中描述元素风格的字段作为一组数据
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
  /** 与ElementStyle内字段一一对应 */

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
///补充将Patch应用到ElementStyle的方法
extension ElementStyleApply on ElementStyle{
  void applyPatch(ElementStylePatch patch);
}
```

# TODOs
直线、箭头两点拖动编辑
直线、箭头支持多点修改
支持图片