import 'package:flutter_tts/flutter_tts.dart';

/* 
 * Imporvements Needed
 * --------------------
 * [1] Run setHandlers() only when class created, 
 *     Now the setHandlers() function runs everytime the speak() is called
 */

class TextToSpeechFunction {
  final FlutterTts flutterTts = FlutterTts();
  bool speaking = false;
  
  setHandlers(){
    flutterTts.setStartHandler(() {
      speaking = true;
    });
    flutterTts.setCompletionHandler(() {
      speaking = false;
    });
    flutterTts.setErrorHandler((msg) {
      speaking = false;
    });
  }

  void speak(String text) async{
    setHandlers();
    if(!speaking){
      await flutterTts.setLanguage('en-US');
      await flutterTts.setPitch(1);
      await flutterTts.speak(text);
    }
  }
  void stop() async {
    var result = await flutterTts.stop();
    if (result == 1) { speaking = false; } 
  }
}