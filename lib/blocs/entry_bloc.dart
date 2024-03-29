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
  final String folder;
  Fetch({@required this.sourceId, @required this.folder}):
      super([sourceId, folder]);
  @override
  String toString() => 'Fetch';
}

class FetchFullCoverage extends EntryEvent{
  final int cluster;
  FetchFullCoverage({@required this.cluster}):
        super([cluster]);
  @override
  String toString() {
    // TODO: implement toString
    return 'FetchFullCoverage';
  }
}

class Update extends EntryEvent {
  final int sourceId;
  final String folder;
  Update({@required this.sourceId, @required this.folder}):
        super([sourceId, folder]);
  @override
  String toString() => 'Update';
}

class SearchEntry extends EntryEvent{
  final String target;
  SearchEntry({@required this.target}):
      super([target]);
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchEntry';
  }
}

class SearchEntryUpdate extends EntryEvent{
  final String target;
  SearchEntryUpdate({@required this.target}):
        super([target]);
  @override
  String toString() {
    // TODO: implement toString
    return 'SearchEntryUpdate';
  }
}

class StarEntry extends EntryEvent{
  final int entryId;
  final int from; //0: from list, 1: from article
  StarEntry({@required this.entryId, @required this.from}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'StarEntry { entry: $entryId }';
}

class UnstarEntry extends EntryEvent{
  final int entryId;
  UnstarEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'UnstarEntry { entry: $entryId }';
}

class PassEntryLoading extends EntryEvent{
  @override
  String toString() {
    // TODO: implement toString
    return 'PassEntryLoading';
  }
}

class PassEntries extends EntryEvent{
  final List<Entry> entries;
  PassEntries({@required this.entries}):
      super([entries]);
  @override
  String toString() {
    // TODO: implement toString
    return 'PassEntries';
  }
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

class EntryMessageArrived extends EntryState {
  final String message;
  EntryMessageArrived(this.message);
  @override
  String toString() => 'EntryMessageArrived';
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
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
          entriesRepository.entries = entries;
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getTimeline((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10, event.folder);
          entriesRepository.entries = (currentState as EntryLoaded).entries + entries;
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
          entriesRepository.entries = entries;
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getTimelineOfSource((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10, event.sourceId);
          entriesRepository.entries = (currentState as EntryLoaded).entries + entries;
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Fetch && event.sourceId == -3 && !_hasReachedMax(currentState)) {
        try {
          if (currentState is EntryUninitialized) {
            final entries = await entriesRepository.getRecommends("2049-12-31T23:59:59", 1000000, 10);
            entriesRepository.entries = entries;
            yield EntryLoaded(entries: entries, hasReachedMax: false);
          }
          if (currentState is EntryLoaded) {
            final entries = await entriesRepository.getRecommends((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10);
            entriesRepository.entries = (currentState as EntryLoaded).entries + entries;
            yield entries.isEmpty
                ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
                : EntryLoaded(
                entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
          }
        } catch (_) {
          print(_);
          yield EntryError();
        }
    } else if (event is Fetch && event.sourceId == -2) {
      try {
        if (currentState is EntryUninitialized) {
          final entries = await entriesRepository.getBookmarks(1000000, 10, event.folder);
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.getBookmarks((currentState as EntryLoaded).entries.last.starId, 10, event.folder);
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is SearchEntry) {
      try {
        if (currentState is EntryUninitialized) {
          final entries = await entriesRepository.searchEntry("2049-12-31T23:59:59", 1000000, 10, event.target);
          entriesRepository.entries = entries;
          yield EntryLoaded(entries: entries, hasReachedMax: false);
        }
        if (currentState is EntryLoaded) {
          final entries = await entriesRepository.searchEntry((currentState as EntryLoaded).entries.last.pubDate, 1000000, 10, event.target);
          entriesRepository.entries = (currentState as EntryLoaded).entries + entries;
          yield entries.isEmpty
              ? (currentState as EntryLoaded).copyWith(hasReachedMax: true)
              : EntryLoaded(
              entries: (currentState as EntryLoaded).entries + entries, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is FetchFullCoverage) {
      final result = await entriesRepository.getFullCoverage(event.cluster);
      print(result);
      if (result.length > 0) {
        yield EntryLoaded(entries: result, hasReachedMax: true);
      } else {
        yield EntryError();
      }
    } else if (event is Update && event.sourceId == -1) {
      try {
          final entries = await entriesRepository.getTimeline("2049-12-31T23:59:59", 1000000, 10, event.folder);
          print(entries);
          entriesRepository.entries = entries;
          yield EntryUpdated();
          yield EntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Update && event.sourceId > -1) {
      try {
          final entries = await entriesRepository.getTimelineOfSource("2049-12-31T23:59:59", 1000000, 10, event.sourceId);
          entriesRepository.entries = entries;
          yield EntryUpdated();
          yield EntryLoaded(entries: entries, hasReachedMax: false);
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is Update && event.sourceId == -2) {
      try {
        final entries = await entriesRepository.getBookmarks(1000000, 10, event.folder);
        print(entries);
        yield EntryUpdated();
        yield EntryLoaded(entries: entries, hasReachedMax: false, timenow: DateTime.now());
      } catch (_) {
        print(_);
        yield EntryError();
      }
    } else if (event is SearchEntryUpdate) {
      final entries = await entriesRepository.searchEntry("2049-12-31T23:59:59", 1000000, 10, event.target);
      entriesRepository.entries = entries;
      yield EntryLoaded(entries: entries, hasReachedMax: false);
    } else if (event is StarEntry) {
      if (currentState is EntryLoaded) {
        final response = await entriesRepository.starEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries = (currentState as EntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: true) : entry;
          }).toList();
          if (event.from == 0)
            entriesRepository.showStarred = true;
          else
            entriesRepository.showStarred2 = true;
          entriesRepository.lastStarId = event.entryId;
          entriesRepository.entries = updatedEntries;
          yield EntryUpdated();
          yield EntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield EntryLoaded(entries: (currentState as EntryLoaded).entries, hasReachedMax: false);
        }
      }
    } else if (event is Update && event.sourceId == -3) {
      final entries = await entriesRepository.getRecommends("2049-12-31T23:59:59", 1000000, 10);
      entriesRepository.entries = entries;
      yield EntryLoaded(entries: entries, hasReachedMax: false);
    } else if (event is UnstarEntry) {
      if (currentState is EntryLoaded) {
        final response = await entriesRepository.unstarEntry(event.entryId);
        if (response) {
          final List<Entry> updatedEntries =
          (currentState as EntryLoaded).entries.map((entry) {
            return entry.id == event.entryId ? entry.copyWith(isStarring: false) : entry;
          }).toList();
          entriesRepository.entries = updatedEntries;
          yield EntryUpdated();
          yield EntryLoaded(entries: updatedEntries, hasReachedMax: false);
        } else {
          yield EntryLoaded(entries: (currentState as EntryLoaded).entries, hasReachedMax: false);
        }
      }
    } else if (event is PassEntryLoading) {
      yield EntryUninitialized();
      print(currentState);
    } else if (event is PassEntries) {
      yield EntryLoaded(entries: event.entries, hasReachedMax: false);
    }
  }

  bool _hasReachedMax(EntryState state) =>
      state is EntryLoaded && state.hasReachedMax;

}