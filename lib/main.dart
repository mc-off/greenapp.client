import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:greenapp/pages/root_page.dart';
import 'package:greenapp/services/authentication.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: RootPage(
          auth: Auth(),
        ));
  }
}
