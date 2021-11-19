import 'dart:ui';
// import 'package:flash_chat_flutter/screens/chat_screen.dart';
import 'package:flash_chat_flutter/screens/alternate_chat_screen.dart';
// import 'package:flash_chat_flutter/screens/original_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class AllUsers extends StatefulWidget {
  static const String id = 'all_users'; //so i couldnt change it accidently

  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String contactName;
  String contactEmail;
  String contactImage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

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
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
//        title: Text('⚡️Chat'),
        title: Text(
          'All Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(height: 2),
            MessagesStream(),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('contacts').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final contacts = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var contact in contacts) {
          final contactName = contact.data['name'];
          final contactEmail = contact.data['email'];
          final contactImage = contact.data['profile pic'];
          print(contactImage);

          final messageBubble = MessageBubble(
            name: contactName,
            email: contactEmail,
            pic: contactImage,
          );
          if (contactEmail == loggedInUser.email) {
            // print(contactEmail);
          } else {
            messageBubbles.add(messageBubble);
          }
        }
        return Expanded(
          child: ListView(
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String name;
  final String email;
  final String pic;
  MessageBubble({this.name, this.email, this.pic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FlatButton(
          color: Colors.lightBlueAccent.shade100,
          padding: EdgeInsets.only(
            top: 3,
            bottom: 3,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(contactEmail: email, contactName: name),
              ),
            );
          },
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 6,
                  top: 4,
                  bottom: 4,
                ),
                child: CircleAvatar(
                  radius: 30,

                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(30),
                  //   child:profilePicUrl==null? Image.asset(
                  //     height: 45.0,
                  //     width: 45.0,
                  //   'assets/images/emoteU.png'
                  // ),
                  // Image.network(profilePicUrl,
                  //               height:45,
                  //               width:45)

                  // backgroundColor: Colors.brown,

                  backgroundImage: (pic != null)
                      ? NetworkImage(pic)
                      : AssetImage('images/default_person.png'),
                  // backgroundImage: AssetImage('images/default_person.png'),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                children: <Widget>[
                  Text(
                    name,
                    style: TextStyle(color: Colors.black, fontSize: 21),
                  ),
                  Text(
                    name,
                    style: TextStyle(color: Colors.black38, fontSize: 17),
                    //last message send
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 0,
          child: Divider(
            thickness: 1,
            color: Colors.black26,
          ),
        ),
      ],
    );
  }
}
