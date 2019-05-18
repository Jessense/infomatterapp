import 'package:flutter/material.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/widgets/widgets.dart';
class ResetPasswordPage extends StatefulWidget{
  @override
  State<ResetPasswordPage> createState() {
    // TODO: implement createState
    return ResetPasswordState();
  }
}

class ResetPasswordState extends State<ResetPasswordPage> with SingleTickerProviderStateMixin{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _codeFocus = FocusNode();

  AnimationController _controller;
  Animation _animation;

  LoginBloc get _loginBloc => BlocProvider.of<LoginBloc>(context);


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
    // TODO: implement build
    return Scaffold(
      body: BlocBuilder<LoginEvent, LoginState>(
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
              Navigator.of(context).pop();
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
                    LoginFormCode(countdown: 30, onTapCallback: () {
                      if (state is !LoginLoading) {
                        _onResetPasswordVerify();
                      }
                    }, available: true,)
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      onPressed: () {
                        if (state is !LoginLoading) {
                          _onResetPassword();
                        }
                      },
                      child: Text('重置密码', style: TextStyle(color: Colors.white, fontSize: 17),),
                    )
                ),

                Container(
                  child:
                  state is LoginLoading ? Center(child: CircularProgressIndicator(),) : null,
                ),
              ],
            ),
          );
        },
      ),
    );

  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
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

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

}