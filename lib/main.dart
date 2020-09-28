import 'package:flutter/material.dart';
import 'package:photo_gallery_flutter/screens/gallery_screen.dart';
import 'package:photo_gallery_flutter/screens/image_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: PhotoGallery.id,
      routes: {
        PhotoGallery.id: (context) => PhotoGallery(),
        ImageScreen.id: (context) => ImageScreen(),
      }
    );
  }
}