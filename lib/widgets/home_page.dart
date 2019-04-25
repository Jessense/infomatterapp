import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:infomatterapp/blocs/source_folder_bloc.dart';
import 'package:infomatterapp/blocs/entry_bloc.dart';
import 'package:infomatterapp/blocs/entry_star_bloc.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:infomatterapp/repositories/repositories.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  SourceFolderBloc sourceFolderBloc = SourceFolderBloc(
      sourceFoldersRepository: SourceFolderRepository(
          sourceFolderApiClient: SourceFolderApiClient(
            httpClient: http.Client()
          )
      )
  );

  EntryBloc entryBloc = EntryBloc(
    entriesRepository: EntriesRepository(
      entriesApiClient: EntriesApiClient(httpClient: http.Client()),
    ),
    fromState: EntryUninitialized(),
  );

  final _scrollController = ScrollController();
  Completer<void> _refreshCompleter = Completer<void>();
  final _scrollThreshold = 200.0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  int homeSourceId = -1;
  String homeSourceFolder = '';
  
  String appBarText = "全部";

  bool darkModeOn = false;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(_onScroll);
    fetch();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text(appBarText), ),
      body: BlocBuilder(
        bloc: entryBloc,
        builder: (BuildContext context, EntryState state) {
          if (state is EntryUninitialized) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is EntryError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            return Center(
              child: Text('failed to fetch entries'),
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
              return Center(
                child: Text('no entries'),
              );
            }

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                entryBloc.dispatch(Update(sourceId: homeSourceId, folder: homeSourceFolder));
                return _refreshCompleter.future;
              },
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.entries.length
                      ? BottomLoader()
                      : BlocProvider(
                          bloc: EntryStarBloc(
                          entryRepository: EntriesRepository(
                            entriesApiClient: EntriesApiClient(
                                httpClient: http.Client()
                            )
                          ),
                          fromState: state.entries[index].isStarring ? EntryStarring() : EntryNotStarring()
                      ),
                    child: EntryWidget(entry: state.entries[index]),
                  );
                },
                itemCount: state.hasReachedMax
                    ? state.entries.length
                    : state.entries.length + 1,
                controller: _scrollController,
              ),
            );
          }
        },
      ),
      drawer: Drawer(
        child: BlocBuilder(
            bloc: sourceFolderBloc,
            builder: (BuildContext context, SourceFolderState state) {
              if (state is SourceFolderUninitialized) {
                sourceFolderBloc.dispatch(FetchSourceFolders());
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is SourceFolderError) {
                return Center(
                  child: Text("failed to fetch source folders"),
                );
              }

              if (state is SourceFolderLoaded) {
                return ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text("设置"),
                      );
                    } else if (index == 1) {
                      return ListTile(
                        title: Text("白天/夜间"),
                        onTap: (){
                          changeBrightness();
                          Navigator.of(context).pop();
                        },
                      );
                    } else if (index == 2) {
                      return ListTile(
                        title: Text("收藏"),
                        onTap: () {
                          homeSourceId = -2;
                          homeSourceFolder = '';
                          refresh();
                          setState(() {
                            appBarText = "收藏";
                          });
                        },
                      );
                    } else if (index == 3) {
                      return Divider();
                    } else if (index == 4) {
                      return ListTile(
                        title: Text("订阅"),
                        trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => SourcesDiscoveryPage()));
                            }
                        ),
                      );
                    }
                    index = index - 5;
                    return GestureDetector(
                      child: ExpansionTile(
                          title: state.sourceFolders[index].sourceFolderName.length > 0 ?
                          Text(state.sourceFolders[index].sourceFolderName) :
                          Text("全部"),
                          children: state.sourceFolders[index].sourceList.map((source){
                            return ListTile(
                              leading: Image.network(source.photo, width: 20, height: 20,),
                              title: Text(source.name),
                              onTap: () {
                                homeSourceId = source.id;
                                Navigator.of(context).pop();
                                refresh();
                                setState(() {
                                  appBarText = source.name;
                                });
                              },
                            );
                          }).toList()
                      ),
                      onTap: (){
                        homeSourceId = -1;
                        homeSourceFolder = state.sourceFolders[index].sourceFolderName;
                        Navigator.of(context).pop();
                        refresh();
                        setState(() {
                          setState(() {
                            if (homeSourceFolder.length == 0) {
                              appBarText = '全部';
                            } else {
                              appBarText = homeSourceFolder;
                            }
                          });
                        });
                      },
                    );
                  },
                  itemCount: state.sourceFolders.length + 5,
                );
              }
            }
        )
      ),
    );
  }

  @override
  void dispose() {
    entryBloc.dispose();
    super.dispose();
  }

  void _onScroll() {

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      fetch();
    }
  }

  void fetch() {
    entryBloc.dispatch(Fetch(sourceId: homeSourceId, folder: homeSourceFolder));
  }

  void refresh() {
    _scrollController.animateTo(0.0, duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    _refreshIndicatorKey.currentState.show();
    entryBloc.dispatch(Update(sourceId: homeSourceId, folder: homeSourceFolder));
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(
        Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark);
  }
}

