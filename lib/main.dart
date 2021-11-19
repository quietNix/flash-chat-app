import 'package:flash_chat_flutter/screens/all_users.dart';
import 'package:flash_chat_flutter/screens/original_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat_flutter/screens/welcome_screen.dart';
import 'package:flash_chat_flutter/screens/login_screen.dart';
import 'package:flash_chat_flutter/screens/registration_screen.dart';
import 'package:flash_chat_flutter/screens/alternate_chat_screen.dart';

void main() => runApp(FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        AllUsers.id: (context) => AllUsers(),
        ChatScreen.id: (context) => ChatScreen(),
        OriginalChatScreen.id: (context) => OriginalChatScreen(),
      },
    );
  }
}
