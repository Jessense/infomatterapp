import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class BookmarkEntryEvent extends Equatable {
  BookmarkEntryEvent([List props = const []]) : super(props);
}

class FetchBookmarkEntry extends BookmarkEntryEvent {
  final int sourceId;
  final String folder;
  FetchBookmarkEntry({@required this.sourceId, @required this.folder}):
        super([sourceId, folder]);
  @override
  String toString() => 'FetchBookmarkEntry';
}

class UpdateBookmarkEntry extends BookmarkEntryEvent {
  final int sourceId;
  final String folder;
  UpdateBookmarkEntry({@required this.sourceId, @required this.folder}):
        super([sourceId, folder]);
  @override
  String toString() => 'UpdateBookmarkEntry';
}

class StarBookmarkEntry extends BookmarkEntryEvent{
  final int entryId;
  StarBookmarkEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'StarBookmarkEntry { entry: $entryId }';
}

class UnstarBookmarkEntry extends BookmarkEntryEvent{
  final int entryId;
  UnstarBookmarkEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'UnstarBookmarkEntry { entry: $entryId }';
}

abstract class BookmarkEntryState extends Equatable {
  BookmarkEntryState([List props = const []]) : super(props);
}

class BookmarkEntryUninitialized extends BookmarkEntryState {
  @override
  String toString() => 'BookmarkEntryUninitialized';
}

class BookmarkEntryError extends BookmarkEntryState {
  @override
  String toString() => 'BookmarkEntryError';
}

class BookmarkEntryUpdated extends BookmarkEntryState {
  @override
  String toString() => 'BookmarkEntryUpdated';
}


class BookmarkEntryMessageArrived extends BookmarkEntryState {
  final String message;
  BookmarkEntryMessageArrived(this.message);
  @override
  String toString() => 'BookmarkEntryMessageArrived';
}

class BookmarkEntryLoaded extends BookmarkEntryState {
  final List<Entry> entries;
  final bool hasReachedMax;
  final DateTime timenow;

  BookmarkEntryLoaded({
    this.entries,
    this.hasReachedMax,
    this.timenow
  }) : super([entries, hasReachedMax]);

  BookmarkEntryLoaded copyWith({
    List<Entry> entries,
    bool hasReachedMax,
  }) {
    return BookmarkEntryLoaded(
      entries: entries ?? this.entries,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'BookmarkEntryLoaded { entries: ${entries.length}, hasReachedMax: $hasReachedMax,  timenow: $timenow}';
}


class BookmarkEntryBloc extends Bloc<BookmarkEntryEvent, BookmarkEntryState> {
  final EntriesRepository entriesRepository;
  final BookmarkEntryState fromState;

  BookmarkEntryBloc({@required this.entriesRepository, @required this.fromState});

//  @override
//  Stream<BookmarkEntryState> transform(
//      Stream<BookmarkEntryEvent> events,
//      Stream<BookmarkEntryState> Function(BookmarkEntryEvent event) next,
//      ) {
//    return super.transform(
//      (events as Observable<BookmarkEntryEvent>).debounce(
//        Duration(milliseconds: 500),
//      ),
//      next,
//    );
//  }

  @override
  get initialState => fromState;

  @override
  Stream<BookmarkEntryState> mapEventToState(event) async* {
    if (event is FetchBookmarkEntry && event.sourceId == -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is BookmarkEntryUninitialized) {
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
          yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is BookmarkEntryLoaded) {
          final entries = await entriesRepository.getTimeline((currentState as BookmarkEntryLoaded).entries.last.pubDate, 1000000, 10, event.folder);
          yield entries.isEmpty
              ? (currentState as BookmarkEntryLoaded).copyWith(hasReachedMax: true)
              : BookmarkEntryLoaded(
              entries: (currentState as BookmarkEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is FetchBookmarkEntry && event.sourceId > -1 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is BookmarkEntryUninitialized) {
          final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
          yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is BookmarkEntryLoaded) {
          final entries = await entriesRepository.getTimelineOfSource((currentState as BookmarkEntryLoaded).entries.last.pubDate, 1000000, 10, event.sourceId);
          yield entries.isEmpty
              ? (currentState as BookmarkEntryLoaded).copyWith(hasReachedMax: true)
              : BookmarkEntryLoaded(
              entries: (currentState as BookmarkEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is FetchBookmarkEntry && event.sourceId == -2 && !_hasReachedMax(currentState)) {
      try {
        if (currentState is BookmarkEntryUninitialized) {
          final entries = await entriesRepository.getBookmarks(1000000, 10);
          yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is BookmarkEntryLoaded) {
          final entries = await entriesRepository.getBookmarks((currentState as BookmarkEntryLoaded).entries.last.starId, 10);
          yield entries.isEmpty
              ? (currentState as BookmarkEntryLoaded).copyWith(hasReachedMax: true)
              : BookmarkEntryLoaded(
              entries: (currentState as BookmarkEntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is UpdateBookmarkEntry && event.sourceId == -1) {
      try {
        final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
        print(entries);
        yield BookmarkEntryUpdated();
        yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is UpdateBookmarkEntry && event.sourceId == -2) {
      try {
        final entries = await entriesRepository.getBookmarks(1000000, 10);
        print(entries);
        yield BookmarkEntryUpdated();
        yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is UpdateBookmarkEntry && event.sourceId > -1 && !_hasReachedMax(currentState)) {
      try {
        final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
        yield BookmarkEntryUpdated();
        yield BookmarkEntryLoaded(entries: entries, hasReachedMax: false);
      } catch (_) {
        print(_);
        yield BookmarkEntryError();
      }
    } else if (event is StarBookmarkEntry) {
      if (currentState is BookmarkEntryLoaded) {
        final response = await entriesRepository.starEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries = (currentState as BookmarkEntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: true) : entry;
          }).toList();
          yield BookmarkEntryUpdated();
          yield BookmarkEntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield BookmarkEntryMessageArrived('star failed');
          yield BookmarkEntryLoaded(entries: (currentState as BookmarkEntryLoaded).entries, hasReachedMax: false);
        }
      }
    } else if (event is UnstarBookmarkEntry) {
      if (currentState is BookmarkEntryLoaded) {
        final response = await entriesRepository.unstarEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries =
          (currentState as BookmarkEntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: false) : entry;
          }).toList();
          yield BookmarkEntryUpdated();
          yield BookmarkEntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield BookmarkEntryMessageArrived('unstar failed');
          yield BookmarkEntryLoaded(entries: (currentState as BookmarkEntryLoaded).entries, hasReachedMax: false);
        }
      }
    }
  }

  bool _hasReachedMax(BookmarkEntryState state) =>
      state is BookmarkEntryLoaded && state.hasReachedMax;

}