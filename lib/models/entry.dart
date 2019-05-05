import 'package:equatable/equatable.dart';

class Entry extends Equatable {
  final int id;
  final String title;
  final String link;
  String digest;
  String pubDate;
  int form;
  String sourcePhoto;
  List<String> photo;
  int sourceId;
  String sourceName;

  bool isStarring;
  bool isReaded;

  int loadChoice;

  int cluster;
  int sim_count;

  //optional
  int starId;

  Entry({this.id, this.title, this.link, this.digest, this.pubDate, this.form, this.sourcePhoto, this.photo, this.sourceId, this.sourceName, this.starId, this.isReaded, this.isStarring, this.loadChoice, this.cluster, this.sim_count}) : super([id, title, link, digest, pubDate, form, sourcePhoto, photo, sourceId, sourceName]);


  Entry copyWith({bool isStarring, bool isReaded}) {
    return Entry(
      id: this.id,
      title: this.title,
      link: this.link,
      digest: this.digest,
      pubDate: this.pubDate,
      form: this.form,
      sourcePhoto: this.sourcePhoto,
      photo: this.photo,
      sourceId: this.sourceId,
      sourceName: this.sourceName,
      starId: this.starId,
      isStarring: isStarring ?? this.isStarring,
      isReaded: isReaded ?? this.isReaded,
      loadChoice: this.loadChoice
    );
  }

  @override
  String toString() => 'Entry { id: $id, tile: $title, link: $link, digest: $digest, pubDate: $pubDate, form: $form, sourcePhoto: $sourcePhoto,'
      'sourceName: $sourceName, starId: $starId, isStarring: $isStarring, isReaded: $isReaded, loadChoice: $loadChoice }';
}