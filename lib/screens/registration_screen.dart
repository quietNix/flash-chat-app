import 'dart:io';
import 'login_screen.dart';
import 'package:flutter/material.dart';
import '../components/rounded_button.dart';
import '../utilities/images.dart';
import '../utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class RegistrationScreen extends StatefulWidget {
  final File imageFile;
  static const String id = 'registration_screen';
  RegistrationScreen({this.imageFile});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String myEmail;
  String myPassword;
  String myName;
  String downloadUrl;

  Future uploadPic(BuildContext context) async {
    String fileName = basename(widget.imageFile.path);
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    final StorageUploadTask uploadTask =
        storageReference.putFile(widget.imageFile);
    final StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    downloadUrl = await taskSnapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: SizedBox(
                  height: 15.0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 90,
                    backgroundColor: Colors.brown,
                    backgroundImage: (widget.imageFile != null) ?
                       FileImage(widget.imageFile) : AssetImage('images/default_person.png'),
                  ),
                  ImageInput(),
                ],
              ),
              Flexible(
                child: SizedBox(
                  height: 48.0,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  myName = value;
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your name'),
              ),
              Flexible(
                child: SizedBox(
                  height: 8.0,
                ),
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  myEmail = value;
                },
                decoration: kTextFieldDecoration,
              ),
              Flexible(
                child: SizedBox(
                  height: 8.0,
                ),
              ),
              TextField(
                obscureText: true,
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  myPassword = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              Flexible(
                child: SizedBox(
                  height: 8.0,
                ),
              ),
//              ImageInput(),
              Flexible(
                child: SizedBox(
                  height: 24.0,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RoundedButton(
                    colour: Colors.blueAccent,
                    text: 'Register',
                    onPress: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      if (myPassword != null && myEmail != null) {
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                            email: myEmail,
                            password: myPassword,
                          );
                          if(widget.imageFile != null) await uploadPic(context);
                          if (newUser != null) {
                            _firestore.collection('contacts').add({
                              'name': myName,
                              'email': myEmail,
                              'profile pic': downloadUrl,
                            });

                            Navigator.pushNamed(context, LoginScreen.id);
                          }
                          setState(() {
                            showSpinner = false;
                          });
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
