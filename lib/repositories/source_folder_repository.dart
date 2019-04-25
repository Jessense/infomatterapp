import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';

class SourceFolderRepository {
  final SourceFolderApiClient sourceFolderApiClient;
  SourceFolderRepository({@required this.sourceFolderApiClient}):
      assert(sourceFolderApiClient != null);

  Future<List<SourceFolder>> getSourceFolders() async {
    return await sourceFolderApiClient.fetchSourceFolders();
  }
}