import 'package:flutter/material.dart';

class CenterTextPage extends StatelessWidget{
  String msg;
  CenterTextPage({Key key, @required this.msg}):
      super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text(msg),
    );
  }
}

class TimelineBlank extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('暂无内容，你可以到发现页订阅些内容源'),
    );
  }
}