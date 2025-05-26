// ignore_for_file: unused_local_variable
import 'package:firebase_auth/firebase_auth.dart';

/// This class handles the Firebase Authentication logic related to registering
/// new users and logging in existing users. This class **does not** handle
/// creating Firebase Firestore database entries for users.
class AuthService {
  /// This registers a new user with the inputted email and password
  /// and returns a String with the relevant result. Possible results:
  ///   - 'Success': a user has been created with the inputted credentials.
  ///   - 'The password provided is too weak.': The inputted password was two weak.
  ///       Firebase Auth does not allow passwords under 6 characters.
  ///   - 'The account already exists for that email.': An account already exists for the
  ///       inputted email.
  ///   - 'Firebase Auth Error: {e}' Any other errors are reported in this format.
  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'Firebase Auth Error: $e';
    }
  }

  /// This logs in an existing with the inputted email and password
  /// and returns a String with the relevant result. Possible results:
  ///   - 'Success': the user has been signed in with the inputted credentials.
  ///   - 'No user found for that email.': No user was found for the email.
  ///   - 'Wrong password provided for that user.': Incorrect password was passed
  ///       for the inputted email.
  ///   - 'Firebase Auth Error: {e}' Any other errors are reported in this format.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message;
      }
    } catch (e) {
      return 'Firebase Auth Error: $e';
    }
  }
}
