import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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


// ---------- Google (Web: Popup) ----------
static Future<void> signInWithGoogleWeb() async {
final provider = GoogleAuthProvider();
provider.setCustomParameters({'prompt': 'select_account'});


final cred = await _auth.signInWithPopup(provider);
await _upsertUserDoc(cred.user!);
}


// ---------- Facebook (Web: Popup) ----------
static Future<void> signInWithFacebookWeb() async {
final provider = FacebookAuthProvider();
provider.addScope('email');
provider.addScope('public_profile');


final cred = await _auth.signInWithPopup(provider);
await _upsertUserDoc(cred.user!);
}


static Future<void> signOut() => _auth.signOut();
}