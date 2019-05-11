import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:convert';


class ListTestPage extends StatefulWidget{
  @override
  State<ListTestPage> createState() {
    // TODO: implement createState
    return ListTestPageState();
  }
}

class ListTestPageState extends State<ListTestPage>{
  List<String> imgs;
  
  @override
  void initState() {
    // TODO: implement initState
    final data = json.decode('["https://wx2.sinaimg.cn/large/7e948b4dly1g2g2248j8aj20k00qotaf.jpg","https://wx2.sinaimg.cn/large/7e948b4dly1g2g2248iykj20k00qoabt.jpg"]') as List;
    for (int i = 0; i < data.length; i ++ ) {
      print(data[i]);
    }
    imgs = data.map((img){
      return img.toString();
    }).toList();
    for (int i = 0; i < imgs.length; i ++ ) {
      print(imgs[i]);
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("test"),),
      body: Center(
        child: ListView(
          children: <Widget>[
            Text("Bilibili"),
            SizedBox(height: 20,),
            VideoWidget(videoUrl: "http://player.bilibili.com/player.html?aid=50040443&cid=87599414&page=1"),
            SizedBox(height: 20,),
            Text("优酷"),
            SizedBox(height: 20,),
            VideoWidget(videoUrl: "http://player.youku.com/embed/XNDAyMzY0MTU4OA=="),
            SizedBox(height: 20,),
            Text("爱奇艺"),
            VideoWidget(videoUrl: "http://open.iqiyi.com/developer/player_js/coopPlayerIndex.html?vid=7e11abb5ce044a30797fc453710a851f&tvId=2063768000&accessToken=2.f22860a2479ad60d8da7697274de9346&appKey=3955c3425820435e86d0f4cdfe56f5e7&appId=1368&height=100%&width=100%"),
            SizedBox(height: 20,),
            HtmlWidget(
              """
              <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width=330 height=86 src="http://music.163.com/outchain/player?type=2&id=268154&auto=1&height=66">
              </iframe>
              """,
              webViewJs: true,
              webView: true,
            ),
            HtmlWidget(
              """
              <div style='font-size:20px;'>I am good</div>
              """,
              webView: true,
            )
          ],
        ),
      ),
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
    return HtmlWidget(
      """
      <iframe width="640" height="480" src=$_videoUrl scrolling="no" border="0"
        frameborder="no" framespacing="0" allowfullscreen="true"> </iframe>
      """,
      webView: true,
      webViewJs: true,
    );
  }
}