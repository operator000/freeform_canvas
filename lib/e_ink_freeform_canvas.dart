import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/renderers/e_ink_screen_renderer.dart';
import 'package:freeform_canvas/application/fundamental.dart';
import 'package:freeform_canvas/application/interactors/stylus_aware_interactor.dart';
import 'package:freeform_canvas/application/freeform_canvas_viewer.dart';
import 'package:freeform_canvas/core/editor_state.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import 'package:freeform_canvas/overlays/e_ink_toolbar.dart';
///**ZH** 适配墨水屏的画布编辑器组件，在 Bigme S6 上验证无误。
///
///**EN** Canvas editor component adapted to e-ink screens. Verified on Bigme S6.
class EInkFreeformCanvas extends StatefulWidget{

  final FreeformCanvasFile? file;

  final String? jsonString;

  final void Function(FreeformCanvasFile file)? onSave;

  final EditorState? editorState;

  const EInkFreeformCanvas({
    super.key, 
    this.file, 
    this.jsonString,
    this.onSave,
    this.editorState,
  }) : assert(
    (file==null ?1 :0) + (jsonString==null ?1 :0) + (editorState==null ?1 :0) == 2,
    'Provide file or jsonString or provide editorState'
  );
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
      editorState: widget.editorState,
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