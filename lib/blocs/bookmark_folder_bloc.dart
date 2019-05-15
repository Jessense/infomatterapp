import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';

abstract class BookmarkFolderEvent extends Equatable {
  BookmarkFolderEvent([List props = const []]) : super(props);
}

class FetchBookmarkFolders extends BookmarkFolderEvent {
  @override
  String toString() => 'FetchBookmarkFolders';
}

class RenameBookmarkFolder extends BookmarkFolderEvent{
  final String oldFolder;
  final String newFolder;
  RenameBookmarkFolder({@required this.oldFolder, @required this.newFolder}):
        super([oldFolder, newFolder]);
  @override
  String toString() {
    // TODO: implement toString
    return 'RenameBookmarkFolder';
  }
}

class DeleteBookmarkFolder extends BookmarkFolderEvent{
  final String folder;
  DeleteBookmarkFolder({@required this.folder}):
        super([folder]);
  @override
  String toString() {
    // TODO: implement toString
    return 'DeleteBookmarkFolder';
  }
}

//class FetchBookmarkFolderNames extends BookmarkFolderEvent {
//  @override
//  String toString() => 'FetchBookmarkFolderNames';
//}

class AssignBookmarkFolders extends BookmarkFolderEvent{
  final int entryId;
  final List<String> folders;
  AssignBookmarkFolders({@required this.entryId, @required this.folders}):
        assert(folders != null),
        super([folders]);
}

abstract class BookmarkFolderState extends Equatable {
  BookmarkFolderState([List props = const []]) : super(props);
}

class BookmarkFolderUninitialized extends BookmarkFolderState {
  @override
  String toString() => 'BookmarkFolderUninitialized';
}

class BookmarkFolderError extends BookmarkFolderState {
  @override
  String toString() => 'BookmarkFolderError';
}

class BookmarkFolderLoaded extends BookmarkFolderState {
  final List<String> bookmarkFolders;
  final bool hasReachedMax;

  BookmarkFolderLoaded({
    this.bookmarkFolders,
    this.hasReachedMax,
  }) : super([bookmarkFolders, hasReachedMax]);

  BookmarkFolderLoaded copyWith({
    List<String> bookmarkFolders,
    bool hasReachedMax,
  }) {
    return BookmarkFolderLoaded(
      bookmarkFolders: bookmarkFolders ?? this.bookmarkFolders,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() =>
      'BookmarkFolderLoaded { bookmarkFolders: ${bookmarkFolders.length}, hasReachedMax: $hasReachedMax }';
}

//class BookmarkFolderNameLoaded extends BookmarkFolderState{
//  final List<String> folderNames;
//  BookmarkFolderNameLoaded({this.folderNames}):
//      super([folderNames]);
//
//  @override
//  String toString() {
//    // TODO: implement toString
//    return 'BookmarkFolderNameLoaded';
//  }
//}

class BookmarkFolderUpdated extends BookmarkFolderState {
  @override
  String toString() => 'BookmarkFolderUpdated';
}

class BookmarkFolderMessageArrived extends BookmarkFolderState {
  final String message;
  BookmarkFolderMessageArrived({@required this.message}):
        super([message]);
  @override
  String toString() {
    // TODO: implement toString
    return 'BookmarkFolderMessageArrived';
  }
}


class BookmarkFolderBloc extends Bloc<BookmarkFolderEvent, BookmarkFolderState> {
  final BookmarkFolderRepository bookmarkFoldersRepository;

  BookmarkFolderBloc({@required this.bookmarkFoldersRepository});


  @override
  get initialState => BookmarkFolderUninitialized();

  @override
  Stream<BookmarkFolderState> mapEventToState(event) async* {
    if (event is FetchBookmarkFolders && !_hasReachedMax(currentState)) {
      try {
        if (currentState is BookmarkFolderUninitialized) {
          final bookmarkFolders = await bookmarkFoldersRepository.getBookmarkFolders();
          bookmarkFoldersRepository.bookmarkFolders = bookmarkFolders;
          yield BookmarkFolderLoaded(bookmarkFolders: bookmarkFolders, hasReachedMax: false);
        }
        if (currentState is BookmarkFolderLoaded) {
          final bookmarkFolders = await bookmarkFoldersRepository.getBookmarkFolders();
          bookmarkFoldersRepository.bookmarkFolders = bookmarkFolders;
          yield BookmarkFolderUpdated();
          yield BookmarkFolderLoaded(bookmarkFolders: bookmarkFolders, hasReachedMax: false);
        }
      } catch (_) {
        print(_);
        yield BookmarkFolderError();
      }
    } else if (event is AssignBookmarkFolders) {
      print('hihihi');
      if (currentState is BookmarkFolderLoaded) {
        final result = await bookmarkFoldersRepository.assignBookmarkFolders(event.entryId, event.folders);
        print(result);
        if (result) {
          final bookmarkFolders = await bookmarkFoldersRepository.getBookmarkFolders();
          bookmarkFoldersRepository.bookmarkFolders = bookmarkFolders;
          yield BookmarkFolderLoaded(bookmarkFolders: bookmarkFolders, hasReachedMax: false);
        }
      }
    } else if (event is RenameBookmarkFolder) {
      if (currentState is BookmarkFolderLoaded) {
        final result = await bookmarkFoldersRepository.renameBookmarkFolder(event.oldFolder, event.newFolder);
        if (result) {
          final bookmarkFolders = await bookmarkFoldersRepository.getBookmarkFolders();
          bookmarkFoldersRepository.bookmarkFolders = bookmarkFolders;
          yield BookmarkFolderLoaded(bookmarkFolders: bookmarkFolders, hasReachedMax: false);
        }
      }
    } else if (event is DeleteBookmarkFolder) {
      if (currentState is BookmarkFolderLoaded) {
        final result = await bookmarkFoldersRepository.deleteBookmarkFolder(event.folder);
        if (result) {
          final bookmarkFolders = await bookmarkFoldersRepository.getBookmarkFolders();
          bookmarkFoldersRepository.bookmarkFolders = bookmarkFolders;
          yield BookmarkFolderLoaded(bookmarkFolders: bookmarkFolders, hasReachedMax: false);
        }

      }
    }
  }

  bool _hasReachedMax(BookmarkFolderState state) =>
      state is BookmarkFolderLoaded && state.hasReachedMax;

}