import 'dart:io';
import 'package:flash_chat_flutter/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {

  Future _getImage(ImageSource source1) async {
    File image = await ImagePicker.pickImage(source: source1, maxWidth: 400);
    setState(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegistrationScreen(imageFile: image,),
        ),
      );
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 155,
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an Image',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  textColor: Colors.orange,
                  child: Text(
                    'Use Camera',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _getImage(ImageSource.camera);
                  },
                ),
                FlatButton(
                  textColor: Colors.orange,
                  child: Text(
                    'Open Gallery',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _getImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 120.0),
      child: IconButton(
        onPressed: () {
          _openImagePicker(context);
        },
        icon: Icon(
          Icons.camera_alt,
          size: 30,
          color: Colors.black87,
        ),
      ),
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).accentColor;
    return OutlineButton(
      borderSide: BorderSide(
        color: buttonColor,
        width: 2,
      ),
      onPressed: () {
        _openImagePicker(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.camera_alt,
            color: Colors.pinkAccent,
          ),
          SizedBox(
            width: 20,
          ),

          Text(
            _image==null?'Add Image':'Add another Image',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
*/
}