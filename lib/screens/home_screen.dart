import 'dart:ui'; // Necesar pentru efectul de Blur
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_identifier/screens/auth_screen.dart';

import 'herbar_screen.dart';   
import 'scan_screen.dart';     
import 'profile_screen.dart';  

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Pornim pe Scanare (mijloc)

  bool get _isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Modificăm lista de ecrane să aibă mereu 3 elemente
  List<Widget> get _screens {
    return [
      _isLoggedIn ? const HerbarScreen() : _buildPlaceholder("Ierbar"),
      const ScanScreen(),
      _isLoggedIn ? const ProfileScreen() : _buildPlaceholder("Profil"),
    ];
  }

  // Widget care apare în locul ecranelor blocate
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 80, color: Colors.white24),
          const SizedBox(height: 20),
          Text("Conectează-te pentru $title", 
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AuthScreen())),
            child: const Text("Autentificare"),
          )
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Luăm ecranele într-o variabilă locală
    final currentScreens = _screens;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _currentIndex, // Folosim direct indexul, acum e sigur (mereu 3 ecrane)
        children: currentScreens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 5, bottom: 15),
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E).withOpacity(0.9),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: const Color(0xFF10B981),
                  unselectedItemColor: Colors.grey.withOpacity(0.5),
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 0,
                  unselectedFontSize: 0,
                  iconSize: 24,
                  // Bara are mereu 3 iteme, dar cu iconițe diferite pentru vizitatori
                  items: [
                    _buildNavItem(
                      Icons.eco_outlined, 
                      Icons.eco, 
                      'Herbar'
                    ),
                    _buildNavItem(Icons.camera_alt_outlined, Icons.camera_alt, 'Scanare'),
                    _buildNavItem(
                      Icons.person_outline, 
                      Icons.person, 
                      'Profil'
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    if (_isLoggedIn) {
      return [
        _buildNavItem(Icons.eco_outlined, Icons.eco, 'Herbar'),
        _buildNavItem(Icons.camera_alt_outlined, Icons.camera_alt, 'Scanare'),
        _buildNavItem(Icons.person_outline, Icons.person, 'Profil'),
      ];
    } else {
      return [
        _buildNavItem(Icons.camera_alt_outlined, Icons.camera_alt, 'Scanare'),
        _buildNavItem(Icons.login, Icons.login, 'Login'), // Sugestie de login
      ];
    }
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 26),
      activeIcon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(activeIcon, size: 26),
      ),
      label: label,
    );
  }
}

