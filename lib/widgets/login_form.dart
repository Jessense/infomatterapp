import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/blocs.dart';

class LoginForm extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  LoginForm({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  bool isSignup = false;

  LoginBloc get _loginBloc => widget.loginBloc;

  @override
  Widget build(BuildContext context) {
    if (isSignup) {
      return BlocBuilder<LoginEvent, LoginState>(
        bloc: _loginBloc,
        builder: (
            BuildContext context,
            LoginState state,
            ) {
          if (state is LoginFailure) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          if (state is MessageArrived) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.message}'),
                  backgroundColor: state.isGood ? Colors.green : Colors.red
                ),
              );
            });
          }

          return Container(
            padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                Text("Signup",  style: TextStyle(
                  fontSize: 20.0,)),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'email'),
                  controller: _usernameController,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "vertification code"),
                        controller: _codeController,
                      ),
                    ),
                    SizedBox(width: 20,),
                    RaisedButton(
                      child: Text("Get code"),
                      onPressed: () {
                        _onCodeRequested();
                      },
                    )
                  ],
                ),

                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 20,),
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed:
                  state is! LoginLoading ? _onSignupButtonPressed : null,
                  child: Text('Signup'),
                ),
                InkWell(
                  child: Text("login"),
                  onTap: () {
                    setState(() {
                      isSignup = false;
                    });
                  },
                ),
                Container(
                  child:
                  state is LoginLoading ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          );
        },
      );
    } else {
      return BlocBuilder<LoginEvent, LoginState>(
        bloc: _loginBloc,
        builder: (
            BuildContext context,
            LoginState state,
            ) {
          if (state is LoginFailure) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.error}'),
                  backgroundColor: Colors.red,
                ),
              );
            });
          }

          if (state is MessageArrived) {
            _onWidgetDidBuild(() {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                    content: Text('${state.message}'),
                    backgroundColor: state.isGood ? Colors.green : Colors.red
                ),
              );
            });
          }

          return Container(
            padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
            child: Column(
              children: [
                Text("Login",  style: TextStyle(
                  fontSize: 20.0,)),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'email'),
                  controller: _usernameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'password'),
                  controller: _passwordController,
                  obscureText: true,
                ),
                SizedBox(height: 20,),
                RaisedButton(
                  color: Theme.of(context).accentColor,
                  onPressed:
                  state is! LoginLoading ? _onLoginButtonPressed : null,
                  child: Text('Login'),
                ),
                InkWell(
                  child: Text("create an account"),
                  onTap: () {
                    setState(() {
                      isSignup = true;
                    });
                  },
                ),
                Container(
                  child:
                  state is LoginLoading ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          );
        },
      );
    }

  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    _loginBloc.dispatch(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  _onSignupButtonPressed() {
    _loginBloc.dispatch(SignupButtonPressed(
      username: _usernameController.text,
      code: _codeController.text,
      password: _passwordController.text,
    ));
  }

  _onCodeRequested() {
    _loginBloc.dispatch(CodeRequested(email: _usernameController.text));
  }
}
