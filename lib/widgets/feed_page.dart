import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/repositories/repositories.dart';

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _scrollController = ScrollController();
  final EntryBloc _entryBloc = EntryBloc(
      entriesRepository: EntriesRepository(
          entriesApiClient: EntriesApiClient(httpClient: http.Client()),
      )
  );
  final _scrollThreshold = 200.0;

  _FeedPageState() {
    _scrollController.addListener(_onScroll);
    _entryBloc.dispatch(Fetch());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _entryBloc,
      builder: (BuildContext context, EntryState state) {
        if (state is EntryUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is EntryError) {
          return Center(
            child: Text('failed to fetch entries'),
          );
        }
        if (state is EntryLoaded) {
          if (state.entries.isEmpty) {
            return Center(
              child: Text('no entries'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.entries.length
                  ? BottomLoader()
                  : EntryWidget(entry: state.entries[index]);
            },
            itemCount: state.hasReachedMax
                ? state.entries.length
                : state.entries.length + 1,
            controller: _scrollController,
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
      _entryBloc.dispatch(Fetch());
    }
  }
}

class BottomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SizedBox(
          width: 33,
          height: 33,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      ),
    );
  }
}

class EntryWidget extends StatelessWidget {
  final Entry entry;

  const EntryWidget({Key key, @required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(entry.title, style: TextStyle(fontSize: 16),),
      isThreeLine: true,
      subtitle: Text(entry.body, style: TextStyle(fontSize: 14),),
    );
  }
}
