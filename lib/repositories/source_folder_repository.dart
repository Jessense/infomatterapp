import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';

class SourceFolderRepository {
  final SourceFolderApiClient sourceFolderApiClient;
  List<SourceFolder> sourceFolders = [];
  SourceFolderRepository({@required this.sourceFolderApiClient}):
      assert(sourceFolderApiClient != null);

  Future<List<SourceFolder>> getSourceFolders() async {
    return await sourceFolderApiClient.fetchSourceFolders();
  }

  Future<List<String>> getSourceFolderNames() async {
    return await sourceFolderApiClient.fetchSourceFolderNames();
  }

  Future<bool> assignSourceFolders(int sourceId, List<String> folders) async {
    return await sourceFolderApiClient.assignSourceFolders(sourceId, folders);
  }

  Future<bool> renameSourceFolder(String oldFolder, String newFolder) async {
    return await sourceFolderApiClient.renameSourceFolder(oldFolder, newFolder);
  }

  Future<bool> deleteSourceFolder(String folder) async {
    return await sourceFolderApiClient.deleteSourceFolder(folder);
  }
}