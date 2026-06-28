import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/**
 * Serviciu centralizat pentru gestionarea fluxurilor de autentificare.
 * Utilizează [FirebaseAuth] pentru crearea și validarea sesiunilor și
 * [GoogleSignIn] pentru integrarea protocolului OAuth 2.0.
 * Datele utilizatorilor sunt sincronizate automat în [Cloud Firestore].
 */
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Returnează instanța utilizatorului curent autentificat.
  /// Dacă nu există o sesiune activă, returnează [null].
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

  /**
   * Autentifică un utilizator existent folosind adresa de email și parola.
   * 
   * Aruncă o excepție de tip [FirebaseAuthException] care poate fi tratată
   * în interfața grafică prin metoda [getErrorMessage].
   */
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Email/password sign-in error: $e");
      rethrow;
    }
  }

  /**
   * Creează un cont nou folosind adresa de email și parola furnizate.
   * 
   * După crearea cu succes a contului în Firebase Auth, un document corespunzător
   * este generat automat în colecția 'users' din [Cloud Firestore] pentru a stoca
   * metadatele acestuia (ex: data creării).
   */
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

/**
 * Gestionează fluxul de autentificare hibridă prin intermediul Google Sign-In.
 * 
 * Integrează protocolul OAuth 2.0. La o autentificare reușită, datele de profil
 * (nume, fotografie, email) sunt extrase din contul Google și sincronizate 
 * (prin operațiunea de tip merge) în documentul utilizatorului din Firestore.
 */
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

      //5. Sincronizare cu Firestore
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

  /// Deconectare
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /**
   * Returnează identificatorul unic (UID) al utilizatorului curent.
   * Dacă utilizatorul nu este autentificat, returnează un string fallback.
   */
  String get userId {
    return currentUser?.uid ?? 'unknown_user';
  }

  // Future<void> signIsAsGuest() async {

  // }

  /**
   * Verifică starea sesiunii curente.
   * 
   * Returnează [true] dacă aplicația este utilizată în modul vizitator 
   * (niciun utilizator Firebase autentificat).
   */
  bool isGuest() {
    return _firebaseAuth.currentUser == null;
  }

  /**
   * Mapare standardizată a codurilor de eroare Firebase în mesaje 
   * inteligibile și traduse în limba română pentru interfața grafică (UI)
   */
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