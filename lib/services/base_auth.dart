import 'package:greenapp/models/user.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<User> getCurrentUser();

//Future<void> sendEmailVerification();

//Future<void> signOut();

//Future<bool> isEmailVerified();
}
