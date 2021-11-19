import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class OriginalChatScreen extends StatefulWidget {
  final String contactEmail;
  final String contactName;
  OriginalChatScreen({this.contactEmail,this.contactName});

  static const String id = 'original_chat_screen'; //so i couldnt change it accidently
  @override
  _OriginalChatScreenState createState() => _OriginalChatScreenState();
}

class _OriginalChatScreenState extends State<OriginalChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;
  String receiverEmail;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        print(OriginalChatScreen().contactEmail);
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
                //Implement logout functionality
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
            MessagesStream(sndrEml: widget.contactEmail),
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
                        _firestore.collection('messages').add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'timestamp':
                          DateTime.now().microsecondsSinceEpoch.toString(),
                        });
                      } else {
                        receiverEmail = widget.contactEmail;
                        _firestore.collection('messages').add({
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
  final String sndrEml;
  MessagesStream({this.sndrEml});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
//                else{
        final messages = snapshot.data.documents.reversed;
        /*List<Text> messageWidgets = [];
                for (var message in messages) {
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];
                  final messageWidget =
//                      Text('$messageText from $messageSender');
                  messageWidgets.add(messageWidget);*/
        List<MessageBubble> messageBubbles = [];
        if (sndrEml == 'groupChat') {
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
                messageReceiver == sndrEml) {
              messageBubbles.add(messageBubble);
            } else if (messageSender == sndrEml &&
                messageReceiver == loggedInUser.email) {
              messageBubbles.add(messageBubble);
            }
          }
        }

        /*return Column(
                   children: messageWidgets,
                );*/
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
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
//                topRight: 0,
            ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
//                '$text from $sender',
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
//            sender,
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
