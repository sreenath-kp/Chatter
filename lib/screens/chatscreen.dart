import 'package:Chatter/widgets/chat_messages.dart';
import 'package:Chatter/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token = await fcm.getToken();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.teal[100],
        elevation: Theme.of(context).appBarTheme.scrolledUnderElevation,
        // title: const Text("Chatter"),
        // leadingWidth: 80,
        leading: const Padding(
          padding: EdgeInsets.all(5.0),
          child: CircleAvatar(
            radius: 60,
            foregroundImage: AssetImage('assets/icon.png'),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.secondary,
              ))
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          SizedBox(
            height: 5,
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
