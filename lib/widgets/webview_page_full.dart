import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewPageFull extends StatefulWidget {
  final url;
  WebViewPageFull(this.url);
  @override
  createState() => _WebViewPageFullState(this.url);
}
class _WebViewPageFullState extends State<WebViewPageFull> {
  var _url;
  final _key = UniqueKey();
  _WebViewPageFullState(this._url);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _launchURL(context, _url);
            },
          )
        ],
      ),
      body: WebView(
          key: _key,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: _url),
    );
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
}