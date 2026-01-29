import 'dart:math';
import 'package:flutter/material.dart';
import 'package:freeform_canvas/custom_icons.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/foundamental.dart';
import 'package:freeform_canvas/ops/freeform_canvas_file_ops.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import '../models/freeform_canvas_element.dart';

enum EditorTool {
  drag,
  select,
  rectangle,
  diamond,
  ellipse,
  line,
  arrow,
  freedraw,
  text,
  eraser,
}

extension EditorToolExt on EditorTool{
  FreeformCanvasElementType? get targetElement{
    switch(this){
      case EditorTool.drag:
        return null;
      case EditorTool.select:
        return null;
      case EditorTool.rectangle:
        return FreeformCanvasElementType.rectangle;
      case EditorTool.diamond:
        return FreeformCanvasElementType.diamond;
      case EditorTool.ellipse:
        return FreeformCanvasElementType.ellipse;
      case EditorTool.line:
        return FreeformCanvasElementType.line;
      case EditorTool.arrow:
        return FreeformCanvasElementType.arrow;
      case EditorTool.freedraw:
        return FreeformCanvasElementType.freedraw;
      case EditorTool.text:
        return FreeformCanvasElementType.text;
      case EditorTool.eraser:
        return null;
    }
  }

  IconData get icon{
    switch(this){
      case EditorTool.drag:
        return CustomIcons.drag;
      case EditorTool.select:
        return CustomIcons.select;
      case EditorTool.rectangle:
        return CustomIcons.rectangle;
      case EditorTool.diamond:
        return CustomIcons.diamond;
      case EditorTool.ellipse:
        return CustomIcons.ellipse;
      case EditorTool.line:
        return CustomIcons.line;
      case EditorTool.arrow:
        return CustomIcons.arrow;
      case EditorTool.freedraw:
        return CustomIcons.freedraw;
      case EditorTool.text:
        return CustomIcons.text;
      case EditorTool.eraser:
        return CustomIcons.eraser;
    }
  }
}

class EditorState extends ChangeNotifier{
  EditorTool defaultTool = EditorTool.select;
  final fileState = FileState();
  final textEditorState = TextEditorState();
  final focusState = FocusState();
  late ToolState toolState;
  final draftState = DraftState();
  final transformState = TransformState();
  final actionState = ActionState();
  FreeformCanvasFile? _file;
  FreeformCanvasFile? get file => _file;

  ///**ZH** 文件修改控制，仅对EditAction子类开放
  ///仅在 EditAction.commit & inverse 方法中传递，即仅在该方法和初始化时 _file 可被改变
  ///
  ///**EN** File modification control, only open to EditAction subclasses
  ///Only passed in EditAction.commit & inverse methods, 
  ///i.e. _file can be changed only in the initialization and EditAction.commit & inverse methods
  void _modifyFile(FreeformCanvasFile file){
    _file = file;
    if(focusState.isFocusOnElement
      &&FreeformCanvasFileOps.findElement(_file!, focusState.focusElementId!)==null
    ){
      focusState.cancelFocus();
    }
    fileState.notify();
  }
  ///**ZH** 提交编辑意图
  ///
  ///**EN** Submit edit intent
  void commitIntent(EditIntent intent){
    final action = intent.generateAction(this);
    actionState.do_(this, action);
  }
  ///**ZH** 撤销上一个操作
  ///
  ///**EN** Revoke the last operation
  void undo(){
    focusState.cancelFocus();
    actionState.undo(this);
  }
  ///**ZH** 重做上一个操作
  ///
  ///**EN** Redo the last operation
  void redo(){
    focusState.cancelFocus();
    actionState.redo(this);
  }

  //Focus operations
  FreeformCanvasElement? get focusedElement => focusState.getFocusedElement(this);

  //预览操作：将元素提取到预览层。预览不修改文档，改变选择自动取消和抛弃预览。
  //Preview operations: extract the element to the preview layer. Preview does not modify the document, changes to selection automatically cancel and discard the preview.

