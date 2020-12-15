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

//  @override
//  Future<void> sendEmailVerification() {
//    FirebaseUser user = await _firebaseAuth.currentUser();
//    user.sendEmailVerification();
//  }

  Future<String> signIn(String email, String password) async {
    User user = await _httpAuth.signInWithEmailAndPassword(email, password);
    return user.token;
  }

  Future<void> signOut() async {
    return _httpAuth.signOut();
  }

  Future<String> signUp(String email, String password, String firstName,
      String lastName, String birthDate) async {
    User user = await _httpAuth.signUpWithEmailAndPassword(
        email, password, firstName, lastName, birthDate);
    return user.token;
  }
}
