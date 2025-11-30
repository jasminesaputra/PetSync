import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ------------------------------------------------------------
  // AUTH STREAM
  // ------------------------------------------------------------
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String getUid() => _auth.currentUser?.uid ?? "";

  String currentUserEmail() => _auth.currentUser?.email ?? "";

  // ------------------------------------------------------------
  // ERROR FORMATTER
  // ------------------------------------------------------------
  String formatFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case "invalid-email":
        return "Email format is not valid.";
      case "user-disabled":
        return "This account has been disabled.";
      case "user-not-found":
        return "No account found with this email.";
      case "wrong-password":
        return "Incorrect password.";
      case "email-already-in-use":
        return "This email is already registered.";
      case "weak-password":
        return "Password is too weak.";
      case "too-many-requests":
        return "Too many attempts. Try again later.";
      default:
        return "Authentication failed. Please try again.";
    }
  }

  // ------------------------------------------------------------
  // SIGN IN
  // ------------------------------------------------------------
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw formatFirebaseError(e);
    }
  }

  // ------------------------------------------------------------
  // REGISTER
  // ------------------------------------------------------------
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // OPTIONAL: send email verification
      if (_auth.currentUser != null && !_auth.currentUser!.emailVerified) {
        await _auth.currentUser!.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw formatFirebaseError(e);
    }
  }

  // ------------------------------------------------------------
  // PASSWORD RESET
  // ------------------------------------------------------------
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw formatFirebaseError(e);
    }
  }

  // ------------------------------------------------------------
  // SIGN OUT
  // ------------------------------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
