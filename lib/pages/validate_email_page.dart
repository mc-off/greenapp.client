import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/text-styles.dart';

import 'package:greenapp/services/base_auth.dart';

enum _DoubleConstants {
  textFieldContainerHeight,
  textFieldContainerWidth,
  textFieldBorderWidth
}

extension _DoubleConstantsExtension on _DoubleConstants {
  double get value {
    switch (this) {
      case _DoubleConstants.textFieldContainerHeight:
        return 50.0;
      case _DoubleConstants.textFieldContainerWidth:
        return 80.0;
      case _DoubleConstants.textFieldBorderWidth:
        return 0.6;
      default:
        return null;
    }
  }
}

class ValidateEmailPage extends StatefulWidget {
  ValidateEmailPage({this.auth, this.validateCallback, this.email});

  final BaseAuth auth;
  final VoidCallback validateCallback;
  final String email;

  @override
  State<StatefulWidget> createState() => _ValidateEmailPageState();
}

class _ValidateEmailPageState extends State<ValidateEmailPage> {
  final _formKey = new GlobalKey<FormState>();
  TextEditingController _code = TextEditingController();
  String _errorMessage;
  String _infoMessage;
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
    _infoMessage = "";
    _isLoading = false;
    super.initState();
  }

  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _infoMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      bool isValidated = false;
      try {
        isValidated = await widget.auth
            .sendEmailVerification(widget.email, _code.value.text);
        setState(() {
          _isLoading = false;
        });

        if (isValidated) {
          widget.validateCallback();
          Navigator.pop(context);
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

  void resendCode() async {
    setState(() {
      _errorMessage = "";
      _infoMessage = "";
      _isLoading = true;
    });
    bool isSended = false;
    try {
      isSended = await widget.auth.resendEmailVerification(widget.email);
      setState(() {
        _isLoading = false;
      });

      if (isSended) {
        setState(() {
          _infoMessage = "Code resended to ${widget.email}";
        });
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

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    _infoMessage = "";
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Login page"),
      ),
      child: Stack(
        children: <Widget>[_showForm(), _showCircularProgress()],
      ),
    );
  }

  Widget _showForm() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              //showLogo(),
              showMainHint(),
              showCodeInput(),
              showPrimaryButton(),
              showSecondaryButton(),
              showErrorMessage(),
              showInfoMessage()
            ],
          ),
        ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget showMainHint() {
    return new Container(
      height: 240,
      width: 200,
      child: Center(
        child: Text(
          "Enter code below:",
          style: TextStyles.largeTitleRegular(),
          //textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget showInfoMessage() {
    if (_infoMessage.length > 0 && _infoMessage != null) {
      return new CupertinoAlertDialog(
          content: Text(
        _infoMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: CupertinoColors.activeBlue,
            height: 1.0,
            fontWeight: FontWeight.bold),
      ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
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
        padding: EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
        child: SizedBox(
          height: 50.0,
          child: new CupertinoButton.filled(
            disabledColor: CupertinoColors.quaternarySystemFill,
            pressedOpacity: 0.4,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: new Text('Validate code',
                style: new TextStyle(
                    fontSize: 18.0, color: CupertinoColors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }

  Widget showSecondaryButton() {
    return new CupertinoButton(
        child: new Text('Send code one more time',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: resendCode);
  }

  Widget showCodeInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: true,
        autofocus: true,
        keyboardType: TextInputType.number,
        controller: _code,
        prefix: Container(
          height: _DoubleConstants.textFieldContainerHeight.value,
          width: _DoubleConstants.textFieldContainerWidth.value,
          alignment: Alignment.centerLeft,
          child: Text(
            "Code",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
          top: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
        )),
      ),
    );
  }
}
