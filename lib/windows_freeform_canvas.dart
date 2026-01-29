import 'package:flutter/material.dart';
import 'package:freeform_canvas/application/canvas_renderer.dart';
import 'package:freeform_canvas/application/foundamental.dart';
import 'package:freeform_canvas/application/mouse_keyboard_interactor.dart';
import 'package:freeform_canvas/freeform_canvas_viewer.dart';
import 'package:freeform_canvas/models/freeform_canvas_file.dart';
import 'package:freeform_canvas/overlays/windows_toolbar.dart';
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