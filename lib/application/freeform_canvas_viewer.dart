import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/renderers/canvas_renderer.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/application/interactors/mouse_keyboard_interactor.dart';
import 'package:freeform_canvas/inspector/inspector.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import '../freeform_canvas_parser.dart';
import '../core/editor_state.dart';


/// **ZH** FreeformCanvas 查看器组件
///
/// 提供 FreeformCanvas 文件的查看、编辑功能，是编辑器的核心组件。
/// 
/// **EN** FreeformCanvas viewer widget
/// 
/// Provides viewing and editing of FreeformCanvas files, which is the core widget of the editor.
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

  @override
  State<FreeformCanvasViewer> createState() => _FreeformCanvasViewerState();
}

class _FreeformCanvasViewerState extends State<FreeformCanvasViewer> {
  String? _error;
  bool initDone = false;

  // 编辑器状态
  late EditorState _editorState;

  @override
  void initState() {
    super.initState();
    if(widget.editorState != null){
      _editorState = widget.editorState!;
    }else{
      _loadFile();
    }
  }

  @override
  void didUpdateWidget(FreeformCanvasViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.file != oldWidget.file || widget.jsonString != oldWidget.jsonString) {
      _loadFile();
    }
  }

  @override
  void dispose() {
    _editorState.dispose();
    super.dispose();
  }

  /// **ZH** 加载文件并初始化_editorState
  /// 
  /// **EN** Load file and initialize _editorState
  void _loadFile() {
    try {
      if (widget.file != null) {
        _editorState = EditorState(file: widget.file);
        _error = null;
      } else if (widget.jsonString != null) {
        _editorState = EditorState(file: FreeformCanvasParser.parseFromString(widget.jsonString!));
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    }
    initDone = true;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorWidget();
    }

    if (!initDone) {
      return _buildLoadingWidget();
    }

    List<Widget> overlayWidgets = [];
    for(var ol in widget.overlays){
      overlayWidgets.addAll(ol.builder(context,_editorState));
    }
    overlayWidgets.add(Container(width: 1,height: 20,color: Colors.black,));
    overlayWidgets.addAll(widget.interactor.buildOverlay(context, _editorState));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.horizontal,
          children: overlayWidgets,
        ),
        SizedBox(height: 1,child: ColoredBox(color: Colors.black),),
        Expanded(
          child: SizedBox.expand(
            child: ClipRect(
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
        ),
      ],
    );
  }

  /// **ZH** 构建错误显示组件
  /// 
  /// **EN** Build error display component
  Widget _buildErrorWidget() {
    return Container(
      color: Colors.red[50],
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            'Load .excalidraw failed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// **ZH** 构建加载中组件
  /// 
  /// **EN** Build loading component
  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}