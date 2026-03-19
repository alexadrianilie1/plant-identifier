import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plant_identifier/screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  
  try{
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully.");
  } catch(e){
    print("Firebase initialization error: $e");
  }

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp(
    {
      super.key,
    }
  );

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flower Scanner",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF10B981),
        colorScheme: ColorScheme.dark(
          primary:  const Color(0xFF121212),
          secondary: const Color(0xFF10B981),
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        // Verificarea starii de autentificare a utilizatorului
        builder: (context, snapshot) {
          if(snapshot.hasData){
            // Daca utilizatorul este autentificat, afisam ecranul principal
            return const HomeScreen();
          }
          
          // Daca utilizatorul nu este autentificat, afisam ecranul de autentificare
          return const AuthScreen();
        },

      )
    );
  }
}
