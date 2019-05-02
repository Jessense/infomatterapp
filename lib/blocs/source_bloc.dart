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

class FetchSources extends SourceEvent {
  final String target;
  FetchSources({@required this.target}):
        assert(target != null),
        super([target]);
  @override
  String toString() => 'FetchSources';
}

class UpdateSources extends SourceEvent {
  final String target;
  UpdateSources({@required this.target}):
        assert(target != null),
        super([target]);
  @override
  String toString() => 'UpdateSources';
}


class FollowSource extends SourceEvent{
  final int sourceId;
  final String sourceName;
  FollowSource({@required this.sourceId, this.sourceName}):
        assert(sourceId != null),
        super([sourceId]);

  @override
  String toString() => 'FollowSource { source: $sourceId }';
}

class UnfollowSource extends SourceEvent{
  final int sourceId;
  final String sourceName;
  UnfollowSource({@required this.sourceId, this.sourceName}):
        assert(sourceId != null),
        super([sourceId]);

  @override
  String toString() => 'UnfollowSource { source: $sourceId }';
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
  bool followResult;
  int sourceId;
  String sourceName;


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

class SourceUpdated extends SourceState {
  @override
  String toString() {
    // TODO: implement toString
    return 'SourceUpdated';
  }
}




class SourceBloc extends Bloc<SourceEvent, SourceState> {
  final SourceRepository sourcesRepository;
  final SourceFolderBloc sourceFolderBloc;

  SourceBloc({@required this.sourcesRepository, @required this.sourceFolderBloc});

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
    if (event is FetchSources && !_hasReachedMax(currentState)) {
      print(sourcesRepository.target);
      print(event.target);
      try {
        if (currentState is SourceUninitialized) {
          final sources = await sourcesRepository.getSourcesOfCategory(event.target, 1000000, 1000000, 20);
          sourcesRepository.target = event.target;
          yield SourceLoaded(sources: sources, hasReachedMax: false);
        }
        if (currentState is SourceLoaded) {
          final sources = await sourcesRepository.getSourcesOfCategory(event.target, (currentState as SourceLoaded).sources.last.followerCount, (currentState as SourceLoaded).sources.last.id, 20);
          sourcesRepository.target = event.target;
          yield sources.isEmpty
              ? (currentState as SourceLoaded).copyWith(hasReachedMax: true)
              : SourceLoaded(
              sources: (currentState as SourceLoaded).sources + sources, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceError();
      }
    } else if (event is UpdateSources) {
      try {
        final sources = await sourcesRepository.getSourcesOfCategory(event.target, 1000000, 1000000, 20);
        yield SourceUpdated();
        yield SourceLoaded(sources: sources, hasReachedMax: false);
      } catch (_) {
        print(_);
        yield SourceError();
      }
    } else if (event is FollowSource) {
      print(sourcesRepository.target);
      if (currentState is SourceLoaded) {
        final response = await sourcesRepository.followSource(event.sourceId);
        if (response) {
          final List<Source> updatedSources =
          (currentState as SourceLoaded).sources.map((source) {
            return event.sourceId == source.id ? source.copyWith(isFollowing: true) : source;
          }).toList();
          sourcesRepository.showSnackbar = true;
          sourcesRepository.sourceId = event.sourceId;
          sourcesRepository.sourceName = event.sourceName;

          final sourceFolders = await sourceFolderBloc.sourceFoldersRepository.getSourceFolders();
          sourceFolderBloc.sourceFoldersRepository.sourceFolders = sourceFolders;

          yield SourceLoaded(sources: updatedSources, hasReachedMax: (currentState as SourceLoaded).hasReachedMax);
        } else {
          yield SourceLoaded(sources: (currentState as SourceLoaded).sources, hasReachedMax: (currentState as SourceLoaded).hasReachedMax,);
        }
      }
    } else if (event is UnfollowSource) {
      if (currentState is SourceLoaded) {
        final response = await sourcesRepository.unfollowSource(event.sourceId);
        if (response) {
          final List<Source> updatedSources =
          (currentState as SourceLoaded).sources.map((source) {
            return event.sourceId == source.id ? source.copyWith(isFollowing: false) : source;
          }).toList();

          final sourceFolders = await sourceFolderBloc.sourceFoldersRepository.getSourceFolders();
          sourceFolderBloc.sourceFoldersRepository.sourceFolders = sourceFolders;

          yield SourceLoaded(sources: updatedSources, hasReachedMax: (currentState as SourceLoaded).hasReachedMax);
        } else {
          yield SourceLoaded(sources: (currentState as SourceLoaded).sources, hasReachedMax: (currentState as SourceLoaded).hasReachedMax);
        }
      }
    }
  }

  bool _hasReachedMax(SourceState state) =>
      state is SourceLoaded && state.hasReachedMax;

}