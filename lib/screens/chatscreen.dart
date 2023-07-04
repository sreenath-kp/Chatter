import 'package:chatter/widgets/chat_messages.dart';
import 'package:chatter/widgets/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? url;
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
    getUrl();
  }

  void getUrl() async {
    final userid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance
        .ref()
        .child('User_images')
        .child('$userid.jpeg');
    final geturl = (await ref.getDownloadURL()).toString();
    setState(() {
      url = geturl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.teal[100],
        elevation: Theme.of(context).appBarTheme.scrolledUnderElevation,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: CircleAvatar(
            foregroundImage: url != null ? NetworkImage(url!) : null,
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
