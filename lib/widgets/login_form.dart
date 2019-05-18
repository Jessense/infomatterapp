import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/widgets/widgets.dart';

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

class _LoginFormState extends State<LoginForm> with SingleTickerProviderStateMixin{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _codeFocus = FocusNode();

  AnimationController _controller;
  Animation _animation;

  bool isSignup = false;

  int type = 1;

  LoginBloc get _loginBloc => widget.loginBloc;


  @override
  void initState() {
    // TODO: implement initState
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _animation = Tween(begin: 200.0, end: 50.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _emailFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    _codeFocus.addListener(() {
      if (_codeFocus.hasFocus) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginEvent, LoginState>(
      bloc: _loginBloc,
      builder: (
          BuildContext context,
          LoginState state,
          ) {
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
          child: ListView(
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: [
              SizedBox(height: _animation.value,),
              Text(type == 1 ? "登录" : "注册",  style: TextStyle(
                fontSize: 20.0,)),
              SizedBox(height: 20,),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'email',
                ),
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                onFieldSubmitted: (term) {
                  _fieldFocusChange(context, _emailFocus, _passwordFocus);
                },
              ),
              SizedBox(height: 15,),
              TextFormField(
                decoration: InputDecoration(
                  labelText: '密码',
                ),
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                focusNode: _passwordFocus,
                onFieldSubmitted: (term) => state is! LoginLoading ? _onSignupButtonPressed : null,
              ),
              SizedBox(height: 20,),

              Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                    ),
                    onPressed: () {
                      if (state is !LoginLoading) {
                        if (type == 1) {
                          _onLoginButtonPressed();
                        } else {
                          _onSignupButtonPressed();
                        }
                      }
                    },
                    child: Text(type == 1 ? '登录' : "注册", style: TextStyle(color: Colors.white, fontSize: 17),),
                  )
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      child: Text(type == 1 ? "创建账号" : "已有账号登录", style: TextStyle(color: Theme.of(context).accentColor),),
                      onPressed: () {
                        setState(() {
                          if (type == 1)
                            type = 2;
                          else
                            type = 1;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: type == 1 ? FlatButton(
                      child: Text("忘记密码", style: TextStyle(color: Theme.of(context).accentColor)),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ResetPasswordPage()));
                      },
                    ) : Container(),
                  )
                ],
              ),

              Container(
                child:
                state is LoginLoading ?  Center(child: CircularProgressIndicator(),) : null,
              ),
            ],
          ),
        );
      },
    );

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
      password: _passwordController.text,
    ));
  }

  _onResetPasswordVerify() {
    _loginBloc.dispatch(ResetPasswordVerify(email: _usernameController.text));
  }

  _onResetPassword() {
    _loginBloc.dispatch(ResetPassword(
        username: _usernameController.text,
        code: _codeController.text,
        password: _passwordController.text
    ));
  }

  _onCodeRequested() {
    _loginBloc.dispatch(CodeRequested(email: _usernameController.text));
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
