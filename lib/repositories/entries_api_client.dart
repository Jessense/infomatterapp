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

  Future<List<Entry>> fetchEntries(int startIndex, int limit) async {
    final response = await httpClient.get(
        'https://jsonplaceholder.typicode.com/posts?_start=$startIndex&_limit=$limit');
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          body: rawEntry['body'],
        );
      }).toList();
    } else {
      throw Exception('error fetching entries');
    }
  }

  Future<List<Entry>> fetchTimeline(String lastTime, int lastId, int limit) async {
    final response = await httpClient.get(
        '$baseUrl/users/timeline?last_time=$lastTime&last_id=$lastId&batch_size=$limit',
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawEntry) {
        return Entry(
          id: rawEntry['id'],
          title: rawEntry['title'],
          body: rawEntry['digest'],
          pubDate: rawEntry['time']
        );
      }).toList();
    } else {
      throw Exception('error fetching entries');
    }
  }


  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String token =  prefs.getString("token");
    return token;
  }
}