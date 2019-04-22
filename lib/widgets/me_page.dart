import 'package:flutter/material.dart';

class MePage extends StatefulWidget{
  MePage({Key key}):
      super(key: key);
  @override
  State<MePage> createState() {
    // TODO: implement createState
    return MePageState();
  }
}

class MePageState extends State<MePage>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("About"),
        )
      ],
    );
  }
}