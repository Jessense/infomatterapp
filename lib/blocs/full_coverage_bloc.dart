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

abstract class FullCoverageState extends Equatable {
  FullCoverageState([List props = const []]) : super(props);
}

class FullCoverageUninit extends FullCoverageState{
  @override
  String toString() {
    // TODO: implement toString
    return 'FullCoverageUninit';
  }
}


class FullCoverageBloc extends Bloc<FullCoverageEvent, FullCoverageState>{
  EntryBloc entryBloc;
  FullCoverageBloc({@required this.entryBloc});

  @override
  // TODO: implement initialState
  FullCoverageState get initialState => FullCoverageUninit();


  @override
  Stream<FullCoverageState> mapEventToState(FullCoverageEvent event) async* {
    // TODO: implement mapEventToState

  }
}