import 'package:flutter/material.dart';
import 'package:vertical_tabs/vertical_tabs.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:infomatterapp/blocs/source_bloc.dart';
import 'package:infomatterapp/blocs/source_item_bloc.dart';
import 'package:infomatterapp/repositories/repositories.dart';
import 'package:infomatterapp/models/models.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class SourceItemWidget extends StatefulWidget{
  final Source source;
  final SourceItemBloc sourceItemBloc;
  SourceItemWidget({
    Key key, @required this.source,
    @required this.sourceItemBloc
  }) : super(key: key);

  @override
  State<SourceItemWidget> createState() {
    // TODO: implement createState
    return SourceItemWidgetState();
  }
}

class SourceItemWidgetState extends State<SourceItemWidget>{
  Source get _source => widget.source;
  SourceItemBloc get _sourceItemBloc => widget.sourceItemBloc;
  bool notNull(Object o) => o != null;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<SourceItemEvent, SourceItemState>(
      bloc: _sourceItemBloc,
      builder: (
        BuildContext context,
        SourceItemState state) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => SourcePage(sourceId: _source.id, sourceName: _source.name,)));
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 10),
            child: Row(
              children: <Widget>[
                _source.photo != null ? Expanded(
                  child: Image.network(_source.photo, width: 20, height: 20,),
                ) : null,
                Expanded(
                  flex: 3,
                  child: Text(_source.name, maxLines: 1,),
                ),
                Expanded(
                  child: IconButton(
                      icon: (state is SourceFollowing) ? Icon(
                        Icons.check,
                        color: Theme.of(context).accentColor,
                      ) : Icon(
                        Icons.add,
                        color: Theme.of(context).accentColor,
                      ),
                      onPressed: (){
                        if (state is SourceNotFollowing)
                          _sourceItemBloc.dispatch(FollowSource(sourceId: _source.id));
                        else if (state is SourceFollowing) {
                          _sourceItemBloc.dispatch(UnfollowSource(sourceId: _source.id));
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