import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String _userKey = 'user_credentials';
  static const String _userEmailKey = 'user_email';

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Try to restore previous sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Save credentials to SharedPreferences
      if (userCredential.user != null) {
        await _saveUserCredentials(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> _saveUserCredentials(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.uid);
    await prefs.setString(_userEmailKey, user.email ?? '');
  }

  Future<bool> isUserLoggedIn() async {
    try {
      // Check if user is signed in with Google
      final isSignedIn = await _googleSignIn.isSignedIn();
      if (!isSignedIn) return false;

      // Check if user is signed in with Firebase
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      // Check if we have stored credentials
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString(_userKey);
      final savedUserEmail = prefs.getString(_userEmailKey);

      return savedUserId != null &&
          savedUserEmail != null &&
          savedUserId == currentUser.uid &&
          savedUserEmail == currentUser.email;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_userEmailKey);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(_userEmailKey) ?? '';
    // TODO: Implement admin email check from Firestore
    print('User email: $userEmail');
    return userEmail.endsWith('@idn.sch.id');
  }
}
