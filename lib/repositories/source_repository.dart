import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';

class SourceRepository {
  final SourceApiClient sourceApiClient;

  bool showSnackbar = false;
  int sourceId = -1;
  String sourceName = '';

  String target = 'all';


  SourceRepository({@required this.sourceApiClient}): assert(sourceApiClient != null);

  Future<List<Source>> getSources(int lastCount, int lastId, int limit) async {
    return await sourceApiClient.fetchSources(lastCount, lastId, limit);
  }

  Future<List<Source>> getSourcesOfCategory(String cate, int lastCount, int lastId, int limit) async {
    return await sourceApiClient.fetchSourcesOfCategory(cate, lastCount, lastId, limit);
  }

  Future<bool> followSource(int sourceId) async {
    return await sourceApiClient.requestFollow(sourceId);
  }

  Future<bool> unfollowSource(int sourceId) async {
    return await sourceApiClient.requestUnfollow(sourceId);
  }

  Future<int> addSource(Source source) async {
    return await sourceApiClient.addSource(source);
  }

}