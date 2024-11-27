import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Platform;
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel model ;
  final List<String> _sent = [];

  void _handleSubmitted(input) async {
    if (input is String) {
      // Handle text input
      _controller.clear();
      ChatMessage userMessage = ChatMessage(
        text: input,
        isUserMessage: true,
      );
      setState(() {
        _messages.insert(0, userMessage);
      });
      _sent.add(input);
      final model1='gemini-pro';
      final model = GenerativeModel(model: model1, apiKey: 'AIzaSyDquV0aGKlMl6vNIXMDFbvV1pfPW7kUQ4E');
      final chat=model.startChat(history: [
    Content.text("""Overall Goal: Be a supportive friend and companion who offers evidence-based advice and strategies for managing ASD symptoms.

Personality: Approachable, positive, patient, and understanding.

Communication Style:
- Simple and Clear Language: Avoid jargon and complex sentence structures.
- Open-Ended Questions: Encourage elaboration and exploration of topics.
- Positive Reinforcement: Celebrate victories, no matter how small.
- Visual Aids (Optional): Consider offering emojis, pictures, or short videos to illustrate concepts.
- Respectful of Individual Preferences: Don't force interactions or communication styles that cause discomfort.

Focus Areas:
- Understanding Emotions: Help identify and express emotions healthily.
- Social Interaction: Offer tips for navigating social situations and building relationships.
- Sensory Processing: Discuss coping mechanisms for managing sensory overload or sensitivities.
- Routine & Structure: Explore strategies for creating predictability and managing changes.
- Interests & Strengths: Celebrate unique talents and passions.

Safety and Resources:
- Avoid Medical Advice: Acknowledge limitations and encourage connecting with qualified professionals."""
),
    Content.model([TextPart('Great to meet you. What would you like to know?')])
  ]);
    GenerateContentResponse botResponse = await chat.sendMessage(Content.text(input));
    final response=botResponse.text ??' no respone ';
    // Display bot response in the chat UI
    ChatMessage botMessage = ChatMessage(
      text: response,
      isUserMessage: false,
    );
    setState(() {
      _messages.insert(0, botMessage);
    });
  
      // Send text to the model and display response in chat UI
    } else if (input is File) {
      print('image');
      ChatMessage userMessage = ChatMessage(
        imageFile: input,
        isUserMessage: true,
      );
      setState(() {
        _messages.insert(0, userMessage);
      });
      const model1='gemini-pro-vision';
      final model = GenerativeModel(model: model1, apiKey: 'AIzaSyDquV0aGKlMl6vNIXMDFbvV1pfPW7kUQ4E');
      final (firstImage) =await input.readAsBytes();
  final prompt = TextPart("What's in this pictures?");
  final imageParts = DataPart('image/jpeg', firstImage);
  final response = await model.generateContent([
    Content.multi([prompt,imageParts])
  ]);
  //print(response.text);
  ChatMessage botMessage = ChatMessage(
      text: response.text ??'No response',
      isUserMessage: false,
    );
    setState(() {
      _messages.insert(0, botMessage);
    });
    }
  }
    //final model = GenerativeModel(model: model1, apiKey: 'AIzaSyDquV0aGKlMl6vNIXMDFbvV1pfPW7kUQ4E');
  void _getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      _handleSubmitted(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _messages[index],
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Colors.amberAccent),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _controller,
                onSubmitted: _handleSubmitted,
                decoration:
                    InputDecoration.collapsed(hintText: 'Send a message'),
              ),
            ),
            Container(margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.upload),
                onPressed: () => _getImage(ImageSource.gallery), //////////PhotoUploadScreen()
              ),),
              SizedBox(width:10),
            Container(margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.camera),
                onPressed: () => _getImage(ImageSource.camera), //////////PhotoUploadScreen()
              ),),
              SizedBox(width:10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _handleSubmitted(_controller.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String? text;
  final bool isUserMessage;
  final File? imageFile;

  ChatMessage({this.imageFile,this.text, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          isUserMessage
              ? Container(
                  margin: EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    child: Text('User'),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                isUserMessage
                    ? Container()
                    : Text(
                        'Chatbot',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: Text(text ?? ""),
                  ),
                imageFile != null
                    ? Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: Image.file(imageFile!),
                      )
                    : Container(),
             
              ],
            ),
          ),
        ],
      ),
    );
  }
}


