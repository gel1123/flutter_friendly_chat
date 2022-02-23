import 'package:flutter/material.dart';

/// mainであり、ホットリロード不可。
/// なので、ホットリロードさせたいコンポーネントは外部化させて、mainから呼び出す形式にする。
void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

/// main#runAppに引数として渡すアプリケーション。
/// Statelessであり、単にMaterialAppとして後述のChatScreenをコールする
class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "FriendlyChat App",
      home: ChatScreen(),
    );
  }
}

/// Chat画面そのものである、Statefulなコンポーネント。
/// 状態とそれに紐づく画面部品をもつ、_ChatScreenStateを生成する。
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

/// * 保有する状態：テキスト入力部品
/// * 可能な操作：入力した内容のsubmit
/// * ビルドするもの：ヘッダ（AppBar）と本文（入力フォーム）
class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FriendlyChat State")),
      body: _buildTextComposer(),
    );
  }

  /// 端末側で設定されているテーマをBuildContext経由で取得し、
  /// そのテーマに基づいたアクセントカラーをIconTheme.dataとしてセッティングしている。
  /// さらにアクセントカラーの適用範囲内に、入力フォームを内包化させ、
  /// ビルド生成物としてreturnしている。
  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
                child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message."),
            )),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
