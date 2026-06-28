import 'package:flutter/material.dart';
import 'package:plant_identifier/screens/home_screen.dart';
import '../servicies/auth_service.dart';

/**
 * Ecranul grafic (UI) dedicat gestionării sesiunilor utilizatorului.
 * 
 * Această componentă este de tip [StatefulWidget] deoarece necesită gestionarea
 * dinamică a stării interfeței: comutarea între modurile de Autentificare/Înregistrare,
 * afișarea indicatoarelor de încărcare (loading spinners) în timpul apelurilor de rețea
 * și validarea în timp real a datelor introduse în formulare.
 */
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Controllere pentru extragerea datelor din campurile text
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Variabile de stare pentru vizibilitatea parolelor
  bool isPasswordVisible = false;
  bool isConfitmPasswordVisible = false;
  
  // Variabile pentru controlul fluxului si afisarea datelor
  bool isLogin = true;
  bool isLoading = false;
  String? errorMessage;

  final AuthService _authService = AuthService();

  /**
   * Procesează trimiterea formularului (Autentificare sau Înregistrare).
   * 
   * Implementează o logică defensivă de validare la nivel de client (Frontend)
   * înainte de a iniția apeluri asincrone către [AuthService]. Erorile returnate
   * de backend (Firebase) sunt interceptate, traduse și afișate în interfață.
   */
  Future<void> _submit() async {
    // 1. Declanșăm starea de încarcare și resetăm erorile anterioare
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {

      if(isLogin) {
        // Validare flux autentificare
        if(_passwordController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
          throw "Te rugăm să completezi toate câmpurile.";
        }
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        // Validare flux înregistrare
        if(_confirmPasswordController.text.trim().isEmpty || _passwordController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
          throw "Te rugăm să completezi toate câmpurile.";
        }
        if(_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
          throw "Parolele nu coincid.";
        }
        await _authService.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Curățăm câmpurile după înregistrare
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

      }

      if(mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = AuthService().getErrorMessage(e);
      });
    } finally {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /**
   * Gestionează fluxul de autentificare integrată Google Sign-In.
   */
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();
      
      if (user != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = "Eroare la autentificarea cu Google. Reîncearcă.";
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo-ul aplicatiei
              const Icon(
                Icons.eco,
                size: 100,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(height: 20.0),

              Text(
                isLogin ? 'Bine ai revenit' : 'Creeaza un cont nou',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                isLogin ? 'Accesează ierbarul tău digital' : 'Înregistrează-te pentru a începe',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30.0),

              // Afișare condițională a contrainerelui de eroare
              if(errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Câmpul pentru email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 20.0),

              // Câmpul pentru parolă
              TextField(
                controller: _passwordController,
                obscureText: !isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Parolă', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                ),
              ),

              // Câmpul pentru confirmarea parolei (doar la înregistrare)
              if(!isLogin) ...[
                const SizedBox(height: 20.0),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !isConfitmPasswordVisible,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration('Confirmă Parolă', Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfitmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfitmPasswordVisible = !isConfitmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30.0),

              // Butonul de autentificare/înregistrare
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: isLoading ? const CircularProgressIndicator(
                  color: Colors.white,
                ) : Text(
                  isLogin ? 'Autentificare' : 'Înregistrare',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              ),
              const SizedBox(height: 20.0),

              // Mecanismul de comutare între login și register
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                    errorMessage = null;

                    // Curățăm câmpurile când schimbăm între moduri
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmPasswordController.clear();
                  });
                },
                child: RichText(
                  text: TextSpan(
                    text: isLogin ? 'Nu ai un cont? ' : 'Ai deja un cont? ',
                    style: const TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: isLogin ? 'Înregistrează-te' : 'Autentificare',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Separator vizual pentru metodele de autentificare alternative
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('SAU', style: TextStyle(color: Colors.white24)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 20.0),


              // Butonul de integrare Google OAuth
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/250px-Google_%22G%22_logo.svg.png',
                  height: 24,
                ),
                label: Text(isLogin ? "Continuă cu Google" : "Înregistrează-te cu Google"),
                onPressed: isLoading ? null : _handleGoogleSignIn,
              ),

              const SizedBox(height: 20,),

              // Accesul de tip vizitator (Guest Mode)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen())
                  );
                },
                child: const Text(
                  "Continuă ca vizitator",
                  style: TextStyle(color: Colors.white54, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /**
   * Metodă utilitară pentru standardizarea aspectului vizual al câmpurilor text.
   * 
   * Returnează un obiect [InputDecoration] reutilizabil care menține consistența
   * designului Dark Mode pe parcursul întregului formular.
   */
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF10B981)),
      ),
    );
  }
}