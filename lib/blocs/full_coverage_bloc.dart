import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class FullCoverageEvent extends Equatable {
  FullCoverageEvent([List props = const []]) : super(props);
}

class FetchFullCoverage extends FullCoverageEvent{
  final int cluster;
  FetchFullCoverage({@required this.cluster}):
      super([cluster]);
  @override
  String toString() {
    // TODO: implement toString
    return 'FetchFullCoverage';
  }
}

abstract class FullCoverageState extends Equatable {
  FullCoverageState([List props = const []]) : super(props);
}

class FullCoverageLoading extends FullCoverageState{
  @override
  String toString() {
    // TODO: implement toString
    return 'FullCoverageLoading';
  }
}
class FullCoverageLoaded extends FullCoverageState{
  final List<Entry> entries;
  FullCoverageLoaded({@required this.entries}):
      super([entries]);
  @override
  String toString() {
    // TODO: implement toString
    return 'FullCoverageLoaded';
  }
}

class FullCoverageError extends FullCoverageState{
  @override
  String toString() {
    // TODO: implement toString
    return 'FullCoverageError';
  }
}

class FullCoverageBloc extends Bloc<FullCoverageEvent, FullCoverageState>{
  EntriesRepository entriesRepository;

  FullCoverageBloc({@required this.entriesRepository});

  @override
  // TODO: implement initialState
  FullCoverageState get initialState => FullCoverageLoading();


  @override
  Stream<FullCoverageState> mapEventToState(FullCoverageEvent event) async* {
    // TODO: implement mapEventToState
    if (event is FetchFullCoverage) {
      yield FullCoverageLoading();
      final result = await entriesRepository.getFullCoverage(event.cluster);
      print(result);
      if (result.length > 0) {
        yield FullCoverageLoaded(entries: result);
      } else {
        yield FullCoverageError();
      }
    }
  }
}