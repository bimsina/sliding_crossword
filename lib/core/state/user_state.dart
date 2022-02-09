import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus { idle, loggedIn, loggedOut, loggingIn }

class UserState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;
  set status(AuthStatus value) {
    _status = value;
    notifyListeners();
  }

  User? _user;
  User? get user => _user;
  set user(User? data) {
    _user = data;
    notifyListeners();
  }

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;
  set isAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  UserState() {
    _auth.authStateChanges().listen(_authStateListener);
  }

  void _authStateListener(User? listenedUser) {
    if (listenedUser == null) {
      _isAdmin == false;
      status = AuthStatus.loggedOut;
    } else {
      _user = listenedUser;
      _fetchIfAdmin();
      status = AuthStatus.loggedIn;
    }
  }

  signInAnonymously(BuildContext context) async {
    status = AuthStatus.loggingIn;

    await _auth.signInAnonymously().catchError((onError) {
      _showErrorMessage(context);

      status = AuthStatus.loggedOut;
    });
  }

  signInWithGoogle(BuildContext context) async {
    status = AuthStatus.loggingIn;
    final AuthCredential? credential =
        await _getGoogleSignInCredential(context);

    if (credential == null) return;

    await _auth.signInWithCredential(credential).catchError((onError) {
      _showErrorMessage(context);

      status = AuthStatus.loggedOut;
    });
  }

  signOut() {
    _auth.signOut();
    _googleSignIn.signOut();
  }

  Future<AuthCredential?> _getGoogleSignInCredential(
      BuildContext context) async {
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn().catchError((e) {
      _showErrorMessage(context);
      status = AuthStatus.loggedOut;
    });
    if (googleUser == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return credential;
  }

  _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Oops! Something went wrong.")));
  }

  _fetchIfAdmin() {
    // if (_user == null) return;
    // final _usersDocument =
    //     FirebaseFirestore.instance.collection('users').doc(_user!.uid);

    // _usersDocument.get().then((value) {
    //   if (value.exists) {
    //     isAdmin = value.data()?['is_admin'] ?? false;
    //   }
    // });
    if (_user?.uid == "YJRNkpUnKJaz2bqhTnoynUr3fO53") {
      isAdmin = true;
    }
  }
}
