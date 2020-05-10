import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Flutter login demo"),
          //TODO sign out performer
          trailing: GestureDetector(
            onTap: () {
              debugPrint('Sign Out tapped');
            },
            child: Text(
              "Sign out",
              style: TextStyle(
                color: CupertinoColors.activeBlue,
              ),
            ),
          ),
        ),
        child: Center(
          child: Text("Hello World"),
        ));
  }
}
