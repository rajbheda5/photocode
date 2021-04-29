import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/constants.dart';
import 'package:mobile/screens/edit_screen.dart';
import 'package:platform_action_sheet/platform_action_sheet.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class PhotoScreen extends StatefulWidget {
  static const routeName = '/photo';
  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  File _image;

  String _selectedLanguage = "Javascript";

  Dio dio = new Dio();
  final imgBBkey = '430884ee402612043810c42ec4bca070';
  String imgURL = '';
  String code = '';

  Future<void> uploadImageFile(File _image) async {
    // ByteData bytes = await rootBundle.load(_image.path);
    final ByteData bytes = _image.readAsBytesSync().buffer.asByteData();
    var buffer = bytes.buffer;
    var m = base64.encode(Uint8List.view(buffer));

    FormData formData =
        FormData.fromMap({"key": imgBBkey, "image": m, "expiration": 3600});

    final Response response = await dio.post(
      "https://api.imgbb.com/1/upload",
      data: formData,
    );
    print(response.data['data']['url']);

    imgURL = response.data['data']['url'];
    if (imgURL != '') {
      ocrResult(imgURL);
    }
  }

  void ocrResult(String url) async {
    // FormData formData = FormData.fromMap({"url": imgURL});
    final response = await dio.post(
      "http://192.168.0.106:8080/OCR",
      data: {"url": url},
    );
    if (response.statusCode == 200) {
      print('OCR Received');
      print(response.data);
      setState(() {
        code = response.data;
      });
    } else
      code = '';
  }

  Future getImage(ImageSource source, BuildContext context) async {
    var input = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = File(input.path);
    });
    await uploadImageFile(_image);
    //print(code);
    Navigator.pop(context);
    // FormData formData = new FormData.fromMap({
    //   "image": await MultipartFile.fromFile(
    //     image.path,
    //     filename: image.path.split('/').last,
    //   ),
    // });
    //var imgBBLink = await dio.post("https://api.imgbb.com/1/upload?expiration=600&key=YOUR_CLIENT_API_KEY" --form "image=R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
    // var response = await dio.post("https://photo-code-web.herokuapp.com/scan",
    //     data: formData);
    // setState(() {
    //   _image = image;
    //   _ocrResult = response.data["code"].toString();
    // });
  }

  void openSheet() {
    PlatformActionSheet().displaySheet(context: context, actions: [
      ActionSheetAction(
        text: "Take Picture",
        onPressed: () => getImage(ImageSource.camera, context),
      ),
      ActionSheetAction(
        text: "Choose picture from gallery",
        onPressed: () => getImage(ImageSource.gallery, context),
      ),
    ]);
  }

  void openEditor() {
    Navigator.pushNamed(
      context,
      EditScreen.routeName,
      arguments: EditArguments(code),
    );
  }

  void changeLanguage(String newSelection) {
    if (mounted) {
      setState(() {
        _selectedLanguage = newSelection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(40, 0, 40, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 4),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
              child: _image != null
                  ? Image.file(_image, fit: BoxFit.contain)
                  : null,
            ),
            Spacer(),
            GFButton(
              onPressed: openSheet,
              fullWidthButton: true,
              shape: GFButtonShape.pills,
              color: Constants.barBackgroundColor,
              size: GFSize.LARGE,
              child: Text("Select Image",
                  style: TextStyle(color: Constants.accentColor)),
            ),
            Spacer(),
            GFButton(
              onPressed: openEditor,
              fullWidthButton: true,
              shape: GFButtonShape.pills,
              color: Constants.barBackgroundColor,
              size: GFSize.LARGE,
              child: Text("Process Image",
                  style: TextStyle(color: Constants.accentColor)),
            ),
            Spacer(),
            DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Constants.barBackgroundColor,
                items: <String>['Javascript', 'More coming soon...']
                    .map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: TextStyle(color: Constants.accentColor)),
                  );
                }).toList(),
                onChanged: (newSelection) {
                  changeLanguage(newSelection);
                }),
            Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
