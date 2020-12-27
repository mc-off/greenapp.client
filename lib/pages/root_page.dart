import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/pages/home_page.dart';
import 'package:greenapp/pages/login_singup_page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}


final FirebaseAuth _auth = FirebaseAuth.instance;


class RootPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  @override
  void initState()  {
    super.initState();
    final user = _auth.currentUser;
    if (user!=null)
      setState(() {
        authStatus = user.uid.isEmpty
            ? AuthStatus.NOT_LOGGED_IN
            : AuthStatus.LOGGED_IN;
      });
     else
      setState(() {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      });
  }

  void loginCallback() {
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      _auth.signOut();
      authStatus = AuthStatus.NOT_LOGGED_IN;
      displayDialog();
    });
  }

  void displayDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Info"),
        content: new Text("Your session is over\nPlease, re-login"),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context, "Close");
              })
        ],
      ),
    );
  }

  Widget buildWaitingScreen() {
    return CupertinoPageScaffold(
      child: Container(
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignUpPage(
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_auth.currentUser != null && _auth.currentUser.uid.isNotEmpty) {
          return new HomePage(
            logoutCallback: logoutCallback,
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
