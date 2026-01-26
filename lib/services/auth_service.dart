import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> _upsertUserDoc(User user, {String? role}) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    final data = <String, dynamic>{
      'email': user.email ?? '',
      'name': user.displayName ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      data['role'] = role ?? 'customer';
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(data, SetOptions(merge: true));
  }

  // ---------- Email/Password ----------
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _upsertUserDoc(cred.user!);
  }

  // ---------- Google (Mobile) ----------
  static Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) return; // User canceled
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final cred = await _auth.signInWithCredential(credential);
      await _upsertUserDoc(cred.user!);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // ---------- Google (Web: Popup) ----------
  static Future<void> signInWithGoogleWeb() async {
    final provider = GoogleAuthProvider();
    provider.setCustomParameters({'prompt': 'select_account'});

    final cred = await _auth.signInWithPopup(provider);
    await _upsertUserDoc(cred.user!);
  }

  // ---------- Facebook (Mobile) ----------
  static Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) return;
      
      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.token);
      
      final cred = await _auth.signInWithCredential(credential);
      await _upsertUserDoc(cred.user!);
    } catch (e) {
      print('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  // ---------- Facebook (Web: Popup) ----------
  static Future<void> signInWithFacebookWeb() async {
    final provider = FacebookAuthProvider();
    provider.addScope('email');
    provider.addScope('public_profile');

    final cred = await _auth.signInWithPopup(provider);
    await _upsertUserDoc(cred.user!);
  }

  // ---------- Apple (Mobile & Web) ----------
  static Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      final cred = await _auth.signInWithCredential(oAuthCredential);
      await _upsertUserDoc(cred.user!);
    } catch (e) {
      print('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // ---------- Get User Role ----------
  static Future<String?> getMyRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final doc = await _db.collection('users').doc(user.uid).get();
    return doc.data()?['role'] as String?;
  }

  static Future<void> signOut() => _auth.signOut();
}