import 'package:chatter/widgets/chat_messages.dart';
import 'package:chatter/widgets/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final ref =
        FirebaseStorage.instance.ref().child('User_images/$userid.jpeg');
    try {
      final geturl = await ref.getDownloadURL();
      setState(() {
        url = geturl;
      });
    } catch (e) {
      print('Failed to fetch profile. please login again.');
    }
  }

  void deleteDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: const LinearBorder(),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Do you really want to delete the account ?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      deleteAccount();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Yes'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    final userid = user!.uid;
    final ref =
        FirebaseStorage.instance.ref().child('User_images/$userid.jpeg');
    try {
      await ref.delete();
    } catch (e) {
      print('failed to delete image');
      print(e);
    }
    try {
      // delete chat history to do
      final chatRef = FirebaseFirestore.instance.collection('chat');

      await chatRef.where('userId', isEqualTo: userid).get().then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });
      await FirebaseFirestore.instance.collection('users').doc(userid).delete();
    } catch (e) {
      print('failed to delete chat history');
      print(e);
    }
    try {
      await user.delete();
    } catch (e) {
      print('failed to delete user');
      print(e);
    }
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
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'exit') {
                SystemNavigator.pop();
              }
              if (value == 'signout') {
                FirebaseAuth.instance.signOut();
              }
              if (value == 'delete') {
                deleteDialog();
              }
            },
            itemBuilder: (BuildContext bc) {
              return const [
                PopupMenuItem(
                  value: 'signout',
                  child: Text("Sign Out"),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text("Delete Account"),
                ),
                PopupMenuItem(
                  value: 'exit',
                  child: Text("Exit"),
                )
              ];
            },
          )
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
