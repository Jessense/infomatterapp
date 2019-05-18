import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:dynamic_theme/dynamic_theme.dart';

import 'package:infomatterapp/blocs/source_folder_bloc.dart';
import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/widgets/widgets.dart';
import 'package:infomatterapp/repositories/repositories.dart';

class FullCoveragePage extends StatefulWidget{
  final int cluster;
  FullCoveragePage({Key key, @required this.cluster}):
      super(key: key);
  @override
  State<FullCoveragePage> createState() {
    // TODO: implement createState
    return FullCoveragePageState();
  }
}

class FullCoveragePageState extends State<FullCoveragePage>{
  int get _cluster => widget.cluster;
  EntryBloc entryBloc;

  @override
  void initState() {
    // TODO: implement initState
    entryBloc = BlocProvider.of<FullCoverageBloc>(context).entryBloc;
    entryBloc.dispatch(FetchFullCoverage(cluster: _cluster));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('全面报道'),),
      body: BlocBuilder(
        bloc: entryBloc,
        builder: (BuildContext context, EntryState state) {
          if (state is EntryError) {
            return Center(
              child: Text('failed to fetch entries'),
            );
          }
          if (state is EntryUninitialized) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is EntryLoaded) {
            if (state.entries.length == 0) {
              return Center(
                child: Text('empty'),
              );
            }
            return ListView.builder(
              itemBuilder:(BuildContext context, int index) {
                return EntryWidget(entry: state.entries[index], index: index, type: 4,);
              },
              itemCount: state.entries.length,
            );
          }
          return Container();
        },
      ),
    );
  }
}