import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class SourceEntryEvent extends Equatable {
  SourceEntryEvent([List props = const []]) : super(props);
}

class FetchSourceEntry extends SourceEntryEvent {
  final int sourceId;
  final String folder;
  FetchSourceEntry({@required this.sourceId, @required this.folder}):
        super([sourceId, folder]);
  @override
  String toString() => 'FetchSourceEntry';
}

class UpdateSourceEntry extends SourceEntryEvent {
  final int sourceId;
  final String folder;
  UpdateSourceEntry({@required this.sourceId, @required this.folder}):
        super([sourceId, folder]);
  @override
  String toString() => 'UpdateSourceEntry';
}

class StarSourceEntry extends SourceEntryEvent{
  final int entryId;
  final int from;
  StarSourceEntry({@required this.entryId, @required this.from}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'StarSourceEntry { entry: $entryId }';
}

class UnstarSourceEntry extends SourceEntryEvent{
  final int entryId;
  UnstarSourceEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'UnstarSourceEntry { entry: $entryId }';
}

abstract class SourceEntryState extends Equatable {
  SourceEntryState([List props = const []]) : super(props);
}

class SourceEntryUninitialized extends SourceEntryState {
  @override
  String toString() => 'SourceEntryUninitialized';
}

class SourceEntryError extends SourceEntryState {
  @override
  String toString() => 'SourceEntryError';
}

class SourceEntryUpdated extends SourceEntryState {
  @override
  String toString() => 'SourceEntryUpdated';
}


class SourceEntryMessageArrived extends SourceEntryState {
  final String message;
  SourceEntryMessageArrived(this.message);
  @override
  String toString() => 'SourceEntryMessageArrived';
}

class SourceEntryLoaded extends SourceEntryState {
  final List<Entry> entries;
  final bool hasReachedMax;
  final DateTime timenow;

  SourceEntryLoaded({
    this.entries,
    this.hasReachedMax,
    this.timenow
  }) : super([entries, hasReachedMax]);

  SourceEntryLoaded copyWith({
    List<Entry> entries,
    bool hasReachedMax,
  }) {
    return SourceEntryLoaded(
      entries: entries ?? this.entries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'SourceEntryLoaded { entries: ${entries.length}, hasReachedMax: $hasReachedMax,  timenow: $timenow}';
}


class SourceEntryBloc extends Bloc<SourceEntryEvent, SourceEntryState> {
  final EntriesRepository entriesRepository;

  SourceEntryBloc({@required this.entriesRepository});

//  @override
//  Stream<SourceEntryState> transform(
//      Stream<SourceEntryEvent> events,
//      Stream<SourceEntryState> Function(SourceEntryEvent event) next,
//      ) {
//    return super.transform(
//      (events as Observable<SourceEntryEvent>).debounce(
//        Duration(milliseconds: 500),
//      ),
//      next,
//    );
//  }

  @override
  get initialState => SourceEntryUninitialized();

  @override
  Stream<SourceEntryState> mapEventToState(event) async* {
    if (event is FetchSourceEntry && event.sourceId == -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceEntryUninitialized) {
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
          yield SourceEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is SourceEntryLoaded) {
          final entries = await entriesRepository.getTimeline((currentState as SourceEntryLoaded).entries.last.pubDate, 1000000, 10, event.folder);
          yield entries.isEmpty
              ? (currentState as SourceEntryLoaded).copyWith(hasReachedMax: true)
              : SourceEntryLoaded(
              entries: (currentState as SourceEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is FetchSourceEntry && event.sourceId > -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceEntryUninitialized) {
          final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
          yield SourceEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is SourceEntryLoaded) {
          final entries = await entriesRepository.getTimelineOfSource((currentState as SourceEntryLoaded).entries.last.pubDate, 1000000, 10, event.sourceId);
          yield entries.isEmpty
              ? (currentState as SourceEntryLoaded).copyWith(hasReachedMax: true)
              : SourceEntryLoaded(
              entries: (currentState as SourceEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is FetchSourceEntry && event.sourceId == -2 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceEntryUninitialized) {
          final entries = await entriesRepository.getBookmarks(1000000, 10, event.folder);
          yield SourceEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is SourceEntryLoaded) {
          final entries = await entriesRepository.getBookmarks((currentState as SourceEntryLoaded).entries.last.starId, 10, event.folder);
          yield entries.isEmpty
              ? (currentState as SourceEntryLoaded).copyWith(hasReachedMax: true)
              : SourceEntryLoaded(
              entries: (currentState as SourceEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is UpdateSourceEntry && event.sourceId == -1) {
      try {
        final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
        print(entries);
        yield SourceEntryUpdated();
        yield SourceEntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is UpdateSourceEntry && event.sourceId == -2) {
      try {
        final entries = await entriesRepository.getBookmarks(1000000, 10, event.folder);
        print(entries);
        yield SourceEntryUpdated();
        yield SourceEntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is UpdateSourceEntry && event.sourceId > -1 && !_hasReachedMax(currentState)) {
      try {
        final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
        yield SourceEntryUpdated();
        yield SourceEntryLoaded(entries: entries, hasReachedMax: false);
      } catch (_) {
        print(_);
        yield SourceEntryError();
      }
    } else if (event is StarSourceEntry) {
      if (currentState is SourceEntryLoaded) {
        final response = await entriesRepository.starEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries = (currentState as SourceEntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: true) : entry;
          }).toList();
          if (event.from == 0)
            entriesRepository.showStarred = true;
          else
            entriesRepository.showStarred2 = true;
          entriesRepository.lastStarId = event.entryId;
          yield SourceEntryUpdated();
          yield SourceEntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield SourceEntryMessageArrived('star failed');
          yield SourceEntryLoaded(entries: (currentState as SourceEntryLoaded).entries, hasReachedMax: false);
        }
      }
    } else if (event is UnstarSourceEntry) {
      if (currentState is SourceEntryLoaded) {
        final response = await entriesRepository.unstarEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries =
          (currentState as SourceEntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: false) : entry;
          }).toList();
          yield SourceEntryUpdated();
          yield SourceEntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield SourceEntryMessageArrived('unstar failed');
          yield SourceEntryLoaded(entries: (currentState as SourceEntryLoaded).entries, hasReachedMax: false);
        }
      }
    }
  }

  bool _hasReachedMax(SourceEntryState state) =>
      state is SourceEntryLoaded && state.hasReachedMax;

}