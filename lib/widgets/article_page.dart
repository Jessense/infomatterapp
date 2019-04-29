import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infomatterapp/blocs/article_bloc.dart';
import 'package:infomatterapp/blocs/entry_star_bloc.dart';
import 'package:infomatterapp/repositories/repositories.dart';


class ArticlePage extends StatefulWidget{
  final String title;
  final String link;
  final int id;
  final String sourceName;
  final String time;
  final int loadChoice; //1: full-text rss - from server;
  final EntryStarBloc entryStarBloc;
  ArticlePage({Key key, this.title, this.link, this.id, this.sourceName, this.time, this.loadChoice, this.entryStarBloc}):
      super(key: key);
  @override
  State<ArticlePage> createState() {
    // TODO: implement createState
    return ArticlePageState();
  }
}

class ArticlePageState extends State<ArticlePage> {
  ArticleBloc articleBloc;
  String get _title => widget.title;
  String get _link => widget.link;
  int get _id => widget.id;
  String get _sourceName => widget.sourceName;
  String get _time => widget.time;
  int get _loadChoice => widget.loadChoice;

  EntryStarBloc get entryStarBloc => widget.entryStarBloc;

  String header;
  final String css = "<style>p{font-size :16px !important;line-height:30px !important}</style><style>a{color:#4285F4; text-decoration:none}</style><body style=\"margin: 0; padding: 20\"><style>img{max-width: 100%; width:auto; height: auto;}</style>";

  @override
  void initState() {
    // TODO: implement initState
  if (_loadChoice == 1) {
    articleBloc = ArticleBloc(
      entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
    );
    articleBloc.dispatch(FetchArticle(entryId: _id));
  }

    header = "<h2>" + "<a href=\"" + _link + "\" style=\"color:#000000\">" + _title + "</a>" + "</h2>" + "<i>" + _sourceName + " / " + _time + "</i><p>";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (_loadChoice == 1) {
      return BlocBuilder(
        bloc: articleBloc,
        builder: (BuildContext context, ArticleState state) {
          if (state is ArticleUninitialized) {
            return Scaffold(
              appBar: articleAppBar(),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is ArticleLoaded) {
            return WebviewScaffold(
              appBar: articleAppBar(),
              url: Uri.dataFromString(header + state.content + css, mimeType: 'text/html', encoding: utf8).toString(),
              hidden: true,
            );
          }
        },
      );
    } else {
      return WebviewScaffold(
        appBar: articleAppBar(),
        url: _link,
        hidden: true,
      );
    }
  }

  Widget articleAppBar() {
    return AppBar(
      actions: <Widget>[
        BlocBuilder(
          bloc: entryStarBloc,
          builder: (BuildContext context, EntryStarState state) {
            return IconButton(
              icon: state is EntryStarring ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
              onPressed: () {
                if (state is EntryStarring) {
                  entryStarBloc.dispatch(UnstarEntry(entryId: _id));
                } else {
                  entryStarBloc.dispatch(StarEntry(entryId: _id));
                }
              },
            );
          },
        )
      ],
    );
  }
}