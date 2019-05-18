import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';

class MyDialog extends StatefulWidget {
  final int sourceId;
  final String sourceName;
  MyDialog({
    this.sourceId,
    this.sourceName
  });

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {

  int get _sourceId => widget.sourceId;
  String get _sourceName => widget.sourceName;
  List<String> selectedItems = [];
  TextEditingController _textFieldController = TextEditingController();

  SourceFolderBloc get sourceFolderBloc => BlocProvider.of<SourceFolderBloc>(context);

  @override
  void initState() {
    sourceFolderBloc.dispatch(FetchSourceFolders());
    sourceFolderBloc.sourceFoldersRepository.sourceFolders.forEach((folder){
      for (var source in folder.sourceList) {
        if (source.name == _sourceName && folder.sourceFolderName.length > 0) {
          selectedItems.add(folder.sourceFolderName);
          break;
        }
      }
    });
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
                    _sourceName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            flex: 7,
            child: BlocBuilder(
                bloc: sourceFolderBloc,
                builder: (BuildContext context, SourceFolderState state) {
                  if (state is SourceFolderUninitialized) {
                    return Center(
                      child: SpinKitThreeBounce(
                        color: Colors.grey,
                        size: 30.0,
                      ),
                    );
                  }
                  if (state is SourceFolderError) {
                    return Center(
                      child: Text("failed to load source folders"),
                    );
                  }
                  if (state is SourceFolderLoaded) {
                    return ListView.builder(
                        itemCount: state.sourceFolders.length,
                        itemBuilder: (BuildContext context, int index) {
                          final sourceFolderName = sourceFolderBloc.sourceFoldersRepository.sourceFolders[index].sourceFolderName;
                          if (sourceFolderName == '') {
                            return Container();
                          } else {
                            return CheckboxListTile(
                                title: Text(sourceFolderName),
                                value: selectedItems.contains(sourceFolderName),
                                onChanged: (bool v) {
                                  if (v) {
                                    if (!selectedItems.contains(sourceFolderName)) {
                                      setState(() {
                                        selectedItems.add(sourceFolderName);
                                      });
                                    }
                                  } else {
                                    if (selectedItems.contains(sourceFolderName)) {
                                      setState(() {
                                        selectedItems.removeWhere((String folder) {
                                          return folder == sourceFolderName;
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
                    child: Text('新建分组', style: TextStyle(fontSize: 16, color: Theme.of(context).accentColor),textAlign: TextAlign.center,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('新建分组'),
                              content: TextField(
                                controller: _textFieldController,
                                decoration: InputDecoration(hintText: "新分组名称"),
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
                                      sourceFolderBloc.dispatch(AssignSourceFolders(sourceId: -1, folders: [_textFieldController.text]));
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
                        sourceFolderBloc.dispatch(AssignSourceFolders(sourceId: _sourceId, folders: selectedItems));
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