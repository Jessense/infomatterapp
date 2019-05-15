import 'package:flutter/material.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';

class AddBookmarkDialog extends StatefulWidget {
  final int entryId;
  AddBookmarkDialog({
    this.entryId,
  });

  @override
  _AddBookmarkDialogState createState() => _AddBookmarkDialogState();
}

class _AddBookmarkDialogState extends State<AddBookmarkDialog> {

  int get _entryId => widget.entryId;
  List<String> selectedItems = [];
  TextEditingController _textFieldController = TextEditingController();

  BookmarkFolderBloc get bookmarkFolderBloc => BlocProvider.of<BookmarkFolderBloc>(context);

  @override
  void initState() {
    bookmarkFolderBloc.dispatch(FetchBookmarkFolders());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: 20,),
                Expanded(
                  child: Text(
                    '添加到收藏夹',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
              flex: 6,
              child: BlocBuilder(
                  bloc: bookmarkFolderBloc,
                  builder: (BuildContext context, BookmarkFolderState state) {
                    if (state is BookmarkFolderUninitialized) {
                      return CircularProgressIndicator();
                    }
                    if (state is BookmarkFolderError) {
                      return Center(
                        child: Text("failed to load bookmark folders"),
                      );
                    }
                    if (state is BookmarkFolderLoaded) {
                      return ListView.builder(
                          itemCount: state.bookmarkFolders.length,
                          itemBuilder: (BuildContext context, int index) {
                            final bookmarkFolderName = bookmarkFolderBloc.bookmarkFoldersRepository.bookmarkFolders[index];
                            if (bookmarkFolderName == '') {
                              return Container();
                            } else {
                              return CheckboxListTile(
                                  title: Text(bookmarkFolderName),
                                  value: selectedItems.contains(bookmarkFolderName),
                                  onChanged: (bool v) {
                                    if (v) {
                                      if (!selectedItems.contains(bookmarkFolderName)) {
                                        setState(() {
                                          selectedItems.add(bookmarkFolderName);
                                        });
                                      }
                                    } else {
                                      if (selectedItems.contains(bookmarkFolderName)) {
                                        setState(() {
                                          selectedItems.removeWhere((String folder) {
                                            return folder == bookmarkFolderName;
                                          });
                                        });
                                      }
                                    }
                                  }
                              );
                            }
                          }
                      );
                    }
                    return Container(
                      width: 0,
                      height: 0,
                    );
                  }
              )
          ),

          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(width: 15,),
                Expanded(
                  flex: 2,
                  child: FlatButton(
                    child: Text('新建收藏夹', style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),textAlign: TextAlign.center,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('新建收藏夹'),
                              content: TextField(
                                controller: _textFieldController,
                                decoration: InputDecoration(hintText: "新收藏夹名称"),
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
                                      bookmarkFolderBloc.dispatch(AssignBookmarkFolders(entryId: -1, folders: [_textFieldController.text]));
                                    }
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    },
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text('取消', style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor), textAlign: TextAlign.center,),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                Expanded(
                  child: FlatButton(
                    child: Text('确定', style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor), textAlign: TextAlign.center,),
                    onPressed: () {
                      if (selectedItems.length > 0) {
                        bookmarkFolderBloc.dispatch(AssignBookmarkFolders(entryId: _entryId, folders: selectedItems));
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }




}