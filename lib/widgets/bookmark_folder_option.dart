import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';

class BookmarkFolderOption extends StatefulWidget{
  final String bookmarkFolderName;
  BookmarkFolderOption({Key key, @required this.bookmarkFolderName}):
        super(key: key);
  @override
  State<BookmarkFolderOption> createState() {
    // TODO: implement createState
    return BookmarkFolderOptionState();
  }
}

class BookmarkFolderOptionState extends State<BookmarkFolderOption> {
  String get _bookmarkFolderName => widget.bookmarkFolderName;
  @override
  Widget build(BuildContext context) {
    final bookmarkFolderBloc = BlocProvider.of<BookmarkFolderBloc>(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(_bookmarkFolderName),
        ),
        Divider(),
        ListTile(
          title: Text('重命名收藏夹'),
          onTap: () {
            TextEditingController _textFieldController = TextEditingController();
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('重命名收藏夹'),
                    content: TextField(
                      controller: _textFieldController,
                      decoration: InputDecoration(hintText: "收藏夹新名称"),
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
                            bookmarkFolderBloc.dispatch(RenameBookmarkFolder(oldFolder: _bookmarkFolderName, newFolder: _textFieldController.text));
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
          title: Text('删除收藏夹'),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('删除收藏夹'),
                    content: Text('确定删除收藏夹\"' + _bookmarkFolderName + "\"?（该收藏夹内的订阅源将归属默认收藏夹）"),
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
                          bookmarkFolderBloc.bookmarkFoldersRepository.deleteBookmarkFolder(_bookmarkFolderName);
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