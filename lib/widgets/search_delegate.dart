import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class MySearchDelegate extends SearchDelegate{
  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    SourceBloc sourceBloc = BlocProvider.of<SourceBloc>(context);
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    SourceBloc sourceBloc = BlocProvider.of<SourceBloc>(context);
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    if (query.length > 0) {
      if (query.startsWith('http://') || query.startsWith('https://'))
        searchBloc.searchRepository.type = 'RSS';
      searchBloc.dispatch(GoSearch(target: query));
    }
    else {
      return buildSuggestions(context);
    }
    return BlocBuilder(
      bloc: searchBloc,
      builder: (BuildContext context, SearchState searchState) {
        return BlocBuilder(
          bloc: sourceBloc,
          builder: (BuildContext context, SourceState sourceState) {
            if (sourceState is SourceUninitialized) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (sourceState is SourceError) {
              return Center(
                child: Text('failed to fetch sources'),
              );
            }
            if (sourceState is SourceLoaded) {
              if (sourceState.sources.length == 0) {
                return Center(
                  child: Text('no result'),
                );
              }
              return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return SourceItemWidget(source: sourceState.sources[index],);
                  },
                  itemCount: sourceState.sources.length,
              );
            }
          },
        );

      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // TODO: implement buildSuggestions
    return SearchSelector();
  }

}

class SearchSelector extends StatefulWidget{
  @override
  State<SearchSelector> createState() {
    // TODO: implement createState
    return SearchSelectorState();
  }
}

class SearchSelectorState extends State<SearchSelector>{
  String hint = '请输入内容源关键词';
  @override
  Widget build(BuildContext context) {
    SourceBloc sourceBloc = BlocProvider.of<SourceBloc>(context);
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: Text(hint),
        ),
        Divider(),
        SizedBox(height: 10,),
        Text('创建订阅源'),
        SizedBox(height: 10,),

        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    hint = '请输入RSS链接';
                    searchBloc.searchRepository.type = 'RSS';
                  });
                },
                child: Text('RSS', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'RSS'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      hint = '请输入微博用户名';
                      searchBloc.searchRepository.type = 'weiboUser';
                    });
                  },
                  child: Text('微博用户', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'weiboUser'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                  ))
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    hint = '请输入微信公众号名称';
                    searchBloc.searchRepository.type = 'wechat';
                  });
                },
                child: Text('微信公众号', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'wechat'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      hint = '请输入知乎用户名';
                      searchBloc.searchRepository.type = 'zhihuUser';
                    });
                  },
                  child: Text('知乎用户', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'zhihuUser'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                  ))
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    hint = '请输入Bilibili Up主名称';
                    searchBloc.searchRepository.type = 'Bilibili';
                  });
                },
                child: Text('Bilibili Up主', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'Bilibili'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      hint = '请访问https://docs.rsshub.app/查看文档, 在搜索框中输入<路由>, 如\'/douban/movie/playing\'';
                      searchBloc.searchRepository.type = 'any';
                    });
                  },
                  child: Text('更多', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'any'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                  ))
              ),
            )
          ],
        )
      ],
    );
  }
}