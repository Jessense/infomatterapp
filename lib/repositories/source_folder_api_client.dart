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
        List rawSourceList;
        if (tempLen >= 2 && tempStr[tempLen - 2] == ',') {
          rawSourceList = json.decode(tempStr.substring(0, tempLen-2) + tempStr.substring(tempLen-1)) as List;
        }
        else {
          rawSourceList = json.decode(rawFolder['list']) as List;
        }
        return SourceFolder(
          sourceFolderName: rawFolder['tag'],
          sourceList: rawSourceList.map((rawSource) {
            return Source(
              id: rawSource['source_id'],
              name: rawSource['name'],
              photo: rawSource['photo']
            );
          }).toList()
        );
      }).toList();
    } else {
      throw Exception('error fetchingSourceFolders');
    }
  }


  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String token =  prefs.getString("token");
    return token;
  }
}