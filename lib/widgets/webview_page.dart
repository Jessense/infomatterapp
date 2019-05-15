import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewPage extends StatefulWidget {
  final url;
  WebViewPage(this.url);
  @override
  createState() => _WebViewPageState(this.url);
}
class _WebViewPageState extends State<WebViewPage> {
  var _url;
  final _key = UniqueKey();
  _WebViewPageState(this._url);
  @override
  Widget build(BuildContext context) {
    return WebView(
        key: _key,
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: _url);
  }
}