import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:shimmer/shimmer.dart';

abstract class ArticleEvent extends Equatable {
  ArticleEvent([List props = const []]) : super(props);
}

class FetchArticle extends ArticleEvent{
  final int entryId;
  FetchArticle({this.entryId}):
      super([entryId]);
  @override
  String toString() {
    // TODO: implement toString
    return 'FetchArticle';
  }
}

class FetchReadability extends ArticleEvent{
  final String link;
  FetchReadability({this.link}):
      super([link]);
  @override
  String toString() {
    // TODO: implement toString
    return 'FetchReadability';
  }
}

abstract class ArticleState extends Equatable {
  ArticleState([List props = const []]) : super(props);
}

class ArticleUninitialized extends ArticleState{
  @override
  String toString() {
    // TODO: implement toString
    return 'ArticleUninitialized';
  }
}

class ArticleLoaded extends ArticleState{
  final String content;
  ArticleLoaded({this.content}):
      super([content]);
  @override
  String toString() {
    // TODO: implement toString
    return 'ArticleLoaded';
  }
}

class ArticleError extends ArticleState{
  @override
  String toString() {
    // TODO: implement toString
    return 'ArticleError';
  }
}

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final EntriesRepository entriesRepository;
  ArticleBloc({this.entriesRepository});

  @override
  // TODO: implement initialState
  ArticleState get initialState => ArticleUninitialized();

  @override
  Stream<ArticleState> mapEventToState(ArticleEvent event) async* {
    // TODO: implement mapEventToState
    if (event is FetchArticle) {
      yield ArticleUninitialized();
      final content = await entriesRepository.getArticle(event.entryId);
      yield ArticleLoaded(content: content);
    } else if (event is FetchReadability) {
      yield ArticleUninitialized();
      final content = await entriesRepository.readability(event.link);
      yield ArticleLoaded(content: content);      
    }
  }
}