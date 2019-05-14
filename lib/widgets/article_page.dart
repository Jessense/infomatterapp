import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/entry.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ArticlePage extends StatefulWidget{
  final int type;
  final int index;
  final Entry entry;//1: full-text rss - from server;
  ArticlePage({Key key, this.entry, this.index, this.type}):
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
  int get _index => widget.index;
  int get _type => widget.type;


  String header;
  String colorCSS;

  @override
  void initState() {
    // TODO: implement initState
  if (entry.loadChoice == 1 && entry.form == 1) {
    articleBloc = ArticleBloc(
      entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
    );
    articleBloc.dispatch(FetchArticle(entryId: entry.id));
    header = "<div style=\'font-size:18px;\'>" + "<h2>" +  entry.title + "</h2>" + "</div>" + "<div style=\'font-size:16px;\'>" + "<i>" + entry.sourceName + " / " + _timestamp(entry.pubDate) + "</i></div><br>";

  }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroudColor;
    Color fontColor;
    if (Theme.of(context).brightness == Brightness.light) {
      backgroudColor = Colors.white;
      fontColor = Colors.black;
      colorCSS = '<style>'
          'body {background-color: white; margin: 0; padding: 20;}'
          'h1   {color: black;}'
          'h2   {color: black;}'
          'h3   {color: black;}'
          'p    {color: black; font-size :18px; line-height:30px}'
          'a    {color:#F44336; text-decoration: none;}'
          'img  {max-width: 100%; width:auto; height: auto;}'
          'iframe {width:\"640\"; height:\"480\";}'
          '</style>';
    } else {
      backgroudColor = Colors.black;
      fontColor = Colors.white;
      colorCSS = '<style>'
          'body {background-color: black; margin: 0; padding: 20;}'
          'h1   {color: white;}'
          'h2   {color: white;}'
          'h3   {color: white;}'
          'p    {color: white; font-size :18px; line-height:30px}'
          'a    {color:#F44336; text-decoration: none;}'
          'img  {max-width: 100%; width:auto; height: auto;}'
          'iframe {width:\"640\"; height:\"480\";}'
          '</style>';
    }
    if (entry.loadChoice == 1 && entry.form == 1) {
      return BlocBuilder(
        bloc: articleBloc,
        builder: (BuildContext context, ArticleState state) {
          return Scaffold(
            appBar: articleAppBar(),
            body: SingleChildScrollView(
              key: PageStorageKey(entry.id),
              child: Center(
                child: state is ArticleLoaded ? HtmlWidget(
                  header + state.content,
                  webView: true,
                  webViewJs: true,
                  hyperlinkColor: Colors.blue,
                  textPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
//                  bodyPadding: EdgeInsets.all(15.0),
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                    height: 1.3,
                  ),
                )
                    : Container(padding: EdgeInsets.all(15), child: CircularProgressIndicator()),
              ),
            ),
          );

        },
      );
    } else {
      return WebviewScaffold(
        appBar: articleAppBar(),
        url: entry.link,
        hidden: true,
      );
    }
  }


  Widget articleAppBar() {
    if (_type == 1) {
      return AppBar(
        actions: <Widget>[
          BlocBuilder(
            bloc: BlocProvider.of<EntryBloc>(context),
            builder: (BuildContext context, EntryState state) {
              if (state is EntryLoaded)
                return IconButton(
                  icon: state.entries[_index].isStarring ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (!state.entries[_index].isStarring) {
                      BlocProvider.of<EntryBloc>(context).dispatch(StarEntry(entryId: state.entries[_index].id));
                    } else {
                      BlocProvider.of<EntryBloc>(context).dispatch(UnstarEntry(entryId: state.entries[_index].id));
                    }
                  },
                );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(entry.title + '\n' + entry.link);
            },
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _launchURL(entry.link);
            },
          )
        ],
      );
    } else if (_type == 2) {
      return AppBar(
        actions: <Widget>[
          BlocBuilder(
            bloc: BlocProvider.of<SourceEntryBloc>(context),
            builder: (BuildContext context, SourceEntryState state) {
              if (state is SourceEntryLoaded)
                return IconButton(
                  icon: state.entries[_index].isStarring ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (!state.entries[_index].isStarring) {
                      BlocProvider.of<SourceEntryBloc>(context).dispatch(StarSourceEntry(entryId: state.entries[_index].id));
                    } else {
                      BlocProvider.of<SourceEntryBloc>(context).dispatch(UnstarSourceEntry(entryId: state.entries[_index].id));
                    }
                  },
                );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(entry.title + '\n' + entry.link);
            },
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _launchURL(entry.link);
            },
          )
        ],
      );
    } else if (_type == 3) {
      return AppBar(
        actions: <Widget>[
          BlocBuilder(
            bloc: BlocProvider.of<BookmarkEntryBloc>(context),
            builder: (BuildContext context, BookmarkEntryState state) {
              if (state is BookmarkEntryLoaded)
                return IconButton(
                  icon: state.entries[_index].isStarring ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
                  onPressed: () {
                    if (!state.entries[_index].isStarring) {
                      BlocProvider.of<BookmarkEntryBloc>(context).dispatch(StarBookmarkEntry(entryId: state.entries[_index].id));
                    } else {
                      BlocProvider.of<BookmarkEntryBloc>(context).dispatch(UnstarBookmarkEntry(entryId: state.entries[_index].id));
                    }
                  },
                );
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              Share.share(entry.title + '\n' + entry.link);
            },
          ),
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _launchURL(entry.link);
            },
          )
        ],
      );
    }

  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static String _timestamp(String timeUtcStr) {
    DateTime oldDate = DateTime.parse(timeUtcStr);
    String timestamp;
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(oldDate);
    if (difference.inSeconds < 60) {
      timestamp = 'Now';
    } else if (difference.inMinutes < 60) {
      timestamp = '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      timestamp = '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      timestamp = '${difference.inDays}d';
    }
    return timestamp;
  }

}
