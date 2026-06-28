import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plant_identifier/screens/auth_screen.dart';
import 'package:plant_identifier/screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

/**
 * Punctul de intrare principal al aplicației (Entry Point).
 * 
 * Gestionează faza de bootstrapping (inițializare) a aplicației. Deoarece 
 * necesită comunicarea cu codul nativ (Platform Channels) înainte de apelul [runApp],
 * funcția este marcată ca [async], iar [WidgetsFlutterBinding.ensureInitialized] 
 * garantează că legăturile framework-ului sunt stabilite corect.
 */
void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inițializarea Firebase
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch(e){
    print("Firebase initialization error: $e");
  }

  // 2. Încărcarea variabilelor de mediu
  await dotenv.load(fileName: ".env");

  // 3. Verificarea stării preexistente pentru a determina fluxul inițial
  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime));
}

/**
 * Clasa rădăcină (Root Widget) a arborelui de componente Flutter.
 * 
 * Injectează configurația globală a tematicii (Material Design - Dark Mode) 
 * și definește logica de rutare inițială a utilizatorului pe baza stării locale 
 * și a validității jetonului de autentificare (Auth Token).
 */
class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({
    super.key,
    required this.isFirstTime,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flower Scanner",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF10B981),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF121212),
          secondary: const Color(0xFF10B981),
        ),
      ),
      // 1. Verificam MAI INTAI daca este la prima deschidere a aplicatiei
      home: isFirstTime 
          ? const OnboardingScreen() // Daca da, aratam demo-ul
          : _getAuthOrHomeScreen(),  // Daca nu, verificam autentificarea
    );
  }

  /// Logica Firebase intr-o metoda separata pentru lizibilitate
  Widget _getAuthOrHomeScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Un mic ecran de incarcare cat timp Firebase verifica token-ul
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
          );
        }
        
        if (snapshot.hasData) {
          return const HomeScreen(); // Utilizator logat
        }
        
        return const AuthScreen(); // Utilizator nelogat
      },
    );
  }
}
