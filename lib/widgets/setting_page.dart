import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';

class SettingPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('设置'),),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Logout'),
            onTap: () {
              authenticationBloc.dispatch(LoggedOut());
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}