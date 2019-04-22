import 'package:flutter/material.dart';
import 'package:infomatterapp/widgets/widgets.dart';

class BottomNavigationBarController extends StatefulWidget {
  @override
  _BottomNavigationBarControllerState createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  final List<Widget> pages = [
    FeedPage(
      key: PageStorageKey("FeedPage")
    ),
    BookmarkPage(
      key: PageStorageKey("BookmarkPage"),
    ),
    SourcesDiscoveryPage(
      key: PageStorageKey("SourceDiscoveryPage"),
    ),
    MePage(
      key: PageStorageKey("MePage"),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;


  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
    onTap: (int index) {
      setState(() => _selectedIndex = index);
    },
    currentIndex: selectedIndex,
    type: BottomNavigationBarType.fixed,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          title: Text('Bookmarks')
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        title: Text('Search'),
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text('Me')
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: PageStorage(
        child: pages[_selectedIndex],
        bucket: bucket,
      ),
    );
  }
}