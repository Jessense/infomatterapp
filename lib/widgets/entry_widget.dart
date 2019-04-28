import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibration/vibration.dart';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class EntryWidget extends StatefulWidget{
  final Entry entry;
  EntryWidget({Key key, @required this.entry}):
      assert(entry != null),
      super(key: key);
      
  @override
  State<EntryWidget> createState() {
    // TODO: implement createState
    return EntryWidgetState();
  }
}

class EntryWidgetState extends State<EntryWidget> {

  Entry get _entry => widget.entry;
  EntryStarBloc get _entryStarBloc => BlocProvider.of<EntryStarBloc>(context);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: _entryStarBloc,
      child: GestureDetector(
          onTap: (){
            openWebView(context, _entry.link);
          },
          onLongPress: () {
            Vibration.vibrate(duration: 20);
            showModalBottomSheet(context: context, builder: (BuildContext context){
              return BlocBuilder(
                bloc: _entryStarBloc,
                builder: (BuildContext context, EntryStarState state){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new ListTile(
                        leading: (state is EntryStarring) ? Icon(Icons.bookmark): Icon(Icons.bookmark_border),
                        title: (state is EntryStarring)? Text('Bookmarked') : Text("Bookmark"),
                        onTap: () {
                          if (state is EntryNotStarring) {
                            _entryStarBloc.dispatch(StarEntry(entryId: _entry.id));
                          }
                          else if (state is EntryStarring) {
                            _entryStarBloc.dispatch(UnstarEntry(entryId: _entry.id));
                          }
                        },
                      ),
                      new ListTile(
                        leading: new Icon(Icons.arrow_forward),
                        title: new Text('Go to ' + _entry.sourceName),
                        onTap: () => {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SourcePage(sourceId: _entry.sourceId, sourceName: _entry.sourceName,)))
                        },
                      ),
                    ],
                  );;
                },
              );
            });
          },
          child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Image.network(_entry.sourcePhoto, width: 20, height: 20,),
                      ),
                      Expanded(
                        flex: 8,
                        child: Text(_entry.sourceName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
                      ),
                      Expanded(
                        child: Text(_timestamp(_entry.pubDate), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),),
                      )
                    ],
                  ),
                  SizedBox(height: 8,),
                  _entry.form == 2 ? WeiboEntry(content: _entry.digest, photo: _entry.photo,)
                      : ArticleEntry(title: _entry.title, digest: _entry.digest, photo: _entry.photo,),
                  SizedBox(height: 10,),
                  Divider()
                ],
              )
          ),
        )
    );
  }

  void openWebView(BuildContext context, String url) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewPage(url)));
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

//class FeedBottomSheet extends StatefulWidget{
//  final Entry entry;
//  FeedBottomSheet({Key key, @required this.entry}):
//      assert(entry != null),
//      super(key: key);
//  @override
//  State<FeedBottomSheet> createState() {
//    // TODO: implement createState
//    return FeedBottomSheetState();
//  }
//}
//
//class FeedBottomSheetState extends State<FeedBottomSheet> {
//  Entry get _entry => widget.entry;
//  EntryStarBloc get _entryStarBloc => BlocProvider.of<EntryStarBloc>(context);
//
//  @override
//  Widget build(BuildContext context) {
//    // TODO: implement build
//    return BlocBuilder(
//      bloc: _entryStarBloc,
//      builder: (BuildContext context, EntryStarState state){
//        return Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            new ListTile(
//              leading: (state is EntryStarring) ? Icon(Icons.bookmark): Icon(Icons.bookmark_border),
//              title: (state is EntryStarring)? Text('Bookmarked') : Text("Bookmark"),
//              onTap: () {
//                if (state is EntryNotStarring) {
//                  _entryStarBloc.dispatch(StarEntry(entryId: _entry.id));
//                }
//                else if (state is EntryStarring) {
//                  _entryStarBloc.dispatch(UnstarEntry(entryId: _entry.id));
//                }
//              },
//            ),
//            new ListTile(
//              leading: new Icon(Icons.arrow_forward),
//              title: new Text('Go to ' + _entry.sourceName),
//              onTap: () => {
//              Navigator.of(context).push(MaterialPageRoute(builder: (context) => SourcePage(sourceId: _entry.sourceId, sourceName: _entry.sourceName,)))
//              },
//            ),
//          ],
//        );;
//      },
//    );
//  }
//}

