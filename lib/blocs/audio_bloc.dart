import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';


import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:infomatterapp/models/models.dart';

typedef void OnError(Exception exception);

enum PlayerState { stopped, playing, paused }

abstract class AudioEvent extends Equatable {
  AudioEvent([List props = const []]) : super(props);
}

class PlayAudio extends AudioEvent{
  final Entry entry;
  PlayAudio({@required this.entry}):
      super([entry]);
  @override
  String toString() {
    // TODO: implement toString
    return 'PlayAudio';
  }
}

class PauseAudio extends AudioEvent{
  final Entry entry;
  PauseAudio({@required this.entry}):
        super([entry]);
  @override
  String toString() {
    // TODO: implement toString
    return 'PauseAudio';
  }
}

class StopAudio extends AudioEvent{
  @override
  String toString() {
    // TODO: implement toString
    return 'StopAudio';
  }
}

abstract class AudioState extends Equatable {
  AudioState([List props = const []]) : super(props);
}

class AudioStopped extends AudioState{
  @override
  String toString() {
    // TODO: implement toString
    return 'AudioStopped';
  }
}

class AudioPlaying extends AudioState{
  final Entry entry;
  AudioPlaying({@required this.entry}):
        super([entry]);
  @override
  String toString() {
    // TODO: implement toString
    return 'AudioPlaying';
  }
}

class AudioPaused extends AudioState{
  final Entry entry;
  AudioPaused({@required this.entry}):
        super([entry]);
  @override
  String toString() {
    // TODO: implement toString
    return 'AudioPaused';
  }
}

class AudioBloc extends Bloc<AudioEvent, AudioState>{
  AudioPlayer audioPlayer = new AudioPlayer();

  @override
  // TODO: implement initialState
  AudioState get initialState => AudioPaused();

  @override
  Stream<AudioState> mapEventToState(AudioEvent event) async* {
    // TODO: implement mapEventToState
    if (event is PlayAudio) {
      if (currentState is AudioPlaying) {
        await audioPlayer.stop();
        await audioPlayer.play(event.entry.audio);
        yield AudioPlaying(entry: event.entry);
      } else {
        await audioPlayer.play(event.entry.audio);
        yield AudioPlaying(entry: event.entry);
      }

    } else if (event is PauseAudio) {
      await audioPlayer.pause();
      yield AudioPaused();
    }
  }

  @override
  void dispose() {
    audioPlayer.stop();
    super.dispose();
  }


}