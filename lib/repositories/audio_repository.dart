import 'package:meta/meta.dart';
import 'package:http/http.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:preferences/preferences.dart';

class AudioRepository {
  Entry entryPlaying;
  List<Entry> entries = [];
}