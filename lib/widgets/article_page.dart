import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infomatterapp/blocs/article_bloc.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/blocs/entry_bloc.dart';
import 'package:infomatterapp/models/entry.dart';

class ArticlePage extends StatefulWidget{
  final Entry entry;//1: full-text rss - from server;
  ArticlePage({Key key, this.entry}):
      super(key: key);
  @override
  State<ArticlePage> createState() {
    // TODO: implement createState
    return ArticlePageState();
  }
}

class ArticlePageState extends State<ArticlePage> {
  ArticleBloc articleBloc;

  EntryBloc get entryBloc => BlocProvider.of<EntryBloc>(context);
  Entry get entry => widget.entry;


  String header;
  final String css = "<style>p{font-size :16px !important;line-height:30px !important}</style><style>a{color:#4285F4; text-decoration:none}</style><body style=\"margin: 0; padding: 20\"><style>img{max-width: 100%; width:auto; height: auto;}</style>";

  @override
  void initState() {
    // TODO: implement initState
  if (entry.loadChoice == 1) {
    articleBloc = ArticleBloc(
      entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
    );
    articleBloc.dispatch(FetchArticle(entryId: entry.id));
  }

    header = "<h2>" + "<a href=\"" + entry.link + "\" style=\"color:#000000\">" + entry.title + "</a>" + "</h2>" + "<i>" + entry.sourceName + " / " + entry.pubDate + "</i><p>";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (entry.loadChoice == 1) {
      return BlocBuilder(
        bloc: articleBloc,
        builder: (BuildContext context, ArticleState state) {
          if (state is ArticleUninitialized) {
            return Scaffold(
              appBar: AppBar(
                actions: <Widget>[
                  BlocBuilder(
                    bloc: entryBloc,
                    builder: (BuildContext context, EntryState state) {
                      return IconButton(
                        icon: entry.isStarring ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
                        onPressed: () {
                          if (!entry.isStarring) {
                            entryBloc.dispatch(StarEntry(entryId: entry.id));
                          } else {
                            entryBloc.dispatch(UnstarEntry(entryId: entry.id));
                          }
                        },
                      );
                    },
                  )
                ],
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is ArticleLoaded) {
            return WebviewScaffold(
              appBar: AppBar(
                actions: <Widget>[
                  BlocBuilder(
                    bloc: entryBloc,
                    builder: (BuildContext context, EntryState state) {
                      return IconButton(
                        icon: entry.isStarring ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
                        onPressed: () {
                          if (!entry.isStarring) {
                            entryBloc.dispatch(StarEntry(entryId: entry.id));
                          } else {
                            entryBloc.dispatch(UnstarEntry(entryId: entry.id));
                          }
                        },
                      );
                    },
                  )
                ],
              ),
              url: Uri.dataFromString(header + state.content + css, mimeType: 'text/html', encoding: utf8).toString(),
              hidden: true,
            );
          }
        },
      );
    } else {
      return WebviewScaffold(
        appBar: AppBar(
          actions: <Widget>[
            BlocBuilder(
              bloc: entryBloc,
              builder: (BuildContext context, EntryState state) {
                return IconButton(
                  icon: entry.isStarring ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (!entry.isStarring) {
                      entryBloc.dispatch(StarEntry(entryId: entry.id));
                    } else {
                      entryBloc.dispatch(UnstarEntry(entryId: entry.id));
                    }
                  },
                );
              },
            )
          ],
        ),
        url: entry.link,
        hidden: true,
      );
    }
  }
}

class ArticleAppBar extends StatelessWidget {
  final Entry entry;
  ArticleAppBar(this.entry);
  @override
  Widget build(BuildContext context) {
    final entryBloc = BlocProvider.of<EntryBloc>(context);
    // TODO: implement build
    return AppBar(
      actions: <Widget>[
        BlocBuilder(
          bloc: entryBloc,
          builder: (BuildContext context, EntryState state) {
            return IconButton(
              icon: entry.isStarring ? Icon(Icons.bookmark) : Icon(Icons.bookmark_border),
              onPressed: () {
                if (!entry.isStarring) {
                  entryBloc.dispatch(StarEntry(entryId: entry.id));
                } else {
                  entryBloc.dispatch(UnstarEntry(entryId: entry.id));
                }
              },
            );
          },
        )
      ],
    );
  }
}
