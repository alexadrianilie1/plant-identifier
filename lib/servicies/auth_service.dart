import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Obtinerea utilizatorului curent sau null daca nu este autentificat
  User? get currentUser => _firebaseAuth.currentUser;

  // Autentificare anonima
  // Future<User?> signInAnonymously() async {
  //   try {
  //     UserCredential userCredential = await _firebaseAuth.signInAnonymously();
  //     return userCredential.user;
  //   } catch (e) {
  //     print("Anonymous sign-in error: $e");
  //     return null;
  //   }
  // }

  // Autentificare cu email si parola
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Email/password sign-in error: $e");
      rethrow;
    }
  }

  // Inregistrare cu email si parola
  Future<User?> createUserWithEmailAndPassword({required String email, required String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      if(userCredential.user != null) {
        await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(
            {
              'email': email,
              'createdAt': FieldValue.serverTimestamp(),
            }
          );
      }
      return userCredential.user;
    } catch (e) {
      print("Email/password registration error: $e");
      rethrow;
    }
  }

Future<User?> signInWithGoogle() async {
    try {

      await _googleSignIn.initialize();
      // 1. Deschide fereastra de selectie a contului Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) return null; // Utilizatorul a inchis fereastra

      // 2. Obtine detaliile de autentificare de la Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Creeaza credentialul pentru Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Autentificare in Firebase
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Sincronizare cu Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In error: $e");
      return null;
    }
  }

  // Deconectare
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // ID-ul utilizatorului curent
  String get userId {
    return currentUser?.uid ?? 'unknown_user';
  }

  Future<void> signIsAsGuest() async {

  }

  bool isGuest() {
    return _firebaseAuth.currentUser == null;
  }

  String getErrorMessage(dynamic e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nu am găsit niciun cont cu acest email.';
      case 'wrong-password':
        return 'Parola introdusă este incorectă.';
      case 'email-already-in-use':
        return 'Acest email este deja înregistrat.';
      case 'weak-password':
        return 'Parola este prea slabă. Folosește cel puțin 6 caractere.';
      case 'invalid-email':
        return 'Adresa de email nu are un format valid.';
      case 'network-request-failed':
        return 'Problemă de conexiune. Verifică internetul.';
      case 'too-many-requests':
        return 'Prea multe încercări de autentificare. Încearcă mai târziu.';
      case 'invalid-credential':
        return 'Email sau parolă invalidă. Verifică și încearcă din nou.';
      default:
        return 'A apărut o eroare neașteptată. Încearcă din nou.';
    }
  }
  return e.toString();
}
}