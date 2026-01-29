import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/e_ink_screen_renderer.dart';
import 'package:freeform_canvas/application/foundamental.dart';
import 'package:freeform_canvas/application/stylus_aware_interactor.dart';
import 'package:freeform_canvas/freeform_canvas_viewer.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import 'package:freeform_canvas/overlays/e_ink_toolbar.dart';
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