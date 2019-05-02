import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourceOption extends StatefulWidget{
  final String sourceName;
  final int sourceId;
  SourceOption({Key key, @required this.sourceName, @required this.sourceId}):
        super(key: key);
  @override
  State<SourceOption> createState() {
    // TODO: implement createState
    return SourceOptionState();
  }
}

class SourceOptionState extends State<SourceOption> {
  String get _sourceName => widget.sourceName;
  int get _sourceId => widget.sourceId;
  @override
  Widget build(BuildContext context) {
    final sourceBloc = BlocProvider.of<SourceBloc>(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(_sourceName),
        ),
        Divider(),
        ListTile(
          title: Text('编辑分组'),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return MyDialog(sourceId: sourceBloc.sourcesRepository.sourceId, sourceName: sourceBloc.sourcesRepository.sourceName,);
                }
            );
          },
        ),
        ListTile(
          title: Text('退订'),
          onTap: () {
            sourceBloc.dispatch(UnfollowSource(sourceId: _sourceId));
          },
        ),
      ],
    );
  }
}