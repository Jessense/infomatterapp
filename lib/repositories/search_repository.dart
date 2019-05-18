import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';

class SearchRepository{

  final SearchApiClient searchApiClient;
  SearchRepository(this.searchApiClient);
  String type = 'entry';
  String hint = '请输入内容关键词';

  Future<List<Source>> searchSource(String target) async{
    return await searchApiClient.searchSources(type: this.type, target: target);
  }

}