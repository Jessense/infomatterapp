import 'package:flutter/material.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/blocs.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourceItemWidget extends StatefulWidget{
  final Source source;
  SourceItemWidget({
    Key key, @required this.source
  }) : super(key: key);

  @override
  State<SourceItemWidget> createState() {
    // TODO: implement createState
    return SourceItemWidgetState();
  }
}

class SourceItemWidgetState extends State<SourceItemWidget>{
  Source get _source => widget.source;
  bool notNull(Object o) => o != null;

  SourceBloc get sourceBloc => BlocProvider.of<SourceBloc>(context);


  bool checkboxValueCity = false;
  List<String> allCities = ['Alpha', 'Beta', 'Gamma'];
  List<String> selectedCities = [];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<SourceEvent, SourceState>(
      bloc: sourceBloc,
      builder: (
        BuildContext context,
        SourceState state) {
        return GestureDetector(
//          onTap: () {
//            Navigator.push(context, MaterialPageRoute(builder: (context) =>
//              Scaffold(
//                appBar: AppBar(title: Text(_source.name),),
//                body: SourceFeed(sourceId: _source.id),
//              )));
//          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
            child: Row(
              children: <Widget>[
                _source.photo != null ? Expanded(
                  child: Image.network(_source.photo, width: 20, height: 20,),
                ) : Expanded(child: Container(width: 20, height: 20,),),
                Expanded(
                  flex: 3,
                  child: Text(_source.name, maxLines: 1,),
                ),
                Expanded(
                  child: IconButton(
                      icon: _source.isFollowing ? Icon(
                        Icons.check,
                        color: Theme.of(context).accentColor,
                      ) : Icon(
                        Icons.add,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: (){
                        if (_source.isFollowing)
                          sourceBloc.dispatch(UnfollowSource(sourceId: _source.id, sourceName: _source.name));
                        else {
                          if (BlocProvider.of<SearchBloc>(context).searchRepository.type == 'sourceKeyword')
                            sourceBloc.dispatch(FollowSource(sourceId: _source.id, sourceName: _source.name));
                          else {
                            print('hihihihi');
                            sourceBloc.dispatch(AddSource(source: _source));
                          }

                        }

                      }
                  ),
                )
              ].where(notNull).toList(),
            ),
          ),
        );
      }
    );
  }
}