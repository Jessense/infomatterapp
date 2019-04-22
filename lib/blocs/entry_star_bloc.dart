import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class EntryStarEvent extends Equatable {
  EntryStarEvent([List props = const []]) : super(props);
}

class StarEntry extends EntryStarEvent{
  final int entryId;
  StarEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'StarEntry { entry: $entryId }';
}

class UnstarEntry extends EntryStarEvent{
  final int entryId;
  UnstarEntry({@required this.entryId}):
        assert(entryId != null),
        super([entryId]);

  @override
  String toString() => 'UnstarEntry { entry: $entryId }';
}

abstract class EntryStarState extends Equatable {
  EntryStarState([List props = const []]) : super(props);
}

class EntryStarring extends EntryStarState{
  @override
  String toString() => "EntryStarring";
}

class EntryNotStarring extends EntryStarState{
  @override
  String toString() => "EntryNotStarring";
}


class EntryStarBloc extends Bloc<EntryStarEvent, EntryStarState>{
  final EntriesRepository entryRepository;
  final EntryStarState fromState;

  EntryStarBloc({@required this.entryRepository, @required this.fromState});

  @override
  // TODO: implement initialState
  EntryStarState get initialState => fromState;

  @override
  Stream<EntryStarState> mapEventToState(EntryStarEvent event) async* {
    // TODO: implement mapEventToState
    if (event is StarEntry) {
      final response = await entryRepository.starEntry(event.entryId);
      if (response) {
        yield EntryStarring();
      } else {
        yield EntryNotStarring();
      }
    } else if (event is UnstarEntry) {
      final response = await entryRepository.unstarEntry(event.entryId);
      if (response) {
        yield EntryNotStarring();
      } else {
        yield EntryStarring();
      }
    }
  }
}