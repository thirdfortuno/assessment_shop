import 'package:flutter/material.dart';

class OwnerScaffold extends StatelessWidget{
  OwnerScaffold({Key key, this.title, this.body}) : super(key: key);

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(30.0),
        child: AppBar(
          title: Text(
            title,
          ),
          primary: false,
        ),
      ),
      body: body,
    );
  }
}