import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:async';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourceList extends StatefulWidget{
  final String category;
  SourceList({Key key, this.category}):
      super(key: key);
  @override
  State<SourceList> createState() {
    // TODO: implement createState
    return SourceListState();
  }
}

class SourceListState extends State<SourceList>{

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  final _scrollController = ScrollController();
  Completer<void> _refreshCompleter = Completer<void>();
  final _scrollThreshold = 50.0;


  String get category => widget.category;
  SourceBloc get sourceBloc => BlocProvider.of<SourceBloc>(context);

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
    return BlocBuilder(
      bloc: sourceBloc,
      builder: (BuildContext context, SourceState state) {
        if (state is SourceError) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              sourceBloc.dispatch(UpdateSources(target: category));
              return _refreshCompleter.future;
            },
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  child: CenterTextPage(msg: '无法获取内容源列表'),
                )
              ],
            ),
          );
        }
        if (state is SourceUninitialized) {
          return Center(
            child: SpinKitThreeBounce(
              color: Colors.grey,
              size: 30.0,
            ),
          );
        }

        if (state is SourceLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () {
              sourceBloc.dispatch(UpdateSources(target: category));
              return _refreshCompleter.future;
            },
            child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index >= state.sources.length
                      ? BottomLoader()
                      : SourceItemWidget(source: state.sources[index],);
                },
                itemCount: state.hasReachedMax == true
                    ? state.sources.length
                    : state.sources.length + 1,
                controller: _scrollController,
            ),
          );
        }
      },
    );
  }

  void _onScroll() {

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      fetch();
    }
  }

  void fetch() {
    sourceBloc.dispatch(FetchSources(target: category));
  }

  void refresh() {
    _scrollController.animateTo(0.0, duration: Duration(milliseconds: 100), curve: Curves.easeOut);
    _refreshIndicatorKey.currentState.show();
    sourceBloc.dispatch(UpdateSources(target: category));
  }
}