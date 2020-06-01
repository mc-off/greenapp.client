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
            const CSHeader('Brightness'),
            CSWidget(
                CupertinoSlider(
                  value: 0.5,
                  onChanged: (double value) {},
                ),
                style: brightnessStyle),
            CSControl(
              nameWidget: Text('Auto brightness'),
              contentWidget: CupertinoSwitch(
                value: true,
                onChanged: (bool value) {},
              ),
              style: brightnessStyle,
            ),
            CSHeader('Selection'),
            CSSelection<int>(
              items: const <CSSelectionItem<int>>[
                CSSelectionItem<int>(text: 'Day mode', value: 0),
                CSSelectionItem<int>(text: 'Night mode', value: 1),
              ],
              onSelected: (index) {
                print(index);
              },
              currentSelection: 0,
            ),
            CSDescription(
              'Using Night mode extends battery life on devices with OLED display',
            ),
            const CSHeader(''),
            CSControl(
              nameWidget: Text('Loading...'),
              contentWidget: CupertinoActivityIndicator(),
            ),
            CSButton(CSButtonType.DEFAULT, "Licenses", () {
              print("It works!");
            }),
            const CSHeader(''),
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
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}

CSWidgetStyle brightnessStyle = const CSWidgetStyle(
    icon: const Icon(CupertinoIcons.brightness_solid,
        color: CupertinoColors.black));
