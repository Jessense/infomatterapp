import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class SourceEvent extends Equatable {
  SourceEvent([List props = const []]) : super(props);
}

class Fetch extends SourceEvent {
  final String target;
  Fetch({@required this.target}):
        assert(target != null),
        super([target]);
  @override
  String toString() => 'Fetch';
}



abstract class SourceState extends Equatable {
  SourceState([List props = const []]) : super(props);
}

class SourceUninitialized extends SourceState {
  @override
  String toString() => 'SourceUninitialized';
}

class SourceError extends SourceState {
  @override
  String toString() => 'SourceError';
}

class SourceLoaded extends SourceState {
  final List<Source> sources;
  final bool hasReachedMax;

  SourceLoaded({
    this.sources,
    this.hasReachedMax,
  }) : super([sources, hasReachedMax]);

  SourceLoaded copyWith({
    List<Source> sources,
    bool hasReachedMax,
  }) {
    return SourceLoaded(
      sources: sources ?? this.sources,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'SourceLoaded { sources: ${sources.length}, hasReachedMax: $hasReachedMax }';
}




class SourceBloc extends Bloc<SourceEvent, SourceState> {
  final SourceRepository sourcesRepository;

  SourceBloc({@required this.sourcesRepository});

//  @override
//  Stream<SourceState> transform(
//      Stream<SourceEvent> events,
//      Stream<SourceState> Function(SourceEvent event) next,
//      ) {
//    return super.transform(
//      (events as Observable<SourceEvent>).debounce(
//        Duration(milliseconds: 500),
//      ),
//      next,
//    );
//  }

  @override
  get initialState => SourceUninitialized();

  @override
  Stream<SourceState> mapEventToState(event) async* {
    if (event is Fetch && event.target == "all" && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceUninitialized) {
          final sources = await sourcesRepository.getSources(1000000, 1000000, 20);
          yield SourceLoaded(sources: sources, hasReachedMax: false);
        }
        if (currentState is SourceLoaded) {
          final sources = await sourcesRepository.getSources((currentState as SourceLoaded).sources.last.followerCount, (currentState as SourceLoaded).sources.last.id, 20);
          yield sources.isEmpty
              ? (currentState as SourceLoaded).copyWith(hasReachedMax: true)
              : SourceLoaded(
              sources: (currentState as SourceLoaded).sources + sources, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceError();
      }
    } else if (event is Fetch && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceUninitialized) {
          final sources = await sourcesRepository.getSourcesOfCategory(event.target, 1000000, 1000000, 20);
          yield SourceLoaded(sources: sources, hasReachedMax: false);
        }
        if (currentState is SourceLoaded) {
          final sources = await sourcesRepository.getSourcesOfCategory(event.target, (currentState as SourceLoaded).sources.last.followerCount, (currentState as SourceLoaded).sources.last.id, 20);
          yield sources.isEmpty
              ? (currentState as SourceLoaded).copyWith(hasReachedMax: true)
              : SourceLoaded(
              sources: (currentState as SourceLoaded).sources + sources, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceError();
      }
    }
  }

  bool _hasReachedMax(SourceState state) =>
      state is SourceLoaded && state.hasReachedMax;

}