import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';

class MarketTab extends StatefulWidget {
  @override
  _MarketTabState createState() {
    return _MarketTabState();
  }
}

class _MarketTabState extends State<MarketTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: const <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('Market'),
        ),
      ],
    );
  }
}
