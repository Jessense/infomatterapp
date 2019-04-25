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

class SourcesDiscoveryPage extends StatefulWidget {
  SourcesDiscoveryPage({Key key}):
      super(key: key);
  @override
  _SourcesDiscoveryState createState() {
    // TODO: implement createState
    return _SourcesDiscoveryState();
  }
}

class _SourcesDiscoveryState extends State<SourcesDiscoveryPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Discovery"),),
      body: VerticalTabs(
        tabsWidth: 100,
        tabs: <Tab>[
          Tab(child: Text('推荐')),
          Tab(child: Text('科技')),
          Tab(child: Text('技术')),
          Tab(child: Text('大学')),
          Tab(child: Text('财经')),
          Tab(child: Text('教科文')),
          Tab(child: Text('公众号')),
          Tab(child: Text('社交媒体')),
          Tab(child: Text('设计')),
          Tab(child: Text('生活')),
          Tab(child: Text('娱乐')),
          Tab(child: Text('体育')),
          Tab(child: Text('搞笑')),
          Tab(child: Text('其他')),
          Tab(child: Text('全部')),
        ],
        contents: <Widget>[
          new SourceListOfCategory(target: "all"),
          new SourceListOfCategory(target: "1",),
          SourceListOfCategory(target: "2",),
          SourceListOfCategory(target: "9",),
          SourceListOfCategory(target: "3",),
          SourceListOfCategory(target: "5",),
          SourceListOfCategory(target: "4",),
          SourceListOfCategory(target: "E",),
          SourceListOfCategory(target: "6",),
          SourceListOfCategory(target: "C",),
          SourceListOfCategory(target: "7",),
          SourceListOfCategory(target: "A",),
          SourceListOfCategory(target: "B",),
          SourceListOfCategory(target: "Z",),
          SourceListOfCategory(target: "all",),

        ],
      ),
    );
  }
}


class SourceListOfCategory extends StatefulWidget{
  final String target;
  SourceListOfCategory({Key key, @required this.target}):
        assert(target != null),
        super(key: key);

  @override
  State<SourceListOfCategory> createState() {
    // TODO: implement createState
    return _SourceListOfCategoryState();
  }
}

class _SourceListOfCategoryState extends State<SourceListOfCategory> {
  final _scrollController = ScrollController();
  final SourceBloc _sourceBloc = SourceBloc(
      sourcesRepository: SourceRepository(
        sourceApiClient: SourceApiClient(httpClient: http.Client()),
      )
  );
  final _scrollThreshold = 200.0;

  _SourceListOfCategoryState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  void initState() {
    // TODO: implement initState
    _sourceBloc.dispatch(Fetch(target: widget.target));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _sourceBloc,
      builder: (BuildContext context, SourceState state) {
        if (state is SourceUninitialized) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is SourceError) {
          return Center(
            child: Text('failed to fetch sources'),
          );
        }
        if (state is SourceLoaded) {
          if (state.sources.isEmpty) {
            return Center(
              child: Text('no sources'),
            );
          }
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return index >= state.sources.length
                  ? BottomLoader()
                  : SourceItemWidget(
                    source: state.sources[index],
                    sourceItemBloc: SourceItemBloc(
                        sourcesRepository: SourceRepository(
                            sourceApiClient: SourceApiClient(
                                httpClient: http.Client()
                            )
                        ),
                        fromState: state.sources[index].isFollowing ? SourceFollowing() : SourceNotFollowing()
                    ),
                  );
            },
            itemCount: state.hasReachedMax
                ? state.sources.length
                : state.sources.length + 1,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _sourceBloc.dispose();
    super.dispose();
  }

  void _onScroll() {

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _sourceBloc.dispatch(Fetch(target: widget.target));
    }
  }
}


