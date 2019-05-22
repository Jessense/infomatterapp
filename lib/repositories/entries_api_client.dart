import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class EntriesApiClient {
  static const baseUrl = 'http://api.infomatter.cn';
  final http.Client httpClient;

  EntriesApiClient({@required this.httpClient}) : assert(httpClient != null);



  Future<List<Entry>> fetchTimeline(String lastTime, int lastId, int limit, String tag, bool unreadOnly) async {
    String url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit';
    if (unreadOnly) {
      url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit&&unread';
    }
    if (tag.length > 0) {
      url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit&tag=$tag';
      if (unreadOnly) {
        url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit&tag=$tag&&unread';
      }
    }
    final response = await httpClient.get(
        url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(url);
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
              id: rawEntry['id'],
              title: rawEntry['title'],
              link: rawEntry['link'],
              digest: rawEntry['digest'],
              pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: _isNumeric(rawEntry['star_user'].toString()),
              isReaded: _isNumeric(rawEntry['readed_user'].toString()),
              loadChoice: rawEntry['content_rss'],
              cluster: rawEntry['cluster'],
              sim_count: rawEntry['sim_count'],
              video: rawEntry['video'],
              videoFrame: rawEntry['video_frame'],
              audio: rawEntry['audio'],
              audioFrame: rawEntry['audio_frame'],
          );
        }
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          link: rawEntry['link'],
          digest: rawEntry['digest'],
          pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
          form: rawEntry['form'],
          sourcePhoto: rawEntry['source_photo'],
          photo: [rawEntry['photo']],
          sourceId: rawEntry['source_id'],
          sourceName: rawEntry['source_name'],
          isStarring: _isNumeric(rawEntry['star_user'].toString()),
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }

  Future<List<Entry>> fetchTimelineOfSource(String lastTime, int lastId, int limit, int sourceId, bool unreadOnly) async {
    String url = '$baseUrl/sources/timeline?source_id=$sourceId&last_time=$lastTime&last_id=$lastId&batch_size=$limit';
    if (unreadOnly) {
      url = '$baseUrl/sources/timeline?source_id=$sourceId&last_time=$lastTime&last_id=$lastId&batch_size=$limit&&unread';
    }
    final response = await httpClient.get(
        url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
              id: rawEntry['id'],
              title: rawEntry['title'],
              link: rawEntry['link'],
              digest: rawEntry['digest'],
              pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: _isNumeric(rawEntry['star_user'].toString()),
            isReaded: _isNumeric(rawEntry['readed_user'].toString()),
            loadChoice: rawEntry['content_rss'],
            cluster: rawEntry['cluster'],
            sim_count: rawEntry['sim_count'],
            video: rawEntry['video'],
            videoFrame: rawEntry['video_frame'],
            audio: rawEntry['audio'],
            audioFrame: rawEntry['audio_frame'],
          );
        }
        return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  [rawEntry['photo']],
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: _isNumeric(rawEntry['star_user'].toString()),
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }

  Future<List<Entry>> fetchRecommends(String lastTime, int lastId, int limit, bool unreadOnly) async {
    String url = '$baseUrl/users/recommendation?last_time=$lastTime&last_id=$lastId&batch_size=$limit';
    if (unreadOnly) {
      url = '$baseUrl/users/recommendation?last_time=$lastTime&last_id=$lastId&batch_size=$limit&&unread';
    }
    final response = await httpClient.get(
        url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(url);
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  (json.decode(rawEntry['photo']) as List).map((img) {
              return img.toString();
            }).toList(),
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: _isNumeric(rawEntry['star_user'].toString()),
            isReaded: _isNumeric(rawEntry['readed_user'].toString()),
            loadChoice: rawEntry['content_rss'],
            cluster: rawEntry['cluster'],
            sim_count: rawEntry['sim_count'],
            video: rawEntry['video'],
            videoFrame: rawEntry['video_frame'],
            audio: rawEntry['audio'],
            audioFrame: rawEntry['audio_frame'],
          );
        }
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          link: rawEntry['link'],
          digest: rawEntry['digest'],
          pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
          form: rawEntry['form'],
          sourcePhoto: rawEntry['source_photo'],
          photo: [rawEntry['photo']],
          sourceId: rawEntry['source_id'],
          sourceName: rawEntry['source_name'],
          isStarring: _isNumeric(rawEntry['star_user'].toString()),
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }


  Future<List<Entry>> fetchBookmark(int lastId, int limit, String folder) async {
    String url = "$baseUrl/users/starring?last_id=$lastId&batch_size=$limit";
    if (folder.length > 0) {
      url = "$baseUrl/users/starring?last_id=$lastId&batch_size=$limit&tag=$folder";
    }
    print(url);
    final response = await httpClient.get(
        url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
              id: rawEntry['id'],
              title: rawEntry['title'],
              link: rawEntry['link'],
              digest: rawEntry['digest'],
              pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: true,
            isReaded: _isNumeric(rawEntry['readed_user'].toString()),
            loadChoice: rawEntry['content_rss'],
            cluster: rawEntry['cluster'],
            sim_count: rawEntry['sim_count'],
            video: rawEntry['video'],
            videoFrame: rawEntry['video_frame'],
            audio: rawEntry['audio'],
            audioFrame: rawEntry['audio_frame'],
            starId: rawEntry['star_id'],
          );
        }
        return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  [rawEntry['photo']],
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: true,
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
          starId: rawEntry['star_id'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }

  Future<List<Entry>> searchEntry(String lastTime, int lastId, int limit, String target) async {
    String url = '$baseUrl/entries/search?keyword=$target&last_time=$lastTime&last_id=$lastId&batch_size=$limit';
    final response = await httpClient.get(
        url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(url);
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  (json.decode(rawEntry['photo']) as List).map((img) {
              return img.toString();
            }).toList(),
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: _isNumeric(rawEntry['star_user'].toString()),
            isReaded: _isNumeric(rawEntry['readed_user'].toString()),
            loadChoice: rawEntry['content_rss'],
            cluster: rawEntry['cluster'],
            sim_count: rawEntry['sim_count'],
            video: rawEntry['video'],
            videoFrame: rawEntry['video_frame'],
            audio: rawEntry['audio'],
            audioFrame: rawEntry['audio_frame'],
          );
        }
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          link: rawEntry['link'],
          digest: rawEntry['digest'],
          pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
          form: rawEntry['form'],
          sourcePhoto: rawEntry['source_photo'],
          photo: [rawEntry['photo']],
          sourceId: rawEntry['source_id'],
          sourceName: rawEntry['source_name'],
          isStarring: _isNumeric(rawEntry['star_user'].toString()),
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }

  Future<List<Entry>> fetchFullCoverage(int cluster) async {
    final response = await httpClient.get(
        '$baseUrl/entries/cluster/$cluster',
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        if (rawEntry['form'] == 2) {
          return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  (json.decode(rawEntry['photo']) as List).map((img) {
              return img.toString();
            }).toList(),
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: _isNumeric(rawEntry['star_user'].toString()),
            isReaded: _isNumeric(rawEntry['readed_user'].toString()),
            loadChoice: rawEntry['content_rss'],
            cluster: rawEntry['cluster'],
            sim_count: rawEntry['sim_count'],
            video: rawEntry['video'],
            videoFrame: rawEntry['video_frame'],
            audio: rawEntry['audio'],
            audioFrame: rawEntry['audio_frame'],
          );
        }
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          link: rawEntry['link'],
          digest: rawEntry['digest'],
          pubDate: DateTime.parse(rawEntry['time']).toLocal().toIso8601String(),
          form: rawEntry['form'],
          sourcePhoto: rawEntry['source_photo'],
          photo: [rawEntry['photo']],
          sourceId: rawEntry['source_id'],
          sourceName: rawEntry['source_name'],
          isStarring: _isNumeric(rawEntry['star_user'].toString()),
          isReaded: _isNumeric(rawEntry['readed_user'].toString()),
          loadChoice: rawEntry['content_rss'],
          cluster: rawEntry['cluster'],
          sim_count: rawEntry['sim_count'],
          video: rawEntry['video'],
          videoFrame: rawEntry['video_frame'],
          audio: rawEntry['audio'],
          audioFrame: rawEntry['audio_frame'],
        );
      }).toList();
    } else {
      print('error fetching entries');
      return [];
    }
  }

  Future<bool> markAsRead(List<int> entries) async{
    final entriesStr = '[' + entries.join(',') + ']';
    print(entriesStr);
    final response = await httpClient.post(
        "$baseUrl/users/read",
        body: {
          "entries": entriesStr
        },
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> click(int entryId) async{
    final response = await httpClient.get(
        "$baseUrl/users/read?entry_id=$entryId",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestStar(int entryId) async{
    final response = await httpClient.get("$baseUrl/users/star?entry_id=$entryId",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print("star failed");
      return false;
    }
  }

  Future<bool> requestUnstar(int entryId) async{
    final response = await httpClient.get("$baseUrl/users/unstar?entry_id=$entryId",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);

    if (response.statusCode == 200) {
      return true;
    } else {
      print("unstar failed");
      return false;
    }
  }

  Future<bool> requestUnfollow(int sourceId) async{
    final response = await httpClient.get("$baseUrl/users/unfollow?source_id=$sourceId",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  
  Future<String> fetchArticleContent(int entryId) async {
    final url = '$baseUrl/entries/content?entry_id=' + entryId.toString();
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    } else {
      return '';
    }
  }


  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String token =  prefs.getString("token");
    return token;
  }

  bool _isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

}