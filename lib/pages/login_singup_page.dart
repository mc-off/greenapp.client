import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/text-styles.dart';
import 'package:greenapp/pages/validate_email_page.dart';

import 'package:greenapp/services/base_auth.dart';

enum _DoubleConstants {
  textFieldContainerHeight,
  textFieldContainerWidth,
  textFieldDecorationBorderWidth
}

extension _DoubleConstantsExtension on _DoubleConstants {
  double get value {
    switch (this) {
      case _DoubleConstants.textFieldContainerHeight:
        return 50.0;
      case _DoubleConstants.textFieldContainerWidth:
        return 80.0;
      case _DoubleConstants.textFieldDecorationBorderWidth:
        return 0.6;
      default:
        return null;
    }
  }
}

class LoginSignUpPage extends StatefulWidget {
  LoginSignUpPage({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  final _formKey = new GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _secondName = TextEditingController();
  TextEditingController _birthDate = TextEditingController();
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId =
              await widget.auth.signIn(_email.value.text, _password.value.text);
          print('Signed in: $userId');
        } else {
          bool isCodeSended = await widget.auth.signUp(
              _email.value.text,
              _password.value.text,
              _firstName.value.text,
              _secondName.value.text,
              "2011-11-11");
          if (isCodeSended) {
            debugPrint('Code se1315nded to ${_email.value.text}');
            _showValidationEmailPage(_email.value.text);
          }
          //widget.auth.sendEmailVerification();
          //_showVerifyEmailSentDialog();
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.isNotEmpty) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
          _formKey.currentState.reset();
        });
      }
    }
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
    print("Login switch to" + _isLoginForm.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Login page"),
      ),
      child: Stack(
        children: <Widget>[
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  Widget _showForm() {
    return new SafeArea(
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: new Form(
              key: _formKey,
              child: new ListView(
                shrinkWrap: true,
                children: <Widget>[
                  //showLogo(),
                  showMainHint(),
                  showEmailInput(),
                  showPasswordInput(),
                  showFirstNameInput(),
                  showSecondNameInput(),
                  //showBirthDateInput(),
                  showPrimaryButton(),
                  showSecondaryButton(),
                  showErrorMessage(),
                ],
              ),
            )));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Opacity(
          opacity: 0.3,
          child: Container(
              color: CupertinoColors.lightBackgroundGray,
              child: Center(child: CupertinoActivityIndicator())));
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  void _showValidationEmailPage(String email) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ValidateEmailPage(
                auth: widget.auth,
                validateCallback: validateCallback,
                email: email)));
  }

  void _PasswordRecoveryPage(String email) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ValidateEmailPage(
                auth: widget.auth,
                validateCallback: validateCallback,
                email: email)));
  }

  void validateCallback() {
    _isLoginForm = true;
    validateAndSubmit();
  }

  Widget showMainHint() {
    return new Container(
      height: 140,
      width: 200,
      child: Center(
        child: Text(
          _isLoginForm ? "User account" : "Registration",
          style: TextStyles.largeTitleRegular(),
          //textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget showLogo() {
    return new Hero(
      tag: 'hero',
      child: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
        child: Image(
          height: 200,
          width: 200,
          image: AssetImage(
              _isLoginForm ? 'assets/zoomer.png' : 'assets/shrek.png'),
        ),
      ),
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new CupertinoAlertDialog(
          content: Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: CupertinoColors.systemRed,
            height: 1.0,
            fontWeight: FontWeight.bold),
      ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, _isLoginForm ? 40.0 : 30.0, 0.0, 0.0),
        child: SizedBox(
          height: 50.0,
          child: new CupertinoButton.filled(
            disabledColor: CupertinoColors.quaternarySystemFill,
            pressedOpacity: 0.4,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(
                    fontSize: 18.0, color: CupertinoColors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showSecondaryButton() {
    return new CupertinoButton(
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }

  Widget showEmailInput() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, _isLoginForm ? 10.0 : 00.0, 0.0, 0.4),
      child: new CupertinoTextField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        controller: _email,
        maxLengthEnforced: true,
        maxLength: 30,
        placeholder: 'Email',
        showCursor: true,
        autocorrect: false,
        prefix: Container(
          height: _DoubleConstants.textFieldContainerHeight.value,
          width: _DoubleConstants.textFieldContainerWidth.value,
          alignment: Alignment.centerLeft,
          child: Text(
            "Login",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        decoration: BoxDecoration(
          border: Border.symmetric(
            vertical: BorderSide(
              width: _DoubleConstants.textFieldDecorationBorderWidth.value,
              color: CupertinoColors.separator,
            ),
          ),
          //borderRadius: BorderRadius.circular(32.0),
        ),
      ),
    );
  }

  Widget showFirstNameInput() {
    return _isLoginForm
        ? new Container()
        : new Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: new CupertinoTextField(
              maxLines: 1,
              obscureText: false,
              autofocus: true,
              controller: _firstName,
              placeholder: "Name",
              prefix: Container(
                height: _DoubleConstants.textFieldContainerHeight.value,
                width: _DoubleConstants.textFieldContainerWidth.value,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  width: _DoubleConstants.textFieldDecorationBorderWidth.value,
                  color: CupertinoColors.separator,
                ),
              )),
            ),
          );
  }

  Widget showSecondNameInput() {
    return _isLoginForm
        ? new Container()
        : new Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: new CupertinoTextField(
              maxLines: 1,
              obscureText: false,
              autofocus: true,
              controller: _secondName,
              placeholder: "Surname",
              prefix: Container(
                height: _DoubleConstants.textFieldContainerHeight.value,
                width: _DoubleConstants.textFieldContainerWidth.value,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Surname",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  width: _DoubleConstants.textFieldDecorationBorderWidth.value,
                  color: CupertinoColors.separator,
                ),
              )),
            ),
          );
  }

  Widget showBirthDateInput() {
    return _isLoginForm
        ? new Container()
        : new Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            child: new CupertinoTextField(
              maxLines: 1,
              obscureText: false,
              autofocus: true,
              autocorrect: true,
              keyboardType: TextInputType.datetime,
              controller: _birthDate,
              placeholder: "Birth date",
              prefix: Container(
                height: _DoubleConstants.textFieldContainerHeight.value,
                width: _DoubleConstants.textFieldContainerWidth.value,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Birth",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  width: _DoubleConstants.textFieldDecorationBorderWidth.value,
                  color: CupertinoColors.separator,
                ),
              )),
            ),
          );
  }

  Widget showPasswordInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: true,
        autofocus: true,
        autocorrect: false,
        keyboardType: TextInputType.visiblePassword,
        controller: _password,
        placeholder: "Profile's password",
        prefix: Container(
          height: _DoubleConstants.textFieldContainerHeight.value,
          width: _DoubleConstants.textFieldContainerWidth.value,
          alignment: Alignment.centerLeft,
          child: Text(
            "Pass",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: _DoubleConstants.textFieldDecorationBorderWidth.value,
            color: CupertinoColors.separator,
          ),
        )),
      ),
    );
  }
}
