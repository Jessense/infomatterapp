import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class SearchApiClient {
  static const baseUrl = 'http://api.infomatter.cn';
  final http.Client httpClient;

  SearchApiClient({@required this.httpClient}): assert(httpClient != null);

  Future<List<Source>> searchSources({String type, String target}) async {
    String url = '';
    if (type == 'source') {
      if (target.startsWith('http://') || target.startsWith('https://')) {
        url = url = '$baseUrl/sources/search?feedUrl=$target';
      } else {
        url = '$baseUrl/sources/search?name=$target';
      }
    } else if (type == 'rss') {
      url = '$baseUrl/sources/search?feedUrl=$target';
    } else if (type == 'any') {
      url = '$baseUrl/sources/search?feedUrl=http://127.0.0.1:1200$target';
    } else {
      url = 'http://apisearch.infomatter.cn/$type?keyword=$target';
    }
    print(url);
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print("searchSources: " + response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as List;
        return data.map((rawSource) {
          return Source(
              id: rawSource['id'],
              name: rawSource['name'],
              photo: rawSource['photo'] ?? '',
              description: rawSource['description'] ?? '',
              link: rawSource['link'] ?? '',
              followerCount: rawSource['follower'] ?? 0,
              isFollowing: _isNumeric(rawSource['user_id'].toString()) ?? false,
              feedUrl: rawSource['feedUrl'],
              category: rawSource['category'],
              form: rawSource['form'],
              content_rss: rawSource['content_rss'],
          );
        }).toList();
      } catch(_) {
        print(_);
        return [];
      }
    } else {
      return [];
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