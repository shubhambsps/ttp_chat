import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/theme/style.dart';

class ChatErrorScreen extends StatefulWidget {
  const ChatErrorScreen({Key? key}) : super(key: key);

  @override
  _ChatErrorScreenState createState() => _ChatErrorScreenState();
}

class _ChatErrorScreenState extends State<ChatErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: startChatMessageWidget());
  }

  Widget startChatMessageWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/chat_icons/chat_error.svg',
          ),
          const SizedBox(height: 20),
          Text(
            'Don’t panic. Something’s up with your account.',
            style: appBarTitleStyle(context).copyWith(fontSize: 22),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'There seems to be an issue with your account. Get in touch with Tabletop Support and we’ll get it sorted as soon as we can.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FlatButton.icon(
            icon: SvgPicture.asset(
              'assets/chat_icons/contact_support.svg',
              height: 15,
              width: 20,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            label: const Text('Contact Support'),
            color: Theme.of(context).accentColor,
            textColor: Theme.of(context).scaffoldBackgroundColor,
            onPressed: () {},
            minWidth: MediaQuery.of(context).size.width,
            height: 42,
          ),
        ],
      ),
    );
  }
}
