import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:preferences/preferences.dart';


class EntriesRepository {
  final EntriesApiClient entriesApiClient;
  bool showStarred = false;
  bool showStarred2 = false;
  int lastStarId = -1;

  List<Entry> entries = [];


  EntriesRepository({
    @required this.entriesApiClient,
  }) : assert(entriesApiClient != null);

  Future<List<Entry>> getTimeline(String lastTime, int lastId, int limit, String folder) async {
    return await entriesApiClient.fetchTimeline(lastTime, lastId, limit, folder, PrefService.getBool('unread_only')??true);
  }

  Future<List<Entry>> getTimelineOfSource(String lastTime, int lastId, int limit, int sourceId) async {
    return await entriesApiClient.fetchTimelineOfSource(lastTime, lastId, limit, sourceId, PrefService.getBool('unread_only')??true);
  }

  Future<List<Entry>> getRecommends(String lastTime, int lastId, int limit) async {
    return await entriesApiClient.fetchRecommends(lastTime, lastId, limit, PrefService.getBool('unread_only')??true);
  }

  Future<List<Entry>> getBookmarks(int lastId, int limit, String folder) async {
    return await entriesApiClient.fetchBookmark(lastId, limit, folder);
  }

  Future<List<Entry>> searchEntry(String lastTime, int lastId, int limit, String target) async {
    return await entriesApiClient.searchEntry(lastTime, lastId, limit, target);
  }

  Future<List<Entry>> getFullCoverage(int cluster) async{
    return await entriesApiClient.fetchFullCoverage(cluster);
  }

  Future<String> getArticle(int entryId) async{
    return await entriesApiClient.fetchArticleContent(entryId);
  }

  Future<String> readability(String link) async {
    return await entriesApiClient.readability(link);
  }

  Future<bool> click(int index) async{
    entries[index].isReaded = true;
    return await entriesApiClient.click(entries[index].id);
  }

  Future<bool> markAsRead(int index) async{
    List<int> entryIds = [];
    for (int i = 0; i < index; i ++ ) {
      entries[i].isReaded = true;
      entryIds.add(entries[i].id);
    }
    return await entriesApiClient.markAsRead(entryIds);
  }

  Future<bool> starEntry(int entryId) async {
    return await entriesApiClient.requestStar(entryId);
  }

  Future<bool> unstarEntry(int entryId) async {
    return await entriesApiClient.requestUnstar(entryId);
  }

}