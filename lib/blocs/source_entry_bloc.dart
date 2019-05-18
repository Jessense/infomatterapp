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

abstract class SourceEntryState extends Equatable {
  SourceEntryState([List props = const []]) : super(props);
}

class SourceEntryUninit extends SourceEntryState {
  @override
  String toString() => 'SourceEntryUninitialized';
}



class SourceEntryBloc extends Bloc<SourceEntryEvent, SourceEntryState> {
  EntryBloc entryBloc;
  SourceEntryBloc({@required this.entryBloc});



  @override
  get initialState => SourceEntryUninit();

  @override
  Stream<SourceEntryState> mapEventToState(event) async* {

  }

}