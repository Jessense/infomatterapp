import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourcePage extends StatefulWidget{
  final String sourceName;
  final int sourceId;
  SourcePage({Key key, @required this.sourceId, @required this.sourceName}):
      assert(sourceId != null && sourceName != null),
      super(key: key);

  @override
  State<SourcePage> createState() {
    // TODO: implement createState
    return SourcePageState();
  }
}

class SourcePageState extends State<SourcePage> {

  int get _sourceId => widget.sourceId;
  String get _sourceName => widget.sourceName;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text(_sourceName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        )),
                    background: Image.network(
                      "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                      fit: BoxFit.cover,
                    )),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "全部"),
                      Tab(text: "简介"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
              children: <Widget>[
                Center(
                  child: SourceFeed(sourceId: _sourceId),
                ),
                Center(
                  child: Text("tab2"),
                )
              ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class SourceFeed extends StatefulWidget{
  final String sourceName;
  final int sourceId;
  SourceFeed({Key key, @required this.sourceId, @required this.sourceName}):
      assert(sourceId != null),
      super(key: key);

  @override
  State<SourceFeed> createState() {
    // TODO: implement createState
    return SourceFeedState();
  }
}

class SourceFeedState extends State<SourceFeed> {
  SourceEntryBloc get sourceEntryBloc => BlocProvider.of<SourceEntryBloc>(context);

  final _scrollController = ScrollController();
  Completer<void> _refreshCompleter = Completer<void>();
  final _scrollThreshold = 200.0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  int get homeSourceId => widget.sourceId;
  String homeSourceFolder = '';

  int get _sourceId => widget.sourceId;
  String get _sourceName => widget.sourceName;
  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(_onScroll);
    fetch();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_sourceName),),
      body: BlocBuilder(
        bloc: sourceEntryBloc,
        builder: (BuildContext context, SourceEntryState state) {

          if (state is SourceEntryUninitialized) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SourceEntryError) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () {
                sourceEntryBloc.dispatch(UpdateSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
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
//            _refreshCompleter3?.complete();
//            _refreshCompleter3 = Completer();
//          }

          if (state is SourceEntryLoaded) {
            _refreshCompleter?.complete();
            _refreshCompleter = Completer();

            if (state.entries.isEmpty) {
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () {
                  sourceEntryBloc.dispatch(UpdateSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
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
                sourceEntryBloc.dispatch(UpdateSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
                return _refreshCompleter.future;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics (),
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.entries.length
                      ? BottomLoader()
                      : EntryWidget(entry: state.entries[index], index: index, type: 3,);
                },
                itemCount: state.hasReachedMax
                    ? state.entries.length
                    : state.entries.length + 1,
                controller: _scrollController,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

  void _onScroll() {

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      fetch();
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    sourceEntryBloc.dispatch(UpdateSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
    super.deactivate();
  }


  @override
  void dispose() {
    super.dispose();
  }

  void fetch() {
    sourceEntryBloc.dispatch(FetchSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
  }

  void refresh() {
    sourceEntryBloc.dispatch(UpdateSourceEntry(sourceId: _sourceId, folder: homeSourceFolder));
  }
}