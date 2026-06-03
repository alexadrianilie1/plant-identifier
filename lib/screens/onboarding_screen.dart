import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:plant_identifier/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    // 1. Setam flag-ul pe false, am terminat cu demo-ul pentru totdeauna
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    // 2. Navigam catre StreamBuilder-ul de autentificare
    // Evitam sa mergem orbeste direct spre HomeScreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) return const HomeScreen();
            return const AuthScreen();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: TextStyle(fontSize: 19.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xFF121212),
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Descoperă Natura",
          body: "Scanează flori și descoperă-le secretele cu ușurință folosind inteligența artificială.",
          image: const Center(child: Icon(Icons.camera_alt, size: 100, color: Colors.green)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Cum să obții rezultate bune",
          body: "Pentru o precizie ridicată, asigură-te că floarea este bine luminată și ocupă centrul imaginii. Evită pozele neclare.",
          image: const Center(child: Icon(Icons.center_focus_strong, size: 100, color: Colors.green)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Recunoaștere rapidă",
          body: "Obține rezultate precise în doar câteva secunde.",
          image: const Center(child: Icon(Icons.timer, size: 100, color: Colors.green)),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "19 Specii Recunoscute",
          body: "De la trandafiri și lalele, până la orhidee și lotuși. Baza noastră de date este optimizată pentru cele mai populare plante.",
          image: const Center(child: Icon(Icons.local_florist, size: 100, color: Colors.green)),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // Permite utilizatorului să sară peste onboarding
      showSkipButton: true,
      skip: const Text("Sari peste", style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.bold)),
      next: const Icon(Icons.arrow_forward, color: Colors.green, size: 30, weight: 700.0),
      done: const Text("Gata", style: TextStyle(color: Colors.green, fontSize: 17, fontWeight: FontWeight.bold)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeColor: Colors.green,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

}