  ///**ZH** 新建元素并进入预览模式(将取消 focus )
  ///
  ///**EN** Create an element and enter the preview mode (cancel focus)
  void newAndEnterPreview(FreeformCanvasElement element){
    focusState.cancelFocus();
    draftState.draftElement = element;
  }
  ///**ZH** 确保某文档元素为预览元素并处在预览模式(让 focus 指向预览元素)
  ///
  ///**EN** Ensure that a document element is a preview element and in preview mode (let focus point to the preview element)
  void ensurePreviewFor(String elementId){
    if(elementId==draftState.draftId) return;
    final element = FreeformCanvasFileOps.findElement(_file!, elementId);
    if(element!=null){
      draftState.draftElement = element;
      draftState.draftId = elementId;
      focusState.focusOnDraft();
    }
  }
  ///**ZH** 更新预览元素
  ///
  ///**EN** Update the preview element
  void updatePreview(FreeformCanvasElement Function(FreeformCanvasElement) updater){
    if(draftState.draftElement==null) return;
    draftState.draftElement = updater(draftState.draftElement!);
  }
  ///**ZH** 取消预览模式，预览中的修改不保存。
  ///
  ///**EN** Cancel the preview mode, the modifications in the preview are not saved.
  void quitPreview(){
    if(draftState.isEmpty()) return;
    if(focusState.isFocusOnDraft){
      focusState.focusOnElement(draftState.draftId!);
    }
    draftState.removeValue();
  }
  // 文本编辑控制
  // Text editor control
  void enterTextEdit(TextEditingController textController,Offset textCanvasPosition){//进入文本编辑
    textEditorState.setValue(textController, textCanvasPosition);
  }
  void quitTextEdit(){
    final e = textEditorState.toElement();
    if(e!=null){
      _modifyFile(FreeformCanvasFileOps.addElement(_file!, e));
      focusState.focusOnElement(e.id);
    }
    textEditorState.clear();
  }

  ///**ZH** 切换工具
  ///
  ///**EN** Switch tool
  void switchTool(EditorTool tool){
    if(toolState.currentTool==tool){
      return;
    }
    toolState.currentTool = tool;
    if(tool!=EditorTool.select){
      focusState.cancelFocus();
    }
  }
  ///**ZH** 切换到默认工具，默认工具的默认值是选择工具，但是可以指定为其它工具
  ///
  ///**EN** Switch to default tool. The default tool is the selection tool, but it can be specified as another tool
  void switchToolToDefault(){
    switchTool(defaultTool);
  }

  //The transformation status of the canvas, defined:
  //screen = (canvas + pan)*scale
  //canvas = screen/scale - pan
  Offset get pan => transformState.pan;
  set pan(Offset v){
    quitTextEdit();
    transformState.pan = v;
  }
  double get scale => transformState.scale;
  set scale(double v){
    quitTextEdit();
    transformState.scale = v;
  }

  EditorState({
    FreeformCanvasFile? file,
  }):_file = file{
    toolState = ToolState(defaultTool);
  }

  @override
  void dispose(){
    super.dispose();
    textEditorState.textController?.dispose();
  }
}

///**ZH** 仅仅通知文件更改的类
///
///**EN** Class that only notifies file changes
class FileState extends ChangeNotifier{
  int count = 0;
  void notify(){
    count++;
    notifyListeners();
  }
}
///**ZH** 焦点更改与通知焦点元素
///
///**EN** Focus change and notify focus element
class FocusState extends ChangeNotifier{
  int count = 0;
  bool _isFocusOnDraft = false;
  String? _focusElementId;
  void notify(){
    count++;
    notifyListeners();
  }
  void focusOnDraft(){
    if(!isFocusOnDraft){
      _isFocusOnDraft = true;
      _focusElementId = null;
      notify();
    }
  }
  void focusOnElement(String elementId){
    if(focusElementId!=elementId){
      _isFocusOnDraft = false;
      _focusElementId = elementId;
      notify();
    }
  }

  bool get hasFocus => _isFocusOnDraft || _focusElementId!=null;
  bool get isFocusOnDraft => _isFocusOnDraft;
  bool get isFocusOnElement => _focusElementId!=null;
  String? get focusElementId => _focusElementId;

  void cancelFocus(){
    if(hasFocus){
      _focusElementId = null;
      _isFocusOnDraft = false;
      notify();
    }
  }
  FreeformCanvasElement? getFocusedElement(EditorState editorState){
    if(isFocusOnDraft){
      return editorState.draftState.draftElement;
    }else if(isFocusOnElement){
      return FreeformCanvasFileOps.findElement(editorState._file!,focusElementId!);
    }
    return null;
  }
}
///**ZH** 管理与通知当前工具类型
///
///**EN** Manage and notify the current tool type
class ToolState extends ChangeNotifier{
  EditorTool _currentTool;
  ToolState(EditorTool currentTool):_currentTool = currentTool;
  EditorTool get currentTool => _currentTool;
  set currentTool(EditorTool tool){
    _currentTool = tool;
    notifyListeners();
  }

