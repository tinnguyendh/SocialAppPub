import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:insta2/screens/chatbotAi/consts.dart';
import 'package:insta2/screens/chatbotAi/model_Gpt.dart';
import 'package:http/http.dart' as http;
import 'package:insta2/screens/chatbotAi/threedots.dart';

const backgroundColor = Color(0xff343541);
const botbackgroundColor = Color(0xff444654);

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessages> _messages = [];
  StreamSubscription? connectivityStream;
  late bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
  }

  //  giao tiếp với API OpenAI và tạo ra một câu trả lời dựa trên 
  //một prompt cho trước. Nó gửi một yêu cầu HTTP POST đến 
  //API OpenAI với các tham số cần thiết và trả về văn bản được tạo ra.

  Future<String> generateResponse(String prompt) async {
    final apiKey = OPENAI_KEY;
    var url = Uri.https("api.openai.com", "/v1/completions");
    // try {
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        },
        body: jsonEncode({
          "model": "text-davinci-003",
          "prompt": prompt,
          'temperature': 0,
          'max_tokens': 2000,
          'top_p': 1,
          'frequency_penalty': 0.0,
          'presence_penalty': 0.0,
        }));
    //   ResponseData newresponse = ResponseData.fromJson(response);
    //   successORFailure = right(newresponse);
    // } on NetworkFailure catch (e) {
    //   successORFailure = left(e);
    // }

    Map<String, dynamic> newresponse = jsonDecode(response.body);

    return newresponse['choices'][0]['text'];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "OpenAI's ChatGPT Flutter ",
            maxLines: 2,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: botbackgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: _buildList(),
          ),
          Visibility(
            visible: isLoading,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: 
              // CircularProgressIndicator(
              //   color: Colors.white,
              // ),
              ThreeDots(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _buildInput(),
                _buildSubmit(),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Expanded _buildInput() {
    return Expanded(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: Colors.white),
        controller: _textController,
        decoration: const InputDecoration(
          fillColor: botbackgroundColor,
          filled: true,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmit() {
    // return Builder(builder: (context) {
    return Visibility(
      visible: !isLoading,
      child: Container(
        color: botbackgroundColor,
        child: IconButton(
          icon: const Icon(
            Icons.send_rounded,
            color: Color.fromRGBO(142, 142, 160, 1),
          ),
          onPressed: () async {
            // context.read<ChatBloc>().add(
            //       ChatEvent.submitChat(_textController.text),
            //     );
            // Thêm tin nhắn mới từ người dùng vào danh sách
            setState(() {
              _messages.add(ChatMessages(
                  text: _textController.text,
                  chatMessageType: ChatMessageType.user));
              isLoading = true;
            });

            var input = _textController.text;
            _textController.clear();

            // Cuộn xuống dưới cùng của danh sách
            Future.delayed(const Duration(milliseconds: 50))
                .then((value) => _scrollDown);

            //call api
            // Gửi yêu cầu đến OpenAI để nhận câu trả lời từ mô hình
            generateResponse(input).then((value) {
              setState(() {
                isLoading = false;
                // Thêm tin nhắn mới từ bot vào danh sách
                _messages.add(ChatMessages(
                    text: value, chatMessageType: ChatMessageType.bot));
              });
            });
            _textController.clear();
            Future.delayed(const Duration(milliseconds: 50))
                .then((value) => _scrollDown);
          },
        ),
      ),
    );
    // });
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 50),
      curve: Curves.easeOut,
    );
  }

  ListView _buildList() {
    return ListView.builder(
      itemCount: _messages.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(
          text: message.text,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.text, required this.chatMessageType});

  final String text;
  final ChatMessageType chatMessageType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      padding: const EdgeInsets.all(16),
      color: chatMessageType == ChatMessageType.bot
          ? botbackgroundColor
          : backgroundColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chatMessageType == ChatMessageType.bot
              ? Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: CircleAvatar(
                    backgroundColor:
                        // const Color.fromRGBO(16, 163, 127, 1)
                        botbackgroundColor,
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/insta-d9db8.appspot.com/o/post%2FCNxmD3wjSLYBx2pFeNMskOka6k43%2F16aa67a0-7284-11ee-b907-85e4ce7f3465?alt=media&token=e6c46a91-cc88-4e03-b317-e241d7e862d4',
                      scale: 1.5,
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: const CircleAvatar(
                    child: Icon(
                      Icons.person,
                    ),
                  ),
                ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  child: Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
