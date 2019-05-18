import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';


abstract class LoginState extends Equatable {
  LoginState([List props = const []]) : super(props);
}

class LoginInitial extends LoginState {
  @override
  String toString() => 'LoginInitial';
}

class LoginLoading extends LoginState {
  @override
  String toString() => 'LoginLoading';
}



class MessageArrived extends LoginState {
  final bool isGood;
  final String message;

  MessageArrived({@required this.isGood, this.message}) : super([isGood, message]);

  @override
  String toString() => 'LoginFailure { error: $isGood }';
}


abstract class LoginEvent extends Equatable {
  LoginEvent([List props = const []]) : super(props);
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;

  LoginButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

class SignupButtonPressed extends LoginEvent {
  final String username;
  final String password;

  SignupButtonPressed({
    @required this.username,
    @required this.password,
  }) : super([username, password]);

  @override
  String toString() =>
      'LoginButtonPressed { username: $username, password: $password }';
}

class CodeRequested extends LoginEvent {
  final String email;
  CodeRequested({
    @required this.email
  }) : super([email]);

  @override
  String toString() =>
      'LoginButtonPressed { username: $email}';

}

class ResetPasswordVerify extends LoginEvent {
  final String email;
  ResetPasswordVerify({
    @required this.email
  }) : super([email]);

  @override
  String toString() =>
      'ResetPasswordVerify { username: $email}';

}

class ResetPassword extends LoginEvent {
  final String username;
  final String code;
  final String password;

  ResetPassword({
    @required this.username,
    @required this.code,
    @required this.password,
  }) : super([username, code, password]);

  @override
  String toString() =>
      'ResetPassword { username: $username, code: $code, password: $password }';
}


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthenticationBloc authenticationBloc;

  LoginBloc({
    @required this.userRepository,
    @required this.authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null);

  LoginState get initialState => LoginInitial();

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is LoginButtonPressed) {
      yield LoginLoading();

      try {
        final token = await userRepository.login(
          event.username,
          event.password,
        );

        if (token.startsWith("failed:")) {
          yield MessageArrived(isGood: false, message: token);
        } else {
          authenticationBloc.dispatch(LoggedIn(token: token));
        }
      } catch (error) {
        yield MessageArrived(isGood: false, message: error.toString());
      }
    } else if (event is SignupButtonPressed) {
      yield LoginLoading();
      try {
        final token = await userRepository.signup(
          event.username,
          event.password,
        );
        if (token.startsWith("failed:")) {
          yield MessageArrived(isGood: false, message: token);
        } else {
          authenticationBloc.dispatch(LoggedIn(token: token));
        }
        yield LoginInitial();
      } catch (error) {
        yield MessageArrived(isGood: false, message: error.toString());
      }
    } else if (event is CodeRequested) {
      try {
        final sent = await userRepository.getVertificationCode(
          event.email
        );
        if (sent) {
          yield MessageArrived(isGood: true, message :"vertification code sent to your email");
        } else {
          yield MessageArrived(isGood: false, message: "vertification code not sent");
        }
      } catch (error) {
        yield MessageArrived(isGood: false, message: error.toString());
      }
    } else if (event is ResetPasswordVerify) {
      try {
        final sent = await userRepository.resetPasswordVerify(
            event.email
        );
        if (sent) {
          yield MessageArrived(isGood: true, message :"vertification code sent to your email");
        } else {
          yield MessageArrived(isGood: false, message: "vertification code not sent");
        }
      } catch (error) {
        yield MessageArrived(isGood: false, message: error.toString());
      }
    } else if (event is ResetPassword) {
      yield LoginLoading();
      try {
        final result = await userRepository.resetPassword(
          event.username,
          event.code,
          event.password,
        );
        if (result) {
          yield MessageArrived(isGood: true, message :"password reset");
        } else {
          yield MessageArrived(isGood: false, message :"failed to reset password");
        }
      } catch (error) {
        yield MessageArrived(isGood: false, message: error.toString());
      }
    }
  }
}
