//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String loggedInUserEmail;

class ChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactName;
  ChatScreen({this.contactEmail, this.contactName});

  static const String id = 'chat_screen'; //so i couldnt change it accidently
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  String receiverEmail;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        loggedInUserEmail = loggedInUser.email;
      }
    } catch (e) {
      print(e);
    }
  }

/*  void getMessages() async {
    final messages = await _firestore.collection('messages').getDocuments();
    for(var message in messages.documents){
      print(message.data);
    }
  }*/

/*  void messageStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
//                     getMessages();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text(widget.contactName),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(
              senderEmail: widget.contactEmail,
              currentUserEmail: (widget.contactEmail == 'groupChat')
                  ? 'groupMessages'
                  : loggedInUserEmail,
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      if (widget.contactEmail == 'groupChat') {
                        _firestore.collection('groupMessages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timestamp':
                              DateTime.now().microsecondsSinceEpoch.toString(),
                        });
                      } else {
                        receiverEmail = widget.contactEmail;
                        _firestore.collection('$loggedInUserEmail').add({
                          'text': messageText,
                          'receiver': receiverEmail,
                          'sender': loggedInUser.email,
                          'timestamp':
                              DateTime.now().microsecondsSinceEpoch.toString(),
                        });
                        _firestore.collection('$receiverEmail').add({
                          'text': messageText,
                          'receiver': receiverEmail,
                          'sender': loggedInUser.email,
                          'timestamp':
                              DateTime.now().microsecondsSinceEpoch.toString(),
                        });
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String senderEmail;
  final currentUserEmail;
  MessagesStream({this.senderEmail, this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('$currentUserEmail')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          if (senderEmail == 'groupChat') {
            for (var message in messages) {
              final messageSender = message.data['sender'];
              final messageText = message.data['text'];
              final messageTime = message.data['timestamp'];
              final currentUser = loggedInUser.email;
              final messageReceiver = message.data['receiver'];

              final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                time: messageTime,
                isMe: currentUser == messageSender,
              );
              if (messageReceiver == null) {
                messageBubbles.add(messageBubble);
              }
            }
          } else {
            for (var message in messages) {
              final messageSender = message.data['sender'];
              final messageText = message.data['text'];
              final messageTime = message.data['timestamp'];
              final currentUser = loggedInUser.email;
              final messageReceiver = message.data['receiver'];

              final messageBubble = MessageBubble(
                sender: messageSender,
                text: messageText,
                time: messageTime,
                isMe: currentUser == messageSender,
              );
              if (messageSender == loggedInUser.email &&
                  messageReceiver == senderEmail) {
                messageBubbles.add(messageBubble);
              } else if (messageSender == senderEmail &&
                  messageReceiver == loggedInUser.email) {
                messageBubbles.add(messageBubble);
              }
            }
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final String time;
  MessageBubble({this.sender, this.text, this.isMe, this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                  fontSize: 18,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
