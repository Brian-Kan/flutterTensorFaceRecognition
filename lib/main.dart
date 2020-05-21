// import 'dart:html';

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';

void main(){
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading;
  File _image;
  List _output;

 @override
  void initState() {
    super.initState();
    _isLoading = true;
    loadMLModel().then((value){
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ml with Flutter")
      ),
      body: _isLoading ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ) : Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Container():Image.file(_image),
            SizedBox(height: 16,),
            _output == null ? Text(""): Text(
              "${_output[0]["label"]}"
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          chooseImage();
        },
        child: Icon(
          Icons.image
        )
      ),
    );
  }  

  // This function chooses and image.
  chooseImage() async{
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if(image == null) return null;
    setState((){
      _isLoading = true;
      _image = image;
    });
    runModelOnImage(image);
  }

  runModelOnImage(File image) async{
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      imageMean: 127.5,
      imageStd: 127.5,
      threshold: 0.5
    );
    setState((){
      _isLoading = false;
      _output = output;
    });
  }

  // This function loads the image.
  loadMLModel() async{
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt"
    );
  }

}