///所有新建元素的工具在此：两点新建，freedraw，文本.
library;

import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/edit_sessions.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:freeform_canvas/interaction_handlers/interaction_handler.dart';

///**ZH** 两点新建工具
///
///**EN** Two-point creation tool
class TwoPointCreationHandler implements InteractionHandler{
  final FreeformCanvasElementType type;
  final TwoPointCreateSession session;

  TwoPointCreationHandler({required this.type})
    :session = TwoPointCreateSession(type: type);
  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    session.onStart(canvasPoint, editorState);
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    session.onUpdate(event.panDelta/editorState.scale, editorState);
  }

  @override
  void onScaleEnd(_, EditorState editorState) {
    session.onEnd(editorState);
  }
}

///**ZH** 自由绘制工具
///
///**EN** Free drawing tool
class FreeDrawHandler implements InteractionHandler{
  final session = CreateFreedrawSession();
  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    session.onStart(canvasPoint, editorState);
  }

  @override
  void onScaleUpdate(InputUpdateEvent event, EditorState editorState) {
    final currentPoint =  screenToCanvas(editorState.scale, editorState.pan, event.localPoint);
    session.onUpdate(currentPoint, editorState);
  }
  
  @override
  void onScaleEnd(_, EditorState editorState) {
    session.onEnd(editorState);
  }
}

///**ZH** 文本编辑工具
///
///**EN** Text editing tool
class TextCreateHandler extends InteractionHandler{

  @override
  void onScaleStart(InputStartEvent event, EditorState editorState) {
    final canvasPoint = screenToCanvas(editorState.scale, editorState.pan, event.localPoint);

    // 如果已有正在编辑的文本，先提交
    editorState.quitTextEdit();

    // 创建新的文本编辑状态
    editorState.enterTextEdit(TextEditingController(),canvasPoint);
    editorState.switchToolToDefault();
  }
}