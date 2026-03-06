import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';

/// **ZH** 编辑器依赖配置
///
/// **EN** Editor dependencies configuration
///
/// 用于集中管理编辑器的可注入依赖，包括：
/// - Embeddable 元素的渲染器
/// - Embeddable 链接编辑组件
class EditorDependencies {
  /// **ZH** Embeddable 元素的外部渲染器
  ///
  /// **EN** External renderer for embeddable elements
  final EmbeddableRenderer? embeddableRenderer;

  /// **ZH** Embeddable 链接编辑组件构建器
  ///
  /// **EN** Embeddable link edit component builder
  ///
  /// 允许自定义整个链接编辑UI，而不仅仅是文本框和按钮
  final EmbeddableLinkEditComponentBuilder? linkEditComponentBuilder;

  const EditorDependencies({
    this.embeddableRenderer,
    this.linkEditComponentBuilder,
  });

  /// **ZH** 默认配置（使用内置实现）
  ///
  /// **EN** Default configuration (using built-in implementation)
  static const EditorDependencies defaultDependencies = EditorDependencies();
}

/// **ZH** Embeddable 链接编辑组件构建器
///
/// **EN** Embeddable link edit component builder
///
/// 用于构建自定义的链接编辑UI组件
typedef EmbeddableLinkEditComponentBuilder = Widget Function(
  EmbeddableLinkEditContext context,
);

/// **ZH** Embeddable 链接编辑上下文
///
/// **EN** Embeddable link edit context
///
/// 提供给自定义链接编辑组件的上下文信息
class EmbeddableLinkEditContext {
  /// 当前元素
  final FreeformCanvasEmbeddable element;

  /// 编辑器状态
  final EditorState editorState;

  /// 当前链接值（可能为null）
  final String? currentLink;

  /// 提交新链接的回调
  final void Function(String? newLink) onSubmit;

  /// 取消编辑的回调
  final VoidCallback onCancel;

  const EmbeddableLinkEditContext({
    required this.element,
    required this.editorState,
    required this.currentLink,
    required this.onSubmit,
    required this.onCancel,
  });
}
