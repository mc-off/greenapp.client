import 'dart:async';
import 'package:greenapp/models/user.dart';
import 'package:greenapp/services/http_auth.dart';

import 'base_auth.dart';

class Auth implements BaseAuth {
  final HttpAuth _httpAuth = HttpAuth();

  Future<User> getCurrentUser() async {
    User user = await _httpAuth.currentUser();
    return user;
  }

//  Future<bool> isEmailVerified() {
//    // TODO: implement isEmailVerified
//    throw UnimplementedError();
//  }

  @override
  Future<bool> sendEmailVerification(String email, String code) async {
    bool isValidated = false;
    isValidated = await _httpAuth.sendEmailVerification(email, code);
    return isValidated;
  }

  @override
  Future<bool> resendEmailVerification(String email) async {
    bool isSended = false;
    isSended = await _httpAuth.resendEmailVerification(email);
    return isSended;
  }

  Future<String> signIn(String email, String password) async {
    User user = await _httpAuth.signInWithEmailAndPassword(email, password);
    return user.token;
  }

  Future<void> signOut() async {
    return _httpAuth.signOut();
  }

  Future<bool> signUp(String email, String password, String firstName,
      String lastName, String birthDate) async {
    bool isCodeSended = false;
    isCodeSended = await _httpAuth.signUpWithEmailAndPassword(
        email, password, firstName, lastName, birthDate);
    return isCodeSended;
  }
}
