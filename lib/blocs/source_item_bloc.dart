import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class SourceItemEvent extends Equatable {
  SourceItemEvent([List props = const []]) : super(props);
}

class FollowSource extends SourceItemEvent{
  final int sourceId;
  FollowSource({@required this.sourceId}):
        assert(sourceId != null),
        super([sourceId]);

  @override
  String toString() => 'FollowSource { source: $sourceId }';
}

class UnfollowSource extends SourceItemEvent{
  final int sourceId;
  UnfollowSource({@required this.sourceId}):
        assert(sourceId != null),
        super([sourceId]);

  @override
  String toString() => 'UnfollowSource { source: $sourceId }';
}

abstract class SourceItemState extends Equatable {
  SourceItemState([List props = const []]) : super(props);
}

class SourceFollowing extends SourceItemState{
  @override
  String toString() => "SourceFollowing";
}

class SourceNotFollowing extends SourceItemState{
  @override
  String toString() => "SourceNotFollowing";
}


class SourceItemBloc extends Bloc<SourceItemEvent, SourceItemState>{
  final SourceRepository sourcesRepository;
  final SourceItemState fromState;

  SourceItemBloc({@required this.sourcesRepository, @required this.fromState});

  @override
  // TODO: implement initialState
  SourceItemState get initialState => fromState;

  @override
  Stream<SourceItemState> mapEventToState(SourceItemEvent event) async* {
    // TODO: implement mapEventToState
    if (event is FollowSource) {
      final response = await sourcesRepository.followSource(event.sourceId);
      if (response) {
        yield SourceFollowing();
      } else {
        yield SourceNotFollowing();
      }
    } else if (event is UnfollowSource) {
      final response = await sourcesRepository.unfollowSource(event.sourceId);
      if (response) {
        yield SourceNotFollowing();
      } else {
        yield SourceFollowing();
      }
    }
  }
}