import 'package:flutter/material.dart';
import 'package:freeform_canvas/core/edit_intent_and_session/intents.dart';
import 'package:freeform_canvas/core/editor_dependencies.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_element.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:freeform_canvas/generated/l10n/app_localizations.dart';

/// **ZH** Embeddable 元素的 Link 编辑浮动框
///
/// **EN** Link edit overlay for embeddable elements
///
/// 显示条件：元素选中且不处于草稿状态
/// 功能：显示链接、点击打开、编辑链接
class EmbeddableLinkEditOverlay extends StatefulWidget {
  final FreeformCanvasEmbeddable element;
  final EditorState editorState;
  final Offset screenPosition; // 元素在屏幕上的位置（左上角）
  final double screenWidth; // 元素在屏幕上的宽度

  const EmbeddableLinkEditOverlay({
    super.key,
    required this.element,
    required this.editorState,
    required this.screenPosition,
    required this.screenWidth,
  });

  @override
  State<EmbeddableLinkEditOverlay> createState() => _EmbeddableLinkEditOverlayState();
}

class _EmbeddableLinkEditOverlayState extends State<EmbeddableLinkEditOverlay> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.element.link ?? '');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // 当焦点失去时，提交编辑
    if (!_focusNode.hasFocus && _isEditing) {
      _submitEdit();
    }
  }

  @override
  void didUpdateWidget(EmbeddableLinkEditOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果元素变化了，更新控制器的内容
    if (oldWidget.element.id != widget.element.id || oldWidget.element.link != widget.element.link) {
      _controller.text = widget.element.link ?? '';
      _isEditing = false;
    }
  }

  void _submitEdit() {
    final newLink = _controller.text.trim();
    // 只有当内容有变化时才提交
    if (newLink != widget.element.link) {
      widget.editorState.commitIntent(UpdateElementLinkIntent(
        elementId: widget.element.id,
        newLink: newLink.isEmpty ? null : newLink,
      ));
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _handleSubmit(String? newLink) {
    // 只有当内容有变化时才提交
    if (newLink != widget.element.link) {
      widget.editorState.commitIntent(UpdateElementLinkIntent(
        elementId: widget.element.id,
        newLink: newLink,
      ));
    }
    if(!mounted) return;
    setState(() {
      _isEditing = false;
    });
  }

  void _handleCancel() {
    setState(() {
      _isEditing = false;
      _controller.text = widget.element.link ?? '';
    });
  }

  void _openLink()async{
    if(widget.element.link == null) return;
    try{
      await launchUrl(Uri.parse(widget.element.link ?? ''));
    }catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    // 显示条件：元素选中且不处于草稿状态
    final isFocused = widget.editorState.focusState.focusElementId == widget.element.id;
    final isInPreview = widget.editorState.draftState.draftId == widget.element.id;

    if (!isFocused || isInPreview) {
      return const SizedBox.shrink();
    }

    const overlayWidth = 300.0;
    const overlayHeight = 40.0;
    const overlayPadding = 8.0;

    // 计算位置：在元素上方
    final left = widget.screenPosition.dx + (widget.screenWidth - overlayWidth) / 2;
    final top = widget.screenPosition.dy - overlayHeight - 10;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTapDown: (_) {
          // 阻止点击事件传播，避免触发元素失焦
        },
        child: Container(
          width: overlayWidth,
          height: overlayHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: overlayPadding),
          child: _buildEditContent(),
        ),
      ),
    );
  }

  /// **ZH** 构建编辑内容（支持自定义组件）
  ///
  /// **EN** Build edit content (supports custom components)
  Widget _buildEditContent() {
    // 如果有自定义的链接编辑组件构建器，使用它
    final customBuilder = widget.editorState.dependencies.linkEditComponentBuilder;
    if (customBuilder != null) {
      final context = EmbeddableLinkEditContext(
        element: widget.element,
        editorState: widget.editorState,
        currentLink: widget.element.link,
        onSubmit: _handleSubmit,
        onCancel: _handleCancel,
      );
      return customBuilder(context);
    }

    // 否则使用默认实现
    return _buildDefaultEditContent();
  }

  /// **ZH** 构建默认的编辑内容
  ///
  /// **EN** Build default edit content
  Widget _buildDefaultEditContent() {
    return Row(
      children: [
        // 左侧：链接显示/编辑
        Expanded(
          child: _isEditing
              ? TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.enterLink,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (_) => _submitEdit(),
                  autofocus: true,
                )
              : GestureDetector(
                  onTap: _openLink,
                  child: Text(
                    widget.element.link ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
        ),
        // 右侧：编辑按钮
        if (!_isEditing)
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
              // 延迟聚焦，确保 TextField 已经构建
              Future.delayed(Duration.zero, () {
                _focusNode.requestFocus();
              });
            },
          ),
      ],
    );
  }
}
