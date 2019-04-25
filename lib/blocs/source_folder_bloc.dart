import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class SourceFolderEvent extends Equatable {
  SourceFolderEvent([List props = const []]) : super(props);
}

class FetchSourceFolders extends SourceFolderEvent {
  @override
  String toString() => 'FetchSourceFolders';
}



abstract class SourceFolderState extends Equatable {
  SourceFolderState([List props = const []]) : super(props);
}

class SourceFolderUninitialized extends SourceFolderState {
  @override
  String toString() => 'SourceFolderUninitialized';
}

class SourceFolderError extends SourceFolderState {
  @override
  String toString() => 'SourceFolderError';
}

class SourceFolderLoaded extends SourceFolderState {
  final List<SourceFolder> sourceFolders;
  final bool hasReachedMax;

  SourceFolderLoaded({
    this.sourceFolders,
    this.hasReachedMax,
  }) : super([sourceFolders, hasReachedMax]);

  SourceFolderLoaded copyWith({
    List<SourceFolder> sourceFolders,
    bool hasReachedMax,
  }) {
    return SourceFolderLoaded(
      sourceFolders: sourceFolders ?? this.sourceFolders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'SourceFolderLoaded { sourceFolders: ${sourceFolders.length}, hasReachedMax: $hasReachedMax }';
}




class SourceFolderBloc extends Bloc<SourceFolderEvent, SourceFolderState> {
  final SourceFolderRepository sourceFoldersRepository;

  SourceFolderBloc({@required this.sourceFoldersRepository});


  @override
  get initialState => SourceFolderUninitialized();

  @override
  Stream<SourceFolderState> mapEventToState(event) async* {
    if (event is FetchSourceFolders && !_hasReachedMax(currentState)) {
      try {
        if (currentState is SourceFolderUninitialized) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }
        if (currentState is SourceFolderLoaded) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceFolderError();
      }
    }
  }

  bool _hasReachedMax(SourceFolderState state) =>
      state is SourceFolderLoaded && state.hasReachedMax;

}