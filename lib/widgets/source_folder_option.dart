import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';

class SourceFolderOption extends StatefulWidget{
  final String sourceFolderName;
  SourceFolderOption({Key key, @required this.sourceFolderName}):
      super(key: key);
  @override
  State<SourceFolderOption> createState() {
    // TODO: implement createState
    return SourceFolderOptionState();
  }
}

class SourceFolderOptionState extends State<SourceFolderOption> {
  String get _sourceFolderName => widget.sourceFolderName;
  @override
  Widget build(BuildContext context) {
    final sourceFolderBloc = BlocProvider.of<SourceFolderBloc>(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(_sourceFolderName),
        ),
        Divider(),
        ListTile(
          title: Text('重命名分组'),
          onTap: () {
            TextEditingController _textFieldController = TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('重命名分组'),
                    content: TextField(
                      controller: _textFieldController,
                      decoration: InputDecoration(hintText: "分组新名称"),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text('确定'),
                        onPressed: () {
                          if (!SharedFuctions.inputIllegal(_textFieldController.text)) {
                            sourceFolderBloc.dispatch(RenameSourceFolder(oldFolder: _sourceFolderName, newFolder: _textFieldController.text));
                          }
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        ),
        ListTile(
          title: Text('删除分组'),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('删除分组'),
                    content: Text('确定删除分组\"' + _sourceFolderName + "\"?（该分组内的订阅源将归属默认分组）"),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text('取消'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text('确定'),
                        onPressed: () {
                          sourceFolderBloc.sourceFoldersRepository.deleteSourceFolder(_sourceFolderName);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
          },
        ),
      ],
    );
  }
}