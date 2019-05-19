import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:preferences/preferences.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:flutter/services.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('设置'), elevation: 2,),
      body: PreferencePage([
        PreferenceTitle('账户'),
        ListTile(
          title: Text('修改密码'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ResetPasswordPage()));
          },
        ),
        ListTile(
          title: Text('退出登录'),
          onTap: () {
            authenticationBloc.dispatch(LoggedOut());
            Navigator.of(context).pop();
          },
        ),
        PreferenceTitle('缓存'),
        ListTile(
          title: Text('清除图片缓存'),
          subtitle: Text( '当前缓存 '+ ((imageCache.currentSizeBytes)/(1024*1024)).toStringAsFixed(2) + ' MB'),
          onTap: () {
            imageCache.clear();
          },
        ),
        PreferenceTitle('更多'),
        ListTile(
          title: Text('帮助'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WebViewPageFull('http://help.infomatter.cn')));
          },
        ),
        ListTile(
          title: Text('反馈'),
          subtitle: Text('请发送邮件至support@infomatter.cn'),
        ),
        ListTile(
          title: Text('关于'),
          subtitle: Text('当前版本 1.0.0'),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => WebViewPageFull('http://about.infomatter.cn')));
          },
        )
      ]),
    );
  }


}