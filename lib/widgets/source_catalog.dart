import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourceCatalog extends StatefulWidget{
  SourceCatalog({Key key}):
      super(key: key);
  @override
  State<SourceCatalog> createState() {
    // TODO: implement createState
    return SourceCatalogState();
  }
}

class SourceCatalogState extends State<SourceCatalog>{
  List<String> catalogName = ['推荐', '科技', '技术', '大学', '财经', '教科文', '公众号', '社交媒体', '设计', '生活', '娱乐', '体育', '搞笑', '其他', '全部'];
  List<String> catalogCode = ['0', '1', '2', '9', '3', '5', '4', 'E', '6', 'C', '7', 'A', 'B', 'Z', 'all'];
  int currentIndex = 0;
  SourceBloc get sourceBloc => BlocProvider.of<SourceBloc>(context);

  @override
  void initState() {
    // TODO: implement initState
    sourceBloc.dispatch(UpdateSources(target: catalogCode[currentIndex]));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder(
          bloc: sourceBloc,
          builder: (BuildContext context, SourceState state) {
            if (sourceBloc.sourcesRepository.showSnackbar == true) {
              _onWidgetDidBuild(() {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Followed'),
                  action: SnackBarAction(
                    label: 'Assign Folder',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return MyDialog(sourceId: sourceBloc.sourcesRepository.sourceId, sourceName: sourceBloc.sourcesRepository.sourceName,);
                          }
                      );
                    },
                  ),
                ));
                sourceBloc.sourcesRepository.showSnackbar = false;
              });
            }
            return Row(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            catalogName[index],
                            style: TextStyle(
                              color: currentIndex == index
                                  ? Theme.of(context).accentColor : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              currentIndex = index;
                              sourceBloc.dispatch(UpdateSources(target: catalogCode[index]));
                            });
                          },
                        );
                      },
                      itemCount: catalogName.length,
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  flex: 3,
                  child: SourceList(category: catalogCode[currentIndex],)
                )
              ],
            );
          }
      );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }
}