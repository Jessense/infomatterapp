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

class RenameSourceFolder extends SourceFolderEvent{
  final String oldFolder;
  final String newFolder;
  RenameSourceFolder({@required this.oldFolder, @required this.newFolder}):
      super([oldFolder, newFolder]);
  @override
  String toString() {
    // TODO: implement toString
    return 'RenameSourceFolder';
  }
}

class DeleteSourceFolder extends SourceFolderEvent{
  final String folder;
  DeleteSourceFolder({@required this.folder}):
      super([folder]);
  @override
  String toString() {
    // TODO: implement toString
    return 'DeleteSourceFolder';
  }
}

//class FetchSourceFolderNames extends SourceFolderEvent {
//  @override
//  String toString() => 'FetchSourceFolderNames';
//}

class AssignSourceFolders extends SourceFolderEvent{
  final int sourceId;
  final List<String> folders;
  AssignSourceFolders({@required this.sourceId, @required this.folders}):
        assert(folders != null),
        super([folders]);
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

//class SourceFolderNameLoaded extends SourceFolderState{
//  final List<String> folderNames;
//  SourceFolderNameLoaded({this.folderNames}):
//      super([folderNames]);
//
//  @override
//  String toString() {
//    // TODO: implement toString
//    return 'SourceFolderNameLoaded';
//  }
//}

class SourceFolderUpdated extends SourceFolderState {
  @override
  String toString() => 'SourceFolderUpdated';
}

class SourceFolderMessageArrived extends SourceFolderState {
  final String message;
  SourceFolderMessageArrived({@required this.message}):
      super([message]);
  @override
  String toString() {
    // TODO: implement toString
    return 'SourceFolderMessageArrived';
  }
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
          sourceFoldersRepository.sourceFolders = sourceFolders;
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }
        if (currentState is SourceFolderLoaded) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          sourceFoldersRepository.sourceFolders = sourceFolders;
          yield SourceFolderUpdated();
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield SourceFolderError();
      }
    } else if (event is AssignSourceFolders) {
      print('hihihi');
      if (currentState is SourceFolderLoaded) {
        final result = await sourceFoldersRepository.assignSourceFolders(event.sourceId, event.folders);
        print(result);
        if (result) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          sourceFoldersRepository.sourceFolders = sourceFolders;
        }
      }
    } else if (event is RenameSourceFolder) {
      if (currentState is SourceFolderLoaded) {
        final result = await sourceFoldersRepository.renameSourceFolder(event.oldFolder, event.newFolder);
        if (result) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          sourceFoldersRepository.sourceFolders = sourceFolders;
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }
      }
    } else if (event is DeleteSourceFolder) {
      if (currentState is SourceFolderLoaded) {
        final result = await sourceFoldersRepository.deleteSourceFolder(event.folder);
        if (result) {
          final sourceFolders = await sourceFoldersRepository.getSourceFolders();
          sourceFoldersRepository.sourceFolders = sourceFolders;
          yield SourceFolderUpdated();
          yield SourceFolderLoaded(sourceFolders: sourceFolders, hasReachedMax: false);
        }

      }
    }
  }

  bool _hasReachedMax(SourceFolderState state) =>
      state is SourceFolderLoaded && state.hasReachedMax;

}