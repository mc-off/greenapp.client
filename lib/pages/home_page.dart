import 'package:flutter/cupertino.dart';
import 'package:greenapp/pages/market_tab.dart';
import 'package:greenapp/pages/profile_tab.dart';
import 'package:greenapp/pages/tasks_tab.dart';
import 'package:greenapp/services/base_auth.dart';

import 'map_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({this.userId, this.auth, this.logoutCallback});

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.folder_solid),
            title: Text("Tasks"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.location_solid),
            title: Text("Map"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.shopping_cart),
            title: Text("Market"),
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_solid),
            title: Text("Profile"),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        CupertinoTabView returnValue;
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: TasksTab(),
              );
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: MapTab(),
              );
            });
            break;
          case 2:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: MarketTab(),
              );
            });
            break;
          case 3:
            returnValue = CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: ProfileTab(
                    userId: widget.userId,
                    auth: widget.auth,
                    logoutCallback: widget.logoutCallback),
              );
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
