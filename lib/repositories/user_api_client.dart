import 'dart:convert';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

import 'package:infomatterapp/models/models.dart';

class UserApiClient {
  static const baseUrl = 'http://api.infomatter.cn';
  final http.Client httpClient;

  UserApiClient({@required this.httpClient}) : assert(httpClient != null);

  Future<bool> postForCode(String email) async {
    final url = "$baseUrl/users/signup_verify";
    final response = await this.httpClient.post(url, body: {
      "email": email
    });
    log("/signup_verify" + response.statusCode.toString() + response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      return false;
    }
  }

  Future<String> postForSignup(String email, String code, String password) async {
    final url = "$baseUrl/users/signup";
    print(email + ',' + password + ',' + code);
    final response = await this.httpClient.post(url, body: {
      "email": email,
      "code": code,
      "password": password
    });
    if (response.statusCode == 200) {
      Map data = json.decode(response.body);
      print(data['token']);
      return data['token'];
    } else {
      print(response.body);
      return 'failed: ' + response.body;
    }

  }

  Future<String> postForLogin(String email, String password) async {
    final url = "$baseUrl/users/login";
    final response = await this.httpClient.post(url, body: {
      "email": email,
      "password": password
    });

    if (response.statusCode == 200) {
      Map data = json.decode(response.body);
      print(data['token']);
      return data['token'];
    } else {
      print(response.body);
      return 'failed: ' + response.body;
    }

  }

  Future<bool> resetPasswordVerify(String email) async {
    final url = "$baseUrl/users/reset_password_verify";
    final response = await this.httpClient.post(url, body: {
      "email": email
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> resetPassword(String email, String password, String code) async{
    final url = "$baseUrl/users/reset_password";
    print(email + ',' + password + ',' + code);
    final response = await this.httpClient.post(url, body: {
      "email": email,
      "code": code,
      "password": password
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}