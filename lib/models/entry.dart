import 'package:equatable/equatable.dart';

class Entry extends Equatable {
  final int id;
  final String title;
  final String body;
  String pubDate;

  Entry({this.id, this.title, this.body, this.pubDate}) : super([id, title, body, pubDate]);

  @override
  String toString() => 'Entry { id: $id }';
}