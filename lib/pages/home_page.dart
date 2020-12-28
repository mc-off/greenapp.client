import 'package:flutter/cupertino.dart';
import 'package:greenapp/pages/market_tab.dart';
import 'package:greenapp/pages/profile_tab.dart';
import 'package:greenapp/pages/tasks_tab.dart';
import 'package:greenapp/services/shop/shop_provider.dart';

import 'package:greenapp/services/task/task_provider.dart';

import 'map_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({this.logoutCallback});

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
        TaskProvider _taskProvider = TaskProvider(widget.logoutCallback);
        ShopProvider _shopProvider = ShopProvider(widget.logoutCallback);
        switch (index) {
          case 0:
            returnValue = CupertinoTabView(builder: (context) {
              return new CupertinoPageScaffold(
                  child: TasksTab(
                baseTaskProvider: _taskProvider,
              ));
            });
            break;
          case 1:
            returnValue = CupertinoTabView(builder: (context) {
              return new CupertinoPageScaffold(
                child: MapTab(
                  baseTaskProvider: _taskProvider,
                ),
              );
            });
            break;
          case 2:
            returnValue = new CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child: MarketTab(
                  baseShopProvider: _shopProvider,
                  logoutCallback: widget.logoutCallback,
                ),
              );
            });
            break;
          case 3:
            returnValue = new CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                  child: ProfileTab(
                logoutCallback: widget.logoutCallback,
                baseTaskProvider: _taskProvider,
                baseShopProvider: _shopProvider,
              ));
            });
            break;
        }
        return returnValue;
      },
    );
  }
}
