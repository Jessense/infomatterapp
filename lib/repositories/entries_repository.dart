import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';


class EntriesRepository {
  final EntriesApiClient entriesApiClient;
  EntriesRepository({
    @required this.entriesApiClient,
  }) : assert(entriesApiClient != null);

  Future<List<Entry>> getEntries(int startIndex, int limit) async {
    return await entriesApiClient.fetchEntries(startIndex, limit);
  }

  Future<List<Entry>> getTimeline(String lastTime, int lastId, int limit) async {
    return await entriesApiClient.fetchTimeline(lastTime, lastId, limit);
  }

}