  bool get isGenerative => !(
    _currentTool==EditorTool.drag ||
    _currentTool==EditorTool.select ||
    _currentTool==EditorTool.eraser
  );
}
///**ZH** 管理与通知草稿元素信息
///
///**EN** Manage and notify draft element information
class DraftState extends ChangeNotifier{
  int count = 0;
  String? _draftId;
  String? get draftId => _draftId;
  void notify(){
    count++;
    notifyListeners();
  }
  set draftId(String? v){
    if(_draftId!=v){
      _draftId = v;
      notify();
    }
  }

  FreeformCanvasElement? _draftElement;
  FreeformCanvasElement? get draftElement => _draftElement;
  set draftElement(FreeformCanvasElement? v){
    if(_draftElement!=v){
      _draftElement = v;
      notify();
    }
  }

  void removeValue(){
    _draftElement = null;
    _draftId = null;
    notify();
  }

  bool isEmpty() => _draftElement==null;
}
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
  TextEditingController? _textController;// 文本编辑控制器
  Offset? _textCanvasPosition;// 文本框位置（左上角,canvas坐标）

  TextEditingController? get textController => _textController;
  Offset? get textCanvasPosition => _textCanvasPosition;

  TextEditorState();

  /// 将TextEditor转换为Element
  FreeformCanvasText? toElement() {

    final text = textController?.text.trim();

    // 如果文本非空，创建文本元素
    if (text!=null&&text.isNotEmpty) {
      final time = DateTime.now().millisecondsSinceEpoch;
      final id = '$time${Random(time).nextInt(10000)}';

      // 计算文本尺寸，与 ZeroPaddingTextfield 保持一致
      final textStyle = TextStyle(
        color: Colors.black, // 颜色不重要，仅用于计算尺寸
        fontSize: 16.0,
        height: 1.0,
      );
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      // 创建文本元素
      final textElement = FreeformCanvasText(
        id: id,
        index: DateTime.now().millisecondsSinceEpoch.toString(),
        x: textCanvasPosition!.dx,
        y: textCanvasPosition!.dy,
        width: textWidth,
        height: textHeight,
        angle: 0.0,
        strokeColor: FreeformCanvasColor.black(),
        backgroundColor: FreeformCanvasColor.transparent(),
        fillStyle: 'solid',
        strokeWidth: 1.0,
        strokeStyle: 'solid',
        roughness: 0.0,
        opacity: 100.0,
        locked: false,
        groupIds: [],
        frameId: null,
        boundElements: null,
        link: null,
        version: null,
        versionNonce: null,
        seed: null,
        updated: null,
        text: text,
        originalText: text,
        fontSize: 16.0, // 与 ZeroPaddingTextfield 一致
        fontFamily: 1, // TODO: 字体映射
        textAlign: 'left',
        verticalAlign: 'top',
        lineHeight: 1.0, // 与 ZeroPaddingTextfield 的 height: 1.0 对应
        autoResize: false,
        containerId: null,
      );

      return textElement;
    }
    return null;
  }

  void setValue(TextEditingController textController,Offset textCanvasPosition){
    clear();
    _textController = textController;
    _textCanvasPosition = textCanvasPosition;
    notifyListeners();
  }

  void clear(){
    _textController?.dispose();
    _textController = null;
    _textCanvasPosition = null;
    notifyListeners();
  }
}
///**ZH** 管理与通知编辑操作数据
///
///**EN** Manage and notify edit operation data
class ActionState{
  ///指向最后一个commit完的action
  int _statePointer = -1;
  ///对于撤回操作，回调传参为null，否则传参被执行的action
  final List<void Function(EditAction?)> _listeners = [];
  final List<EditAction> _actionList = [];
  List<EditAction> get actionList => _actionList;
  
  void addListener(void Function(EditAction?) listener) {
    _listeners.add(listener);
  }
  void removeListener(void Function(EditAction?) listener) {
    _listeners.remove(listener);
  }
  void _notifyListeners(EditAction? action){
    for(var n in _listeners){
      n(action);
    }
  }
  ///撤销上一个操作
  void undo(EditorState editorState){
    if(_statePointer==-1){
      //没有进行任何action的状态
      return;
    }else{
      _actionList[_statePointer].inverse(editorState,editorState._modifyFile);
      _statePointer--;
      _notifyListeners(null);
    }
  }
  void redo(EditorState editorState){
    if(_statePointer>_actionList.length-2){
      //没有更新的操作
      return;
    }else{
      _statePointer++;
      _actionList[_statePointer].commit(editorState,editorState._modifyFile);
      _notifyListeners(_actionList[_statePointer]);
    }
  }
  void do_(EditorState editorState,EditAction action){
    action.commit(editorState,editorState._modifyFile);
    _actionList.removeRange(_statePointer+1, _actionList.length);
    _actionList.add(action);
    _statePointer++;
    _notifyListeners(action);
  }
}