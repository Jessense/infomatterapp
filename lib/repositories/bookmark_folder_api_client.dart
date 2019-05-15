import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class BookmarkFolderApiClient {
  static const baseUrl = 'http://api.infomatter.cn';
  final http.Client httpClient;
  BookmarkFolderApiClient({this.httpClient}): assert(httpClient != null);

//  Future<List<BookmarkFolder>> fetchBookmarkFolders() async {
//    final url = "$baseUrl/users/get_bookmark_tags";
//    final response = await httpClient.get(url,
//        headers: {HttpHeaders.authorizationHeader: await getToken()});
//    print(response.statusCode.toString() + ": " + response.body);
//    if (response.statusCode == 200) {
//      final data = json.decode(response.body) as List;
//      return data.map((rawFolder) {
//        return rawFolder['tag'];
//      }).toList();
//    } else {
//      throw Exception('error fetchingBookmarkFolders');
//    }
//  }

  Future<List<String>> fetchBookmarkFolders() async {
    final url = "$baseUrl/users/get_star_tags";
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((name) {
        return name['tag'].toString();
      }).toList();
    } else {
      return [''];
    }
  }

  Future<bool> assignBookmarkFolders(int entryId, List<String> folders) async {
    final tags = folders.join('|');
    print('entryId' + entryId.toString() + ' / tags: ' + tags);
    final url = "$baseUrl/users/add_star_tags?entry_id=$entryId&tags=$tags";
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(url);
    print(response.statusCode.toString() + ' : '+ response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> renameBookmarkFolder(String oldFolder, String newFolder) async {
    final url = '$baseUrl/users/rename_star_tag?old_tag=$oldFolder&tag=$newFolder';
    print(url);
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ': ' + response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteBookmarkFolder(String folder) async {
    final url = '$baseUrl/users/delete_star_tag?tag=$folder';
    final response = await httpClient.get(url,
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
}