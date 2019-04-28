import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class EntriesApiClient {
  static const baseUrl = 'http://39.105.127.55:3001';
  final http.Client httpClient;

  EntriesApiClient({@required this.httpClient}) : assert(httpClient != null);



  Future<List<Entry>> fetchTimeline(String lastTime, int lastId, int limit, String tag) async {
    String url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit';
    if (tag.length > 0) {
      url = '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit&tag=$tag';
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
              pubDate: rawEntry['time'],
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: _isNumeric(rawEntry['star_user'].toString())
          );
        }
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          link: rawEntry['link'],
          digest: rawEntry['digest'],
          pubDate: rawEntry['time'],
          form: rawEntry['form'],
          sourcePhoto: rawEntry['source_photo'],
          photo: [rawEntry['photo']],
          sourceId: rawEntry['source_id'],
          sourceName: rawEntry['source_name'],
          isStarring: _isNumeric(rawEntry['star_user'].toString())
        );
      }).toList();
    } else {
      print('error fetching entries');
      return null;
    }
  }

  Future<List<Entry>> fetchTimelineOfSource(String lastTime, int lastId, int limit, int sourceId) async {
    final response = await httpClient.get(
        '$baseUrl/sources/timeline?source_id=$sourceId&last_time=$lastTime&last_id=$lastId&batch_size=$limit',
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
              pubDate: rawEntry['time'],
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: _isNumeric(rawEntry['star_user'].toString())
          );
        }
        return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: rawEntry['time'],
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  [rawEntry['photo']],
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: _isNumeric(rawEntry['star_user'].toString())
        );
      }).toList();
    } else {
      print('error fetching entries');
      return null;
    }
  }


  Future<List<Entry>> fetchBookmark(int lastId, int limit) async {
    final response = await httpClient.get(
        '$baseUrl/users/starring?last_id=$lastId&batch_size=$limit',
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
              pubDate: rawEntry['time'],
              form: rawEntry['form'],
              sourcePhoto: rawEntry['source_photo'],
              photo:  (json.decode(rawEntry['photo']) as List).map((img) {
                return img.toString();
              }).toList(),
              sourceId: rawEntry['source_id'],
              sourceName: rawEntry['source_name'],
              isStarring: true
          );
        }
        return Entry(
            id: rawEntry['id'],
            title: rawEntry['title'],
            link: rawEntry['link'],
            digest: rawEntry['digest'],
            pubDate: rawEntry['time'],
            form: rawEntry['form'],
            sourcePhoto: rawEntry['source_photo'],
            photo:  [rawEntry['photo']],
            sourceId: rawEntry['source_id'],
            sourceName: rawEntry['source_name'],
            isStarring: true
        );
      }).toList();
    } else {
      print('error fetching entries');
      return null;
    }
  }

  Future<bool> requestStar(int entryId) async{
    final response = await httpClient.get("$baseUrl/users/star?entry_id=$entryId",
        headers: {HttpHeaders.authorizationHeader: await getToken()});
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