import 'package:greenapp/models/user.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<bool> signUp(String email, String password, String firstName,
      String lastName, String birthDate);

  Future<User> getCurrentUser();

  Future<bool> sendEmailVerification(String email, String code);

  Future<void> signOut();

  Future<bool> resendEmailVerification(String email);

//Future<bool> isEmailVerified();
}
