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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (type == 2) {
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
                Text("注册",  style: TextStyle(
                  fontSize: 20.0,)),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'email'),
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _emailFocus, _codeFocus);
                  },
                ),
                SizedBox(height: 15,),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: "邮箱验证码"),
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        focusNode: _codeFocus,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _codeFocus, _passwordFocus);
                        },
                      ),
                    ),
                    SizedBox(width: 15,),
                    RaisedButton(
                      color: Colors.black,
                      child: Text("验证码", style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        _onCodeRequested();
                      },
                    )
                  ],
                ),
                SizedBox(height: 15,),
                TextFormField(
                  decoration: InputDecoration(labelText: '密码'),
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
                      color: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      onPressed:
                      state is! LoginLoading ? _onSignupButtonPressed : null,
                      child: Text('创建账号', style: TextStyle(color: Colors.white, fontSize: 17),),
                    )
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        child: Text("已有账号登录"),
                        onPressed: () {
                          setState(() {
                            type = 1;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    )
                  ],
                ),

                Container(
                  child:
                  state is LoginLoading ? CircularProgressIndicator() : null,
                ),
              ],
            ),
          );

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
    } else if (type == 3) {
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
              if (state.message == 'password reset') {
                setState(() {
                  type = 1;
                });
              }
            }

            return Container(
              child: ListView(
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                children: [
                  SizedBox(height: _animation.value,),
                  Text("重置密码",  style: TextStyle(
                    fontSize: 20.0,)),
                  SizedBox(height: 20,),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'email'),
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    focusNode: _emailFocus,
                    onFieldSubmitted: (term) {
                      _fieldFocusChange(context, _emailFocus, _codeFocus);
                    },
                  ),
                  SizedBox(height: 15,),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          decoration: InputDecoration(labelText: "邮箱验证码"),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          focusNode: _codeFocus,
                          onFieldSubmitted: (term) {
                            _fieldFocusChange(context, _codeFocus, _passwordFocus);
                          },
                        ),
                      ),
                      SizedBox(width: 15,),
                      RaisedButton(
                        color: Colors.black,
                        child: Text("验证码", style: TextStyle(color: Colors.white),),
                        onPressed: () {
                          _onResetPasswordVerify();
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 15,),
                  TextFormField(
                    decoration: InputDecoration(labelText: '新密码'),
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    focusNode: _passwordFocus,
                    onFieldSubmitted: (term) => state is! LoginLoading ? _onResetPassword() : null,
                  ),
                  SizedBox(height: 20,),

                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: RaisedButton(
                        color: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        onPressed:
                        state is! LoginLoading ? _onResetPassword() : null,
                        child: Text('重置密码', style: TextStyle(color: Colors.white, fontSize: 17),),
                      )
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          child: Text("已有账号登录"),
                          onPressed: () {
                            setState(() {
                              type = 1;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      )
                    ],
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
    } else if (type == 1){
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
            padding: EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
            child: ListView(
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: [
                SizedBox(height: _animation.value,),
                Text("登录",  style: TextStyle(
                  fontSize: 20.0,)),
                SizedBox(height: 20,),
                TextFormField(
                  decoration: InputDecoration(labelText: 'email'),
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  focusNode: _emailFocus,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _emailFocus, _passwordFocus);
                  },
                ),
                SizedBox(height: 15,),
                TextFormField(
                  decoration: InputDecoration(labelText: '密码'),
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  focusNode: _passwordFocus,
                  onFieldSubmitted: (term) => state is! LoginLoading ? _onLoginButtonPressed : null,
                ),
                SizedBox(height: 20,),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: RaisedButton(
                    color: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                    ),
                    onPressed:
                    state is! LoginLoading ? _onLoginButtonPressed : null,
                    child: Text('登录', style: TextStyle(color: Colors.white, fontSize: 17),),
                  )
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FlatButton(
                        child: Text("创建账号"),
                        onPressed: () {
                          setState(() {
                            type = 2;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(),
//                      child: FlatButton(
//                        child: Text("忘记密码"),
//                        onPressed: () {
//                          setState(() {
//                            type = 3;
//                          });
//                        },
//                      ),
                    )
                  ],
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
