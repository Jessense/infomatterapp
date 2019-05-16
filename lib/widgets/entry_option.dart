import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:share/share.dart';

class EntryOption extends StatefulWidget{
  final Entry entry;
  final int index;
  EntryOption({Key key, @required this.entry, @required this.index}):
      super(key: key);
  @override
  State<EntryOption> createState() {
    // TODO: implement createState
    return EntryOptionState();
  }
}

class EntryOptionState extends State<EntryOption>{
  Entry get _entry => widget.entry;
  int get _index => widget.index;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.arrow_upward),
          title: Text('将以上标记为已读'),
          onTap: () {
            BlocProvider.of<EntryBloc>(context).entriesRepository.markAsRead(_index);
          },
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text('分享'),
          onTap: () {
            Share.share(_entry.title + '\n' + _entry.link);
          },
        )
      ],
    );
  }
}