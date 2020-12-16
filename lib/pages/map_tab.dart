import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:greenapp/models/app_state_model.dart';

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() {
    return _MapTabState();
  }
}

class _MapTabState extends State<MapTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: const <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('Map'),
        ),
      ],
    );
  }
}
