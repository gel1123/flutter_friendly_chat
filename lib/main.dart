import 'package:flutter/material.dart';

/// mainであり、ホットリロード不可。
/// なので、ホットリロードさせたいコンポーネントは外部化させて、mainから呼び出す形式にする。
void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

/// このチャットアプリの利用者名（つまり送信者）。
/// 一般的なアプリなら認証などから名前を取るはずだが、
/// チュートリアルアプリなので、ここは簡易的に固定で名前をもつことにしている。
String _name = "gel1123";

/// man#runAppに引数として渡すアプリ/// Statelessであり、単にMaterialAppとして後述のChatScreenをコールする
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

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required this.text,
    required this.animationController,
    Key? key,
  }) : super(key: key);

  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
      axisAlignment: 0.0,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(child: Text(_name[0])),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_name, style: Theme.of(context).textTheme.headline4),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                )
              ])
            ],
          )),
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
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _handleSubmitted(String text) {
    _textController.clear();

    // vsyncはアニメーションにおけるハートビートの役割。
    // TickerProviderStateMixinを含む自分自身をvsyncの対象としてセットしている。
    var animationController = AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
    );

    var message = ChatMessage(
      text: text,
      animationController: animationController,
    );
    setState(() {
      _messages.insert(0, message);
    });
    // submit後もテキスト入力フォームにフォーカスし続ける
    _focusNode.requestFocus();
    // animation実行
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("FriendlyChat State")),
        body: Column(
          children: [
            Flexible( // Column内で他要素を阻害しない範囲まで高さを広げる
              child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, index) => _messages[index],
                  itemCount: _messages.length),
            ),
            const Divider(height: 1.0), // 区切り線
            Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer())
          ],
        ));
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
              focusNode: _focusNode,
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

  // アニメーションの破棄を行うメソッド（ミックスインから呼び出される）
  // リソース解放忘れで...なんてことが起きないよう、
  // ちゃんとオーバーライドして定義しておくのが妥当と思われる。
  // ※superの破棄まで忘れずに
  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
