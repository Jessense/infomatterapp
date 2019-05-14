import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/blocs/source_folder_bloc.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Transition transition) {
    super.onTransition(transition);
    print(transition);
  }
}

void main() {
  BlocSupervisor().delegate = SimpleBlocDelegate();
  runApp(App(userRepository: UserRepository(
    userApiClient: UserApiClient(
      httpClient: http.Client(),
    )
  )));
}

class App extends StatefulWidget {
  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AuthenticationBloc authenticationBloc;
  EntryBloc entryBloc;
  SourceFolderBloc sourceFolderBloc;
  SourceBloc sourceBloc;
  UserRepository get userRepository => widget.userRepository;
  SearchBloc searchBloc;
  AudioBloc audioBloc;


  @override
  void initState() {
    authenticationBloc = AuthenticationBloc(userRepository: userRepository);
    entryBloc = EntryBloc(
      entriesRepository: EntriesRepository(
        entriesApiClient: EntriesApiClient(httpClient: http.Client()),
      ),
      fromState: EntryUninitialized(),
    );
    sourceFolderBloc = SourceFolderBloc(
        sourceFoldersRepository: SourceFolderRepository(
            sourceFolderApiClient: SourceFolderApiClient(
                httpClient: http.Client()
            )
        )
    );
    sourceBloc = SourceBloc(
        sourcesRepository: SourceRepository(
            sourceApiClient: SourceApiClient(
                httpClient: http.Client()
            )
        ),
        sourceFolderBloc: sourceFolderBloc
    );
    searchBloc = SearchBloc(
        searchRepository: SearchRepository(
            SearchApiClient(
                httpClient: http.Client()
            )
        ),
        sourceBloc: sourceBloc
    );
    audioBloc = AudioBloc();

    authenticationBloc.dispatch(AppStarted());
    super.initState();
  }

  @override
  void dispose() {
    authenticationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => new ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Colors.black,
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return BlocProviderTree(
              blocProviders: [
                BlocProvider<AuthenticationBloc>(bloc: authenticationBloc,),
                BlocProvider<EntryBloc>(bloc: entryBloc,),
                BlocProvider<SourceFolderBloc>(bloc: sourceFolderBloc,),
                BlocProvider<SourceBloc>(bloc: sourceBloc),
                BlocProvider<SearchBloc>(bloc: searchBloc,),
                BlocProvider<AudioBloc>(bloc: audioBloc,),
              ],
              child: MaterialApp(
                  theme: theme,
                  home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
                    bloc: authenticationBloc,
                    builder: (BuildContext context, AuthenticationState state) {
                      if (state is AuthenticationUninitialized) {
                        return SplashPage();
                      }
                      if (state is AuthenticationAuthenticated) {
                        return Home();
                      }
                      if (state is AuthenticationUnauthenticated) {
                        return LoginPage(userRepository: userRepository);
                      }
                      if (state is AuthenticationLoading) {
                        return LoadingIndicator();
                      }
                    },
                  ),
              )
          );
          return new MaterialApp(
            theme: theme,
            home: BlocProvider<AuthenticationBloc>(
              bloc: authenticationBloc,
              child: BlocBuilder<AuthenticationEvent, AuthenticationState>(
                  bloc: authenticationBloc,
                  builder: (BuildContext context, AuthenticationState state) {
                    if (state is AuthenticationUninitialized) {
                      return SplashPage();
                    }
                    if (state is AuthenticationAuthenticated) {
                      return Home();
                    }
                    if (state is AuthenticationUnauthenticated) {
                      return LoginPage(userRepository: userRepository);
                    }
                    if (state is AuthenticationLoading) {
                      return LoadingIndicator();
                    }
                  },
                ),
            )
          );
        }
    );
//    return BlocProvider<AuthenticationBloc>(
//      bloc: authenticationBloc,
//      child: MaterialApp(
//        theme: new ThemeData(
//          brightness: Brightness.dark,
//          primaryColor: Colors.black,
//          accentColor: Colors.black,
//        ),
//        home: BlocBuilder<AuthenticationEvent, AuthenticationState>(
//          bloc: authenticationBloc,
//          builder: (BuildContext context, AuthenticationState state) {
//            if (state is AuthenticationUninitialized) {
//              return SplashPage();
//            }
//            if (state is AuthenticationAuthenticated) {
//              return Home();
//            }
//            if (state is AuthenticationUnauthenticated) {
//              return LoginPage(userRepository: userRepository);
//            }
//            if (state is AuthenticationLoading) {
//              return LoadingIndicator();
//            }
//          },
//        ),
//      ),
//    );
  }
}
