import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:greenapp/services/base_auth.dart';

class ProfileTab extends StatefulWidget {
  ProfileTab({this.userId, this.auth, this.logoutCallback});

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;

  @override
  _ProfileTabState createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(semanticChildCount: 1, slivers: <Widget>[
      const CupertinoSliverNavigationBar(
        largeTitle: Text('Profile'),
      ),
      SliverList(
        delegate: SliverChildListDelegate(
          [
            Row(children: <Widget>[ClipOval()]),
            const CSHeader('Session'),
            CSButton(CSButtonType.DESTRUCTIVE, "Sign out", () {
              signOut();
            })
          ],
        ),
      ),
    ]);
  }

  signOut() async {
    try {
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}

CSWidgetStyle brightnessStyle = const CSWidgetStyle(
    icon: const Icon(CupertinoIcons.brightness_solid,
        color: CupertinoColors.black));
