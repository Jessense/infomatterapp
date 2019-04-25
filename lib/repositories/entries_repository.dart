import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';


class EntriesRepository {
  final EntriesApiClient entriesApiClient;
  EntriesRepository({
    @required this.entriesApiClient,
  }) : assert(entriesApiClient != null);

  Future<List<Entry>> getTimeline(String lastTime, int lastId, int limit, String folder) async {
    return await entriesApiClient.fetchTimeline(lastTime, lastId, limit, folder);
  }

  Future<List<Entry>> getTimelineOfSource(String lastTime, int lastId, int limit, int sourceId) async {
    return await entriesApiClient.fetchTimelineOfSource(lastTime, lastId, limit, sourceId);
  }

  Future<List<Entry>> getBookmarks(int lastId, int limit) async {
    return await entriesApiClient.fetchBookmark(lastId, limit);
  }

  Future<bool> starEntry(int entryId) async {
    return await entriesApiClient.requestStar(entryId);
  }

  Future<bool> unstarEntry(int entryId) async {
    return await entriesApiClient.requestUnstar(entryId);
  }

}