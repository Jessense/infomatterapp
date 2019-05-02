import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class SourceFolderApiClient {
  static const baseUrl = 'http://39.105.127.55:3001';
  final http.Client httpClient;
  SourceFolderApiClient({this.httpClient}): assert(httpClient != null);

  Future<List<SourceFolder>> fetchSourceFolders() async {
    final url = "$baseUrl/users/get_source_tags";
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    print(response.statusCode.toString() + ": " + response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((rawFolder) {
        final String tempStr = rawFolder['list'].toString();
        final int tempLen = tempStr.length;
        final rawSourceList = json.decode(rawFolder['list']) as List;
        List<Source> sourceList = [];
        rawSourceList.forEach((rawSource) {
          if (rawSource['source_id'] != -1) {
            sourceList.add(Source(
                id: rawSource['source_id'],
                name: rawSource['name'],
                photo: rawSource['photo']
            ));
          }
        });
        return SourceFolder(
          sourceFolderName: rawFolder['tag'],
          sourceList: sourceList
        );
      }).toList();
    } else {
      throw Exception('error fetchingSourceFolders');
    }
  }

  Future<List<String>> fetchSourceFolderNames() async {
    final url = "$baseUrl/users/get_source_tag_names";
    final response = await httpClient.get(url,
        headers: {HttpHeaders.authorizationHeader: await getToken()});
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((name) {
        return name['tag'];
      }).toList();
    } else {
      return [''];
    }
  }

  Future<bool> assignSourceFolders(int sourceId, List<String> folders) async {
    final tags = folders.join('|');
    print('sourceId' + sourceId.toString() + ' / tags: ' + tags);
    final url = "$baseUrl/users/add_source_tags?source_id=$sourceId&tags=$tags";
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

  Future<bool> renameSourceFolder(String oldFolder, String newFolder) async {
    final url = '$baseUrl/users/rename_source_tag?old_tag=$oldFolder&tag=$newFolder';
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

  Future<bool> deleteSourceFolder(String folder) async {
    final url = '$baseUrl/users/delete_source_tag?tag=$folder';
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