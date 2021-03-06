import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:getwidget/getwidget.dart';
import 'package:rich_code_editor/exports.dart';

import '../constants.dart';
import '../syntax_highlighter.dart';

class EditArguments {
  final String ocrResult;
  EditArguments(this.ocrResult);
}

class EditScreen extends StatelessWidget {
  static final String routeName = "/edit";
  String ocrResult = "Error";
  @override
  Widget build(BuildContext context) {
    final EditArguments routeParams = ModalRoute.of(context).settings.arguments;
    try {
      ocrResult = routeParams.ocrResult;
    } catch (e) {
      print(e);
    }
    return DemoCodeEditor(ocrResult);
  }
}

class DemoCodeEditor extends StatefulWidget {
  final String ocrResult;
  DemoCodeEditor(this.ocrResult);
  @override
  _DemoCodeEditorState createState() => _DemoCodeEditorState(ocrResult);
}

class _DemoCodeEditorState extends State<DemoCodeEditor> {
  RichCodeEditingController _rec;
  SyntaxHighlighterBase _syntaxHighlighterBase;

  final String ocrResult;
  String _codeToExec;
  _DemoCodeEditorState(this.ocrResult);

  @override
  void initState() {
    super.initState();
    _syntaxHighlighterBase = SyntaxHighlighter();
    _rec = RichCodeEditingController(_syntaxHighlighterBase, text: ocrResult);
  }

  @override
  Widget build(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Your snippet has been succesfully saved.'),
    );

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.backgroundColor,
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: TextField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelText: "Snippet Name",
                          hintText: "DragonHeSnippet3",
                          hintStyle: TextStyle(
                            color: Colors.white30,
                          ),
                          helperStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.all(24.0),
                        padding: EdgeInsets.all(24.0),
                        decoration:
                            new BoxDecoration(border: new Border.all(color: Colors.grey)),
                        child: RichCodeField(
                          autofocus: true,
                          controller: _rec,
                          textCapitalization: TextCapitalization.none,
                          syntaxHighlighter: _syntaxHighlighterBase,
                          decoration: null,
                          maxLines: null,
                          onChanged: (String s) {},
                          onBackSpacePress: (TextEditingValue oldValue) {},
                          onEnterPress: (TextEditingValue oldValue) {
                            var result = _syntaxHighlighterBase.onEnterPress(oldValue);
                            if (result != null) {
                              _rec.value = result;
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: GFButton(
                            onPressed: () {
                              executeCode();
                            },
                            text: "Execute",
                            icon: Icon(Icons.code),
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            color: GFColors.PRIMARY,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: GFButton(
                            onPressed: () {
                              Scaffold.of(context).showSnackBar(snackBar);
                            },
                            text: "Save",
                            icon: Icon(Icons.save),
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            color: GFColors.SUCCESS,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "Code Output:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _execOutput,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _execOutput = "";

  Future executeCode() async {
    Dio dio = new Dio();
    var response = await dio.post(
      "https://photo-code-web.herokuapp.com/run",
      data: {
        "code": _rec.text,
      },
    );
    if (this.mounted) {
      setState(() {
        print(response.data);
        _execOutput = response.data["output"].toString();
      });
    }
  }
}
