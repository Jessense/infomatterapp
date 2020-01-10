import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/entry.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:shimmer/shimmer.dart';
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
  final _key = UniqueKey();

  bool readabilityOn = false;
  ArticleBloc articleBloc;

  EntryBloc get entryBloc => BlocProvider.of<EntryBloc>(context);
  Entry get entry => widget.entry;
  int get _index => widget.index;
  int get _type => widget.type;

  String currentUrl = '';

  String header = '';
  String colorCSS = '';
  String styleCSS = '<style>'
      'body {margin: 0; padding: 15; line-height: 25px;}'
      'a    {color:#2196F3; text-decoration: none;}'
      'iframe {width:\"640\"; height:\"480\";}'
      'img  {max-width: 100%; width:auto; height: auto;}'
      'blockquote {background: #f9f9f9;border-left: 10px solid #ccc;margin: 1.5em 10px;padding: 0.5em 10px;}'
      'blockquote:before {color: #ccc;content: open-quote;font-size: 4em;line-height: 0.1em;margin-right: 0.25em;vertical-align: -0.4em;}'
      'blockquote p {display: inline;}'
      '</style>';

  @override
  void initState() {
    // TODO: implement initState
//    if ((entry.form == 1) || readabilityOn) {
//      articleBloc = ArticleBloc(
//        entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
//      );
//      if (entry.form == 1)
//        articleBloc.dispatch(FetchArticle(entryId: entry.id));
//      header = "<p style=\'font-size:22px;font-weight:500;\'>" +  entry.title + "</p>" + "<p style=\"font-size:16px;color:grey;\">" + entry.sourceName + " / " + _timestamp(entry.pubDate) + "</p>";
//
//    }
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: articleAppBar(),
      body: WebViewPage(entry.link),
    );

//    if (entry.form == 1 || readabilityOn) {
//
//      return BlocBuilder(
//        bloc: articleBloc,
//        builder: (BuildContext context, ArticleState state) {
//          return Scaffold(
//            appBar: articleAppBar(),
//            body: state is ArticleLoaded ? SingleChildScrollView(
//              child: HtmlWidget(
//                header + "<div style=\"font-size:16px; text-decoration:none;\">" +  state.content + "</div>",
//                webViewJs: true,
//                webView: true,
//                hyperlinkColor: Colors.blue,
//                textPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
////                  bodyPadding: EdgeInsets.all(15.0),
//                textStyle: TextStyle(
//                  fontSize: 16.0,
//                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
//                  height: 1.3,
//                ),
//                onTapUrl: (url) {
//                  currentUrl = url;
//                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
//                    return Scaffold(
//                      appBar: articleAppBar(),
//                      body: WebViewPage(url),
//                    );
//                  }));
//                },
//              ),
//            ) : Container(
//              color: Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black,
//              padding: EdgeInsets.all(20),
//              child: Shimmer.fromColors(
//                baseColor: Colors.grey[300],
//                highlightColor: Colors.white,
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: [
//                    Container(
//                      width: double.infinity,
//                      height: 16.0,
//                      color: Colors.white,
//                    ),
//                    Padding(
//                      padding:
//                      const EdgeInsets.symmetric(vertical: 6.0),
//                    ),
//                    Container(
//                      width: double.infinity,
//                      height: 16.0,
//                      color: Colors.white,
//                    ),
//                    Padding(
//                      padding:
//                      const EdgeInsets.symmetric(vertical: 6.0),
//                    ),
//                    Container(
//                      width: double.infinity,
//                      height: 16.0,
//                      color: Colors.white,
//                    ),
//                    Padding(
//                      padding:
//                      const EdgeInsets.symmetric(vertical: 6.0),
//                    ),
//                    Container(
//                      width: double.infinity,
//                      height: 16.0,
//                      color: Colors.white,
//                    ),
//                    Padding(
//                      padding:
//                      const EdgeInsets.symmetric(vertical: 6.0),
//                    ),
//                    Container(
//                      width: 60.0,
//                      height: 16.0,
//                      color: Colors.white,
//                    ),
//                  ],
//                ),
//
//              ),
//            ),
//          );
//        },
//      );
//    } else {
//      return Scaffold(
//        appBar: articleAppBar(),
//        body: WebViewPage(entry.link),
//      );
//    }
  }


  Widget articleAppBar() {
    EntryBloc entryBloc;
    if (_type == 1) {
      entryBloc = BlocProvider.of<EntryBloc>(context);
    } else if (_type == 2) {
      entryBloc = BlocProvider.of<SourceEntryBloc>(context).entryBloc;
    } else if (_type == 3){
      entryBloc = BlocProvider.of<BookmarkEntryBloc>(context).entryBloc;
    } else if (_type == 4) {
      entryBloc = BlocProvider.of<FullCoverageBloc>(context).entryBloc;
    } else if (_type == 5) {
      entryBloc = BlocProvider.of<SearchBloc>(context).entryBloc;
    }

    return AppBar(
      elevation: 0,
      actions: <Widget>[
        IconButton(
          icon: readabilityOn ? Icon(Icons.chrome_reader_mode, color: Theme.of(context).accentColor,) : Icon(Icons.chrome_reader_mode),
          onPressed: () {
            if (entry.form != 1) {
              articleBloc = ArticleBloc(
                entriesRepository: EntriesRepository(entriesApiClient: EntriesApiClient(httpClient: http.Client())),
              );
              articleBloc.dispatch(FetchArticle(entryId: entry.id));
              header = "<p style=\'font-size:22px;font-weight:500;\'>" +  entry.title + "</p>" + "<p style=\"font-size:16px;color:grey;\">" + entry.sourceName + " / " + _timestamp(entry.pubDate) + "</p>";
            }
            if (!readabilityOn) {
              setState(() {
                readabilityOn = true;
                articleBloc.dispatch(FetchReadability(link: entry.link));
              });
            } else {
              setState(() {
                readabilityOn = false;
                if (entry.form == 1) {
                  articleBloc.dispatch(FetchArticle(entryId: entry.id));
                }
              });
            }

          },
        ),
        BlocBuilder(
          bloc: entryBloc,
          builder: (BuildContext context, EntryState state) {
            if (entryBloc.entriesRepository.showStarred2 == true) {
              entryBloc.entriesRepository.showStarred2 = false;
              _onWidgetDidBuild(() {
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('已收藏'),
                  duration: Duration(milliseconds: 1000),
                  action: SnackBarAction(
                    label: '添加到收藏夹',
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AddBookmarkDialog(entryId: entryBloc.entriesRepository.lastStarId);
                          }
                      );
                    },
                  ),
                ));
              });
            }

            if (state is EntryLoaded)
              return IconButton(
                icon: state.entries[_index].isStarring ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
                onPressed: () {
                  if (!state.entries[_index].isStarring) {
                    entryBloc.dispatch(StarEntry(entryId: state.entries[_index].id, from: 1));
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
            _launchURL(context, entry.link);
          },
        )
      ],
    );
    return AppBar(elevation: 0,);

  }

  _launchURL(BuildContext context, String url) async {
    try {
      await launch(
        url,
        option: new CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: CustomTabsAnimation(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
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

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

}
