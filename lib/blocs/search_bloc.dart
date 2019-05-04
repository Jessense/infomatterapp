import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class GoSearch extends SearchEvent{
  final String target;
  GoSearch({@required this.target}):
      assert(target != null),
      super([target]);
  @override
  String toString() {
    // TODO: implement toString
    return 'GoSearch';
  }
}

abstract class SearchState extends Equatable {
  SearchState([List props = const []]) : super(props);
}

class SearchInit extends SearchState{
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchInit';
  }
}

class SearchLoading extends SearchState{
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchLoading';
  }
}

class SearchLoaded extends SearchState{
  final List<Source> sources;
  SearchLoaded({@required this.sources}):
      assert(sources != null),
      super([sources]);
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchLoaded';
  }
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {

  SearchRepository searchRepository;
  SourceBloc sourceBloc;
  SearchBloc({@required this.searchRepository, @required this.sourceBloc});

  @override
  // TODO: implement initialState
  SearchState get initialState => SearchLoading();

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    // TODO: implement mapEventToState
    if (event is GoSearch) {
      sourceBloc.dispatch(PassLoading());
      final result = await searchRepository.searchSource(event.target);
      print('searchBloc: ' + result.toString());
      sourceBloc.dispatch(PassSources(sources: result));
    }
  }
}