class ArticleEntry extends StatelessWidget{
  final String title;
  final String digest;
  final List<String> photo;
  ArticleEntry({Key key, this.title, this.digest, this.photo}):
      super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), maxLines: 3,),
          SizedBox(height: 7,),
          (photo.length > 0 && photo[0].length > 0)? Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(digest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey), maxLines: 3,),
              ),
              SizedBox(width: 10,),
              Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: Image.network(photo[0], height: 50, width: 50,),
                  )
              ),
            ],
          ) : Text(digest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey), maxLines: 3,),
        ],
      ),
    );
  }
}

class WeiboEntry extends StatelessWidget{
  final String content;
  final List<String> photo;
  WeiboEntry({Key key, this.content, this.photo}):
      super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), maxLines: 7),
          (photo.length > 0 && photo[0].length > 0) ? SizedBox(height: 10,) : Container(),
          (photo.length > 0 && photo[0].length > 0) ? layoutImages(context) : Container()
        ],
      ),
    );
  }

  Widget layoutImages(BuildContext context) {
    final width1 = MediaQuery.of(context).size.width*2/3;
    final width2 = MediaQuery.of(context).size.width/2 - 20;
    final width3 = MediaQuery.of(context).size.width/3 - 20;
    final height = 100.0;

    Widget imageWrapper(int index, double width) {
      return GestureDetector(
        child: Image.network(photo[index], width: width, height: height,),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => Container(
            child: GestureDetector(
              onTap: () {Navigator.of(context).pop();},
              child: PhotoViewGallery.builder(
                itemCount: photo.length,
                builder: (BuildContext context, int index2) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(photo[index2]),
                    heroTag: index2.toString() + '/' + photo.length.toString(),
                  );
                },
                pageController: PageController(initialPage: index),
              ),
            ),
          )));
        },
      );
    }

    switch(photo.length) {
      case 1:
        return imageWrapper(0, width1);
      case 2:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            imageWrapper(0, width2),
            imageWrapper(1, width2),
          ],
        );
      case 3:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            imageWrapper(0, width3),
            imageWrapper(1, width3),
            imageWrapper(2, width3),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width2),
                imageWrapper(1, width2),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(2, width2),
                imageWrapper(3, width2),
              ],
            )
          ],
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width2),
                imageWrapper(1, width2),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(2, width3),
                imageWrapper(3, width3),
                imageWrapper(4, width3),
              ],
            )
          ],
        );
      case 6:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width3),
                imageWrapper(1, width3),
                imageWrapper(2, width3),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(3, width3),
                imageWrapper(4, width3),
                imageWrapper(5, width3),
              ],
            )
          ],
        );
      case 7:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width2),
                imageWrapper(1, width2),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(2, width2),
                imageWrapper(3, width2),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(4, width3),
                imageWrapper(5, width3),
                imageWrapper(6, width3),
              ],
            )
          ],
        );
      case 8:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width2),
                imageWrapper(1, width2),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(2, width3),
                imageWrapper(3, width3),
                imageWrapper(4, width3),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(5, width3),
                imageWrapper(6, width3),
                imageWrapper(7, width3),
              ],
            )
          ],
        );
      case 9:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                imageWrapper(0, width3),
                imageWrapper(1, width3),
                imageWrapper(2, width3),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(3, width3),
                imageWrapper(4, width3),
                imageWrapper(5, width3),
              ],
            ),
            Row(
              children: <Widget>[
                imageWrapper(6, width3),
                imageWrapper(7, width3),
                imageWrapper(8, width3),
              ],
            )
          ],
        );
      default:
        return Container();
    }


  }

}




