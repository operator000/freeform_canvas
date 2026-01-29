import 'package:flutter/material.dart';
import 'embedded_file.dart';
import 'package:freeform_canvas/windows_freeform_canvas.dart';

void main() async {
  runApp(const FreeformCanvasExampleApp());
}

class FreeformCanvasExampleApp extends StatefulWidget {
  const FreeformCanvasExampleApp({super.key});

  @override
  State<FreeformCanvasExampleApp> createState() => _FreeformCanvasExampleAppState();
}

class _FreeformCanvasExampleAppState extends State<FreeformCanvasExampleApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreeformCanvas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
      ),
      home: Scaffold(
        body: FutureBuilder(
          future: Future.value(EMBEDDED), 
          builder: (context,snapshot){
            if(snapshot.hasData){
              return SafeArea(
                child: WindowsFreeformCanvas(
                  jsonString: snapshot.data,
                  onSave: (file) {
                    print('save...');
                  },
                )
              );
            }else{
              return Text('loading...');
            }
          }
        )
      ),
    );
  }
}