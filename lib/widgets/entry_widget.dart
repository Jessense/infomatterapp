import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';



class EntryWidget extends StatefulWidget{
  final Entry entry;
  final int index;
  final int type;
  EntryWidget({Key key, @required this.entry, this.index, this.type}):
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
  int get _index => widget.index;
  int get _type => widget.type;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _entry.sourcePhoto != null ? Image.network(_entry.sourcePhoto, width: 20, height: 20) : Container(width: 20, height: 20,),
                ),
                Expanded(
                  flex: 8,
                  child: Text(
                    _entry.sourceName,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _entry.isReaded ? Colors.grey : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white
                    ),
                  ),
                ),
                Expanded(
                  child: Text(_timestamp(_entry.pubDate), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.grey),),
                )
              ],
            ),
            SizedBox(height: 8,),
            GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    BlocProvider.of<EntryBloc>(context).entriesRepository.click(_index);
                    return ArticlePage(entry: _entry, index: _index, type: _type,);
                  },
                )
                );
              },
              child: _entry.form == 2 ? WeiboEntry(content: _entry.digest, photo: _entry.photo, isReaded: _entry.isReaded,)
                  : ArticleEntry(entry: _entry,),
            ),
            _entry.videoFrame.length > 0 ? VideoFrameWidget(videoUrl: _entry.videoFrame, ) : Container(),
            SizedBox(height: 10,),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Container(),
                ),
                Expanded(
                  child: _entry.sim_count != null && _entry.sim_count > 1 && _type != 4 ? IconButton(icon: Icon(Icons.unfold_more), onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => FullCoveragePage(cluster: _entry.cluster)));
                  }) : Container(),
                ),
                Expanded(
                  child: _buildFavbtn(),
                ),
                Expanded(
                  child: IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        showModalBottomSheet(context: context, builder: (BuildContext context) => EntryOption(entry: _entry, index: _index,));
                      }
                  ),
                )
              ],
            ),
            Divider(height: 5, )
          ],
        )
    );
  }

  Widget _buildFavbtn() {
    return IconButton(
      icon: _entry.isStarring == true ? Icon(Icons.bookmark, color: Theme.of(context).accentColor,) : Icon(Icons.bookmark_border),
      onPressed: () {
        EntryBloc entryBloc;
        if (_type == 1) {
          entryBloc = BlocProvider.of<EntryBloc>(context);
        } else if (_type == 2) {
          entryBloc = BlocProvider.of<SourceEntryBloc>(context).entryBloc;
        } else if (_type == 3) {
          entryBloc = BlocProvider.of<BookmarkEntryBloc>(context).entryBloc;
        } else if (_type == 4) {
          entryBloc = BlocProvider.of<FullCoverageBloc>(context).entryBloc;
        } else if (_type == 5) {
          entryBloc = BlocProvider.of<SearchBloc>(context).entryBloc;
        }
        if (_entry.isStarring == true) {
          entryBloc.dispatch(UnstarEntry(entryId: _entry.id));
        } else {
          entryBloc.dispatch(StarEntry(entryId: _entry.id, from: 0));
        }
      },
    );
  }

//  void openWebView(BuildContext context, String url, String sourceName, int id) {
//    Navigator.push(context,
//        MaterialPageRoute(builder: (context) => WebviewScaffold(
//          hidden: true,
//          url: url,
//          appBar: AppBar(
//            title: Text(sourceName),
//            actions: <Widget>[
//              IconButton(
//                icon: Icon(Icons.bookmark_border),
//              ),
//            ],
//          ),
//        )));
//  }

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
    } else {
      timestamp = '${difference.inDays}d';
    }
    return timestamp;
  }

}



class ArticleEntry extends StatelessWidget{
  final Entry entry;
  ArticleEntry({Key key, this.entry}):
      super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(entry.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: entry.isReaded ? Colors.grey : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white), maxLines: 2,),
                SizedBox(height: 5,),
                Text(entry.digest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey), maxLines: 2,),
              ],
            ),
          ),
          SizedBox(width: 5,),
          entry.audio.length > 0 ? BlocBuilder(
            bloc: BlocProvider.of<AudioBloc>(context),
            builder: (BuildContext context, AudioState state) {
              if (state is AudioPlaying && state.entry.id == entry.id) {
                return Container(
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(Icons.pause_circle_filled) ,
                    onPressed: () {
                      BlocProvider.of<AudioBloc>(context).dispatch(PauseAudio());
                    },
                  ),
                );
              }
              return Container(
                width: 80,
                height: 80,
                child: IconButton(
                  icon: Icon(Icons.play_circle_filled) ,
                  onPressed: () {
                    BlocProvider.of<AudioBloc>(context).dispatch(PlayAudio(entry: entry));
                  },
                ),
              );

            },
          ) : Container(),
          (entry.photo.length > 0 && entry.photo[0].length > 0 && entry.audio.length == 0) ? ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Image.network(entry.photo[0], height: 80, width: 80, fit: BoxFit.cover,),
            ) : Container(),

        ],
      ),
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400), maxLines: 3,),
//          SizedBox(height: 7,),
//          (photo.length > 0 && photo[0].length > 0)? Row(
//            children: <Widget>[
//              Expanded(
//                flex: 3,
//                child: Text(digest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey), maxLines: 3,),
//              ),
//              SizedBox(width: 10,),
//              Expanded(
//                  child: ClipRRect(
//                    borderRadius: BorderRadius.circular(5.0),
//                    child: Image.network(photo[0], height: 50, width: 50, fit: BoxFit.cover,),
//                  )
//              ),
//            ],
//          ) : Text(digest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.grey), maxLines: 3,),
//        ],
//      ),
    );
  }
}


class VideoWidget extends StatefulWidget{
  final String videoUrl;
  VideoWidget({Key key, @required this.videoUrl}):
      super(key: key);
  @override
  State<VideoWidget> createState() {
    // TODO: implement createState
    return VideoWidgetState();
  }
}

class VideoWidgetState extends State<VideoWidget>{
  String get _videoUrl => widget.videoUrl;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Chewie(
      controller: ChewieController(
        videoPlayerController: VideoPlayerController.network(_videoUrl),
        aspectRatio: 3 / 2,
        autoPlay: false,
        looping: false,
      )
    );
  }
}

class VideoFrameWidget extends StatefulWidget{
  final String videoUrl;
  VideoFrameWidget({Key key, @required this.videoUrl}):
        super(key: key);
  @override
  State<VideoFrameWidget> createState() {
    // TODO: implement createState
    return VideoFrameWidgetState();
  }
}

class VideoFrameWidgetState extends State<VideoFrameWidget>{
  String get _videoUrl => widget.videoUrl;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return HtmlWidget(
      """
      <iframe width="1080" height="607" src=$_videoUrl scrolling="no" border="0"
        frameborder="no" framespacing="0" allowfullscreen="true"> </iframe>
      """,
      webView: true,
      webViewJs: true,
    );
  }
}

class WeiboEntry extends StatelessWidget{
  final String content;
  final List<String> photo;
  final bool isReaded;
  WeiboEntry({Key key, this.content, this.photo, this.isReaded}):
      super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: isReaded ? Colors.grey : Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white), maxLines: 7),
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
        child: Image.network(photo[index], width: width, height: height, fit: BoxFit.cover,),
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




