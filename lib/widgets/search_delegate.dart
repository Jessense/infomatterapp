import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class MySearchDelegate extends SearchDelegate{


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
    if (query.length > 0)
      searchBloc.dispatch(GoSearch(target: query));
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
                    return SourceItemWidget(source: sourceState.sources[index], type: 1,);
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
    SourceBloc sourceBloc = BlocProvider.of<SourceBloc>(context);
    SearchBloc searchBloc = BlocProvider.of<SearchBloc>(context);
    // TODO: implement buildSuggestions
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    searchBloc.searchRepository.type = 'sourceKeyword';
                  },
                  child: Text('RSS', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'sourceKeyword'
                          ? Colors.red
                          : Colors.black
                  ),),
              ),
            ),
            Expanded(
              child: FlatButton(
                  onPressed: () {
                    searchBloc.searchRepository.type = 'weiboUser';
                  },
                  child: Text('微博用户', style: TextStyle(
                      color: searchBloc.searchRepository.type == 'weiboUser'
                          ? Colors.red
                          : Colors.black
                  ))
              ),
            )
          ],
        )
      ],
    );
  }

}