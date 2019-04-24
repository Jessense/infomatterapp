import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';


import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class FeedPage extends StatefulWidget {
  FeedPage({Key key}):
      super(key: key);
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  Completer<void> _refreshCompleter = Completer<void>();
  EntryBloc _entryBloc;
  final _scrollThreshold = 200.0;


  _FeedPageState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  void initState() {
    // TODO: implement initState
    print(PageStorage.of(context).readState(context, identifier: ValueKey('lastStateFeed')));
    if (PageStorage.of(context).readState(context, identifier: ValueKey('lastStateFeed')) != null) {
      _entryBloc = EntryBloc(
        entriesRepository: EntriesRepository(
          entriesApiClient: EntriesApiClient(httpClient: http.Client()),
        ),
        fromState: PageStorage.of(context).readState(context, identifier: ValueKey('lastStateFeed')),
      );
    } else {
      _entryBloc = EntryBloc(
        entriesRepository: EntriesRepository(
          entriesApiClient: EntriesApiClient(httpClient: http.Client()),
        ),
        fromState: EntryUninitialized(),
      );
      _entryBloc.dispatch(Fetch(sourceId: -1));
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _entryBloc,
      builder: (BuildContext context, EntryState state) {
        PageStorage.of(context).writeState(context, state, identifier: ValueKey('lastStateFeed'));
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

        if (state is EntryToTop) {
          _entryBloc.dispatch(Update(sourceId: -1));
        }

        if (state is EntryLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();

          if (state.entries.isEmpty) {
            return Center(
              child: Text('no entries'),
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              _entryBloc.dispatch(Update(sourceId: -1));
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
    );
  }

  @override
  void dispose() {
    _entryBloc.dispose();
    super.dispose();
  }

  void _onScroll() {

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _entryBloc.dispatch(Fetch(sourceId: -1));
    }
  }

}


