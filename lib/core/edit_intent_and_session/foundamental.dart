import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
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