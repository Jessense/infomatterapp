import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final UserApiClient userApiClient;
  String email;
  UserRepository({@required this.userApiClient}): assert(userApiClient != null);




  Future<bool> getVertificationCode (String email) async {
    return await userApiClient.postForCode(email);
  }

  Future<String> signup(String email, String password) async {
    return await userApiClient.postForSignup(email, password);
  }

  Future<String> login(String email, String password) async {
    return await userApiClient.postForLogin(email, password);
  }

  Future<bool> resetPasswordVerify(String email) async{
    return await userApiClient.resetPasswordVerify(email);
  }

  Future<bool> resetPassword(String email, String password, String code) async{
    return await userApiClient.resetPassword(email, password, code);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    return;
  }

  Future<void> persistToken(String token, String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
    prefs.setString('email', email);
    return;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String token =  prefs.getString("token");
    return token;
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final String email =  prefs.getString("email");
    return email;
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return  prefs.containsKey("token");
  }
}
