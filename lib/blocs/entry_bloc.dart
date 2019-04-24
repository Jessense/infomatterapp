import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class EntryEvent extends Equatable {
  EntryEvent([List props = const []]) : super(props);
}

class Fetch extends EntryEvent {
  final int sourceId;
  Fetch({@required this.sourceId}):
      super([sourceId]);
  @override
  String toString() => 'Fetch';
}

class Update extends EntryEvent {
  final int sourceId;
  Update({@required this.sourceId}):
        super([sourceId]);
  @override
  String toString() => 'Update';
}

abstract class EntryState extends Equatable {
  EntryState([List props = const []]) : super(props);
}

class EntryUninitialized extends EntryState {
  @override
  String toString() => 'EntryUninitialized';
}

class EntryError extends EntryState {
  @override
  String toString() => 'EntryError';
}

class EntryUpdated extends EntryState {
  @override
  String toString() => 'EntryUpdated';
}

class EntryToTop extends EntryState {
  @override
  String toString() => 'EntryToTop';
}

class EntryLoaded extends EntryState {
  final List<Entry> entries;
  final bool hasReachedMax;
  final DateTime timenow;

  EntryLoaded({
    this.entries,
    this.hasReachedMax,
    this.timenow
  }) : super([entries, hasReachedMax]);

  EntryLoaded copyWith({
    List<Entry> entries,
    bool hasReachedMax,
  }) {
    return EntryLoaded(
      entries: entries ?? this.entries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'EntryLoaded { entries: ${entries.length}, hasReachedMax: $hasReachedMax,  timenow: $timenow}';
}


class EntryBloc extends Bloc<EntryEvent, EntryState> {
  final EntriesRepository entriesRepository;
  final EntryState fromState;

  EntryBloc({@required this.entriesRepository, @required this.fromState});

//  @override
//  Stream<EntryState> transform(
//      Stream<EntryEvent> events,
//      Stream<EntryState> Function(EntryEvent event) next,
//      ) {
//    return super.transform(
//      (events as Observable<EntryEvent>).debounce(
//        Duration(milliseconds: 500),
//      ),
//      next,
//    );
//  }

  @override
  get initialState => fromState;

  @override
  Stream<EntryState> mapEventToState(event) async* {
    if (event is Fetch && event.sourceId == -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is EntryUninitialized) {
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10);
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getTimeline((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10);
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Fetch && event.sourceId > -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is EntryUninitialized) {
          final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getTimelineOfSource((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10, event.sourceId);
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Fetch && event.sourceId == -2 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is EntryUninitialized) {
          final entries = await entriesRepository.getBookmarks(1000000, 10);
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getBookmarks((currentState as EntryLoaded).entries.last.starId, 10);
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Update && event.sourceId == -1) {
      try {
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10);
          print(entries);
          yield EntryUpdated();
          yield EntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Update && event.sourceId == -2) {
      try {
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getBookmarks(1000000, 10);
          print(entries);
          yield EntryUpdated();
          yield EntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    }
  }

  bool _hasReachedMax(EntryState state) =>
      state is EntryLoaded && state.hasReachedMax;

}