import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:photo_gallery_flutter/screens/image_screen.dart';
import 'package:photo_gallery_flutter/services%20/network_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoGallery extends StatefulWidget {

  static const String id = 'photo_gallery_screen';

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {

  bool _isDataReady;
  String _pixabyAPIKey = "18455598-c544191a765c50de1cf2bdf58";
  int _pageNumber = 1;

  List<String> images = [];

  bool _allImagesAreLoaded = false;
  bool _allImagesAreLoadedFromSharedPreferences = false;

  ScrollController _scrollController;

   _saveImages() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.setStringList("images", images);
     print("Images saved");
  }

  _scrollListener() {

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange && _scrollController.position.userScrollDirection == ScrollDirection.reverse) {

      setState(() {

        print("user scrolled in ${_scrollController.position.userScrollDirection} direction");

        if (images.length == 40) {

          //images are saved only once (when all 40 images are downloaded from internet)
          if (_allImagesAreLoadedFromSharedPreferences == false) {
            _saveImages();
            _allImagesAreLoadedFromSharedPreferences = true;
           // _allImagesAreLoaded = true;
          }

          _allImagesAreLoaded = true;

        } else {
          //every page has 10 images
          _pageNumber++;
          getImagesFromPixaby();
        }

      });

    }
  }

  void getImagesFromPixaby() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var storedImages = prefs.getStringList("images");
    //checking if there is a stored images array(if images were previously downloaded)
    if (storedImages != [] && storedImages != null && _allImagesAreLoadedFromSharedPreferences == false) {

      images = storedImages;
      _allImagesAreLoadedFromSharedPreferences = true;
      print("Images were already downloaded");

    } else {

      setState(() {
      _isDataReady = false;
      });

      String url = "https://pixabay.com/api/?key=$_pixabyAPIKey&image_type=photo&per_page=10&page=$_pageNumber";

      NetworkHelper networkHelper = NetworkHelper(url: url);

      dynamic data;

      data = await networkHelper.getData();

      if (images.length < 40) {

        print("downloading new batch from internet...");

        for (var i = 0; i < 10; i++) {
          images.add(data["hits"][i]["largeImageURL"]);
        }
      }
    }

    setState(() {
      _isDataReady = true;
    });

  }


  @override
  void initState() {
    //adding controller to gridView to lazily load the images
    super.initState();

    setState(() {
      _isDataReady = false;
    });

    _scrollController = new ScrollController()
      ..addListener(_scrollListener);

     getImagesFromPixaby();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
      child:  Padding(
        padding: EdgeInsets.all(8),

  child: new CustomScrollView(
      controller: _scrollController,
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: <Widget>[
        new SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
          delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                imageBuilder: (context, imageProvider) => GestureDetector(
                  onTap: () {
                    //if image is loaded we go to ImageScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ImageScreen(image: imageProvider)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                  child: Container(
                    margin: EdgeInsets.all(25),
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.broken_image),
              );
            },
            childCount: images.length,
          ),
        ),
        new SliverToBoxAdapter(
          child: _allImagesAreLoaded ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("end of story:(",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),) ,
          ) : Container(),
        ),
        new SliverToBoxAdapter(
          child: !_isDataReady ? Padding(
            padding: const EdgeInsets.all(5.0),
            child: Center(
              child: Container(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black26),)),
            ) ,
          ) : Container(),
        ),
      ]),
      )
      ),
    );
  }
}
