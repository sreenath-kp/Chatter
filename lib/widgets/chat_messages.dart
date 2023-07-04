import 'package:chatter/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No messages',
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          );
        }
        if (chatSnapshot.hasError) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 30, left: 13, right: 13),
            physics: const BouncingScrollPhysics(),
            reverse: true,
            // itemCount: chatSnapshot.data!.size,
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessage['userId'];
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;

              final nextUserisSame = nextMessageUserId == currentMessageUserId;
              if (nextUserisSame) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: me.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: me.uid == currentMessageUserId,
                );
              }
            });
      },
    );
  }
}
