import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:greenapp/pages/login_singup_page.dart';
import 'package:greenapp/pages/root_page.dart';
import 'package:greenapp/services/authentication.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: new RootPage(
          auth: new Auth(),
        ));
  }
}
