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

abstract class BookmarkEntryState extends Equatable {
  BookmarkEntryState([List props = const []]) : super(props);
}

class BookmarkUninitialized extends BookmarkEntryState {
  @override
  String toString() => 'BookmarkUninitialized';
}









class BookmarkEntryBloc extends Bloc<BookmarkEntryEvent, BookmarkEntryState> {
  EntryBloc entryBloc;

  BookmarkEntryBloc({@required this.entryBloc});

  @override
  get initialState => BookmarkUninitialized();

  @override
  Stream<BookmarkEntryState> mapEventToState(event) async* {
  }


}