import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:object_detection/stt.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  // initialize the cameras when the app starts
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  // running the app
  runApp(
    MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
    )
  );
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Object Detector App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: aboutDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("Commands", style: TextStyle(
                  color: Colors.red[800],
                  height: 5,
                  fontSize: 25,
                  //decoration: TextDecoration.underline,
                  //decorationColor: Colors.black,
                ),),
                Text("Find me a/an/my x", style: TextStyle(fontSize: 16,),),
                Text("Start object detection", style: TextStyle(fontSize: 16,),),
              ],
            ),
          ),
          SpeechScreen(cameras),
        ],
      )
    );
  }

  aboutDialog(){
     showAboutDialog(
      context: context,
      applicationName: "Object Detector App",
      applicationLegalese: "By IEDC Cet",
      applicationVersion: "1.0",
      children: <Widget>[
        Text("www.iedc.cet..ac.in"),
      ],
    );
  }

}