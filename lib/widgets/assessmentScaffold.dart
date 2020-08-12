import 'package:flutter/material.dart';

class AssessmentScaffold extends StatelessWidget{
  AssessmentScaffold({Key key, this.title, this.body}) : super(key: key);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: Text(
            title,
          ),
          primary: false,
        ),
      body: body,
    );
  }
}