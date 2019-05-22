import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  bool notNull(Object o) => o != null;

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
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    if (query.length > 0 ) {
      if (searchBloc.searchRepository.type == 'entry') {
        EntryBloc entryBloc = searchBloc.entryBloc;
        final _scrollController = ScrollController();
        Completer<void> _refreshCompleter = Completer<void>();
        final _scrollThreshold = 200.0;

        final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

        String homeSourceFolder = '';
        int homeSourceId = -3;

        entryBloc.dispatch(SearchEntryUpdate(target: query));
        return BlocBuilder(
          bloc: entryBloc,
          key: PageStorageKey('home'),
          builder: (BuildContext context, EntryState state) {
            if (entryBloc.entriesRepository.showStarred == true) {
              _onWidgetDidBuild(() {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('已收藏'),
                  action: SnackBarAction(
                    label: '添加到收藏夹',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AddBookmarkDialog(entryId: entryBloc.entriesRepository.lastStarId);
                          }
                      );
                    },
                  ),
                ));
                entryBloc.entriesRepository.showStarred = false;
              });
            }

            if (state is EntryUninitialized) {
              return Center(
                child: SpinKitThreeBounce(
                  color: Colors.grey,
                  size: 30.0,
                ),
              );
            }

            if (state is EntryError) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();

              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  entryBloc.dispatch(SearchEntryUpdate(target: query));
                  return _refreshCompleter.future;
                },
                child: ListView(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Text('failed to fetch entries'),
                    )
                  ],
                ),
              );
            }

//          if (state is EntryUpdated) {
//            _scrollController.animateTo(0.0, duration: Duration(milliseconds: 100), curve: Curves.easeOut);
//            _refreshCompleter?.complete();
//            _refreshCompleter = Completer();
//          }

            if (state is EntryLoaded) {
              _refreshCompleter?.complete();
              _refreshCompleter = Completer();

              if (state.entries.isEmpty) {
                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: () {
                    entryBloc.dispatch(SearchEntryUpdate(target: query));
                    return _refreshCompleter.future;
                  },
                  child: ListView(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Text('no entries'),
                      )
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  entryBloc.dispatch(SearchEntryUpdate(target: query));
                  return _refreshCompleter.future;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics (),
                  itemBuilder: (BuildContext context, int index) {
                    return index >= entryBloc.entriesRepository.entries.length
                        ? BottomLoader()
                        : EntryWidget(entry: entryBloc.entriesRepository.entries[index], index: index, type: 5,);
                  },
                  itemCount: state.hasReachedMax
                      ? entryBloc.entriesRepository.entries.length
                      : entryBloc.entriesRepository.entries.length + 1,
                  controller: _scrollController,
                ),
              );
            }
            return Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
            );
          },
        );
      } else {
        if (query.startsWith('http://') || query.startsWith('https://'))
          searchBloc.searchRepository.type = 'RSS';
        searchBloc.dispatch(GoSearch(target: query));
        SourceBloc sourceBloc = searchBloc.sourceBloc;
        return BlocBuilder(
          bloc: sourceBloc,
          builder: (BuildContext context, SourceState sourceState) {
            if (sourceState is SourceUninitialized) {
              return Center(
                child: SpinKitThreeBounce(size: 30, color: Colors.grey,),
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
                  Source _source = sourceState.sources[index];
                  return BlocBuilder<SourceEvent, SourceState>(
                      bloc: sourceBloc,
                      builder: (
                          BuildContext context,
                          SourceState state) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                SourceFeed(sourceId: _source.id, sourceName: _source.name,)));
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                            child: Row(
                              children: <Widget>[
                                _source.photo != null ? Expanded(
                                  child: Image.network(_source.photo, width: 20, height: 20,),
                                ) : Expanded(child: Container(width: 20, height: 20,),),
                                Expanded(
                                  flex: 3,
                                  child: Text(_source.name, maxLines: 1,),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: _source.isFollowing ? Icon(
                                        Icons.check,
                                        color: Theme.of(context).accentColor,
                                      ) : Icon(
                                        Icons.add,
                                        color: Theme.of(context).accentColor,
                                      ),
                                      onPressed: (){
                                        if (_source.isFollowing)
                                          sourceBloc.dispatch(UnfollowSource(sourceId: _source.id, sourceName: _source.name));
                                        else {
                                          if (BlocProvider.of<SearchBloc>(context).searchRepository.type == 'source')
                                            sourceBloc.dispatch(FollowSource(sourceId: _source.id, sourceName: _source.name));
                                          else {
                                            print('hihihihi');
                                            sourceBloc.dispatch(AddSource(source: _source));
                                          }

                                        }

                                      }
                                  ),
                                )
                              ].where(notNull).toList(),
                            ),
                          ),
                        );
                      }
                  );
                },
                itemCount: sourceState.sources.length,
              );
            }
          },
        );
      }
    } else {
      return buildSuggestions(context);
    }

  }

  @override
  Widget buildSuggestions(BuildContext context) {

    // TODO: implement buildSuggestions
    return SearchSelector();
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
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
  @override
  Widget build(BuildContext context) {
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: Text(searchBloc.searchRepository.hint),
        ),
        Divider(),
        SizedBox(height: 10,),
        Text('搜索'),
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    searchBloc.searchRepository.hint = '请输入内容关键词';
                    searchBloc.searchRepository.type = 'entry';
                  });
                },
                child: Text('内容', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'entry'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      searchBloc.searchRepository.hint = '请输入订阅源关键词';
                      searchBloc.searchRepository.type = 'source';
                    });
                  },
                  child: Text('订阅源', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'source'
                          ? Theme.of(context).accentColor
                          : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                  ))
              ),
            )
          ],
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
                    searchBloc.searchRepository.hint = '请输入RSS链接';
                    searchBloc.searchRepository.type = 'rss';
                  });
                },
                child: Text('RSS', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'rss'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      searchBloc.searchRepository.hint = '请输入微博用户名';
                      searchBloc.searchRepository.type = 'weibo';
                    });
                  },
                  child: Text('微博用户', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'weibo'
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
                    searchBloc.searchRepository.hint = '请输入微信公众号名称';
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
                      searchBloc.searchRepository.hint = '请输入知乎用户名';
                      searchBloc.searchRepository.type = 'zhihu';
                    });
                  },
                  child: Text('知乎用户', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'zhihu'
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
                    searchBloc.searchRepository.hint = '请输入Bilibili Up主名称';
                    searchBloc.searchRepository.type = 'bilibili_video';
                  });
                },
                child: Text('Bilibili Up主', style: TextStyle(
                    color: searchBloc.searchRepository.type == 'bilibili_video'
                        ? Theme.of(context).accentColor
                        : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    setState(() {
                      searchBloc.searchRepository.hint = '请访问https://docs.rsshub.app/查看文档, 在搜索框中输入<路由>, 如\'/douban/movie/playing\'';
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