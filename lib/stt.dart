import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show rootBundle;
import 'package:object_detection/tts_function.dart';
import 'package:object_detection/realtime/live_camera.dart';
import 'package:camera/camera.dart';

/* 
 * Imporvements Needed
 * --------------------
 * [1] Seperate the UI and Functional components of Speech-To-Text of this widget
 *     (Try to make a stt_function.dart similar to tts_function.dart)
 * [2] At line 100 for delay of execution of code, Fulture.delayed() is used,
 *     try to change it to async-await or .then
 * [3] speech_to_text package outputs realtime speech to conversion. Find a way to
 *     stop it.
 */

class SpeechScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  SpeechScreen(this.cameras);
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  dynamic tts = TextToSpeechFunction();
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the Screen and start speaking';
  double _confidence = 1.0;
  String _labels = "";
  List<String> commands = ["find me a ", "find me an ", "find me my ", "start object detection", "what is my location"];
  bool appStarted = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    loadLables();
  }

  // loads tflite model labels
  loadLables() async {
    String response;
    response = await rootBundle.loadString("assets/models/labels.txt");
    setState(() {
      _labels = response;
    });
    print("labels loaded now!");
  }

  // check whether object is in the tflite model
  findLabel(String object) {
    if (_labels != ""){
      if(_labels.indexOf(object) != -1){
        return true;
      } else {
        return false;
      }
    } else {
      print("Labels file not Loaded !!!!!!!");
      return null;
    }
  }

  dynamic cmdAnalyzer(String text) {
    print("Text Came for analyze: $text");
    String parameter="";
    int cmdIndex;


    // if speech valid, check for a voice command, if found finds (command,parameter)
    for(var i=0;i<commands.length;i++){
      if (text.indexOf(commands[i]) != -1){ 

        cmdIndex = i;
        parameter = text.substring(text.indexOf(commands[i])+commands[i].length, text.length);

        if(i<3 && parameter.length < 2){ 
          print("COMMAND INCOMPLETE (NOT ENOUGH PARAMETERS)");
          return null;
        }
        
        print("Command: "+commands[i]+", Parameter: $parameter");
      }
    }

    // if voice command valid executes the function
    if(cmdIndex == null){
      print("WRONG COMMAND !!!");
      setState(() {
        _text = "WRONG COMMAND !!!";
      });
      return null; // no command found
    } else {

      setState(() {
        _text = "";
      });

      if(cmdIndex < 3){ // object detection commands
        if(findLabel(parameter)){
          tts.speak("Starting object detection for $parameter");
          Future.delayed(const Duration(seconds: 3), ()=> {
            Navigator.push(context, MaterialPageRoute(
            builder: (context) => LiveFeed(widget.cameras, parameter, false),),
          )
          });
        } else {
          tts.speak("$parameter is not identifieble");
        }
      } else if(cmdIndex == 3){ // start raltime dtetction 
        tts.speak("starting realtime detection for all");
        Future.delayed(const Duration(seconds: 3), ()=> {
          Navigator.push(context, MaterialPageRoute(
              builder: (context) => LiveFeed(widget.cameras, "", true),),
          )
        });
      } else if(cmdIndex == 4){
        tts.speak("checking for your geo location");
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    if(!_isListening){
      if (appStarted){ // preventing unwanted running
        cmdAnalyzer(_text);
      }
    }
    return InkWell(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Icon((_isListening) ? Icons.mic:Icons.mic_none_outlined, size: 70,color: (_isListening) ? Colors.red[400]:Colors.grey,),
            Text("Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%"),
            // ElevatedButton(onPressed: (){print(_text);}, child: Text("Click Me")),
            Text(_text),
          ])
      ),
      onTap: () {
        print("inkwell pressed!");
        _listen();
      },
    );
  }

  void _listen() async {
    if(appStarted == false){
      setState(() {
        appStarted = true;
      });
    }
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => {
          if (val == "notListening"){
            setState((){
              _isListening = false;
            });
            print("Mic OFF");
          } else {
            print("Mic ON")
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}
