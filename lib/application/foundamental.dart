import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
///**ZH** 编辑器的overlay组件，负责在画布上显示编辑器状态信息、工具栏等。详见文档
///
///**EN** The editor's overlay component, which displays editor status information, toolbars, etc. on the canvas.
/// Refer to the documentation for details.
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

///**ZH** 编辑器的interactor组件，负责将用户交互映射至编辑操作。详见文档
///
///**EN** The editor's interactor component, which maps user interactions to edit operations.
/// Refer to the documentation for details.
abstract class Interactor {
  Widget build(BuildContext context,EditorState editorState);
  List<Widget> buildOverlay(BuildContext context,EditorState editorState);

  const Interactor();
}

/// **ZH** 编辑器的渲染器组件，负责渲染画布和文本编辑框。详见文档
///
/// **EN** The editor's renderer component, which renders the canvas and text field.
/// Refer to the documentation for details.
abstract class Renderer {
  List<Widget> buildcanvas(BuildContext context,EditorState editorState);
  Widget buildTextfield(BuildContext context,EditorState editorState);

  const Renderer();
}