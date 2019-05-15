import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';

class BookmarkFolderRepository {
  final BookmarkFolderApiClient bookmarkFolderApiClient;
  List<String> bookmarkFolders = [];
  BookmarkFolderRepository({@required this.bookmarkFolderApiClient}):
        assert(bookmarkFolderApiClient != null);

//  Future<List<BookmarkFolder>> getBookmarkFolders() async {
//    return await bookmarkFolderApiClient.fetchBookmarkFolders();
//  }

  Future<List<String>> getBookmarkFolders() async {
    return await bookmarkFolderApiClient.fetchBookmarkFolders();
  }

  Future<bool> assignBookmarkFolders(int entryId, List<String> folders) async {
    return await bookmarkFolderApiClient.assignBookmarkFolders(entryId, folders);
  }

  Future<bool> renameBookmarkFolder(String oldFolder, String newFolder) async {
    return await bookmarkFolderApiClient.renameBookmarkFolder(oldFolder, newFolder);
  }

  Future<bool> deleteBookmarkFolder(String folder) async {
    return await bookmarkFolderApiClient.deleteBookmarkFolder(folder);
  }
}