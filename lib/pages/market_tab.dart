import 'package:flutter/cupertino.dart';

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
