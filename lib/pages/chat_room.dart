import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/chat_bubble.dart';
import 'package:powerstone/services/chat/chat_services.dart';

class ChatRoom extends StatelessWidget {
  final String img;
  final String username;
  final String reciverID;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ChatRoom(
      {super.key,
      required this.username,
      required this.reciverID,
      required this.img});
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(reciverID, _messageController.text);
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            (img.isNotEmpty || img != "nil")
                ? ClipOval(
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/img_not_found.jpg',
                      image: img,
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return const CircleAvatar(
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  )
                : const CircleAvatar(
                    child: Icon(
                      Icons.person_outline_rounded,
                      size: 40,
                    ),
                  ),
            const SizedBox(
              width: 10,
            ),
            Text(username),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            //display all messages
            Expanded(
              child: _buildMessageList(),
            ),

            //display user input
            _buildUserInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _auth.currentUser!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(reciverID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data['senderName'] == _auth.currentUser!.uid;

    //align msg to right when sender is current user or vice versa
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    String message = data["message"];
    return Container(
      alignment: alignment,
      child: ChatBubble(message: message, isCurrentUser: isCurrentUser),
    );
  }

  //build msg input
  Widget _buildUserInput(context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            style: Theme.of(context).textTheme.labelMedium,
            decoration: InputDecoration(
              hintText: "Enter Your Message",
              labelStyle: Theme.of(context).textTheme.labelSmall,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide:
                      const BorderSide(color: Colors.white, width: 0.5)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: Theme.of(context)
                      .primaryColor, // Border color when focused
                  width: 0.5,
                ),
              ),
            ),
          ),
        ),
        IconButton(
            onPressed: sendMessage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).primaryColor,
            ))
      ],
    );
  }
}
