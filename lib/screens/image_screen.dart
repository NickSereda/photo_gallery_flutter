import 'package:flutter/material.dart';


class ImageScreen extends StatelessWidget {

  static const String id = 'image_screen';

  ImageScreen({this.image});

  ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image")),

    body: Container(

      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,

      child: FittedBox(
        fit: BoxFit.cover,
        child: Image(
          image: image,
        ),
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
    onPressed: () {
      print("Share this image");
    },
      label: Text("Share"),
      icon: Icon(Icons.share),
    backgroundColor: Colors.white,
    ),
    );
  }
}

