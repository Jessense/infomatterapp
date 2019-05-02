import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infomatterapp/blocs/article_bloc.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/blocs/entry_bloc.dart';
import 'package:infomatterapp/models/entry.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_html/flutter_html.dart';

class ArticlePage extends StatefulWidget{
  final int index;
  final Entry entry;//1: full-text rss - from server;
  ArticlePage({Key key, this.entry, this.index}):
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


  String header;
  String colorCSS;

  @override
  void initState() {
    // TODO: implement initState
  if (entry.loadChoice == 1) {
    articleBloc = ArticleBloc(
      entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
    );
    articleBloc.dispatch(FetchArticle(entryId: entry.id));
    header = "<h2>" + "<a href=\"" + entry.link + "\">" + entry.title + "</a>" + "</h2>" + "<i>" + entry.sourceName + " / " + _timestamp(entry.pubDate) + "</i><p>";

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
          'p    {color: black; font-size :16px; line-height:30px}'
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
          'p    {color: white; font-size :16px; line-height:30px}'
          'a    {color:#F44336; text-decoration: none;}'
          'img  {max-width: 100%; width:auto; height: auto;}'
          'iframe {width:\"640\"; height:\"480\";}'
          '</style>';
    }
    if (entry.loadChoice == 1) {
      return BlocBuilder(
        bloc: articleBloc,
        builder: (BuildContext context, ArticleState state) {
          return Scaffold(
            appBar: articleAppBar(),
            body: SingleChildScrollView(
              child: Center(
                child: state is ArticleLoaded ? Html(
                  data: header + state.content + colorCSS,
                  padding: EdgeInsets.all(15.0),
                  backgroundColor: backgroudColor,
                  defaultTextStyle: TextStyle(fontSize: 16, color: fontColor, height: 1.3),
                  linkStyle: const TextStyle(
                    color: Colors.redAccent,
                  ),
                  onLinkTap: (url) {
                    _launchURL(url);
                    // open url in a webview
                  },)
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
    return AppBar(
      actions: <Widget>[
        BlocBuilder(
          bloc: entryBloc,
          builder: (BuildContext context, EntryState state) {
            if (state is EntryLoaded)
            return IconButton(
              icon: state.entries[_index].isStarring ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
              onPressed: () {
                if (!state.entries[_index].isStarring) {
                  entryBloc.dispatch(StarEntry(entryId: state.entries[_index].id));
                } else {
                  entryBloc.dispatch(UnstarEntry(entryId: state.entries[_index].id));
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
