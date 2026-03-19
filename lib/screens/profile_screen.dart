import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plant_identifier/screens/auth_screen.dart';
import 'package:plant_identifier/servicies/auth_service.dart';
import 'package:plant_identifier/servicies/db_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final DBService _dbService = DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profilul Meu",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      // Asculta modificarile de autentificare (login / logout)
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          // Afiseaza loader pana cand se rezolva conexiunea
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF10B981),
              ),
            );
          }

          return _buildProfileContent(context, user);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User? user) {
    final AuthService authService = AuthService();
    final String userEmail = user?.email ?? "Utilizator";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildProfileAvatar(user),
            const SizedBox(height: 24),

            const Text(
              "Autentificat ca:",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),

            Text(
              userEmail,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // Container pentru statistici
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.local_florist,
                    "Plante",
                    _dbService.getDistinctPlantCount(),
                  ),
                  _buildStatItem(
                    Icons.camera,
                    "Scanari",
                    _dbService.getFlowerCount(),
                  ),
                  _buildStatItem(
                    Icons.bookmark,
                    "Favorite",
                    _dbService.getFavoriteFlowerCount(),
                  ),
                ],
              ),
            ),

            const Spacer(),

            _buildLogoutButton(context, authService),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Avatar utilizator cu poza Google sau icon fallback
  Widget buildProfileAvatar(User? user) {
    final photoUrl = user?.photoURL;
    final highResPhoto =
        photoUrl?.replaceAll('s96-c', 's400-c'); // marire rezolutie poza Google

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF1E1E1E),
        border: Border.all(
          color: const Color(0xFF10B981),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 20,
          ),
        ],
        image: highResPhoto != null
            ? DecorationImage(
                image: NetworkImage(highResPhoto),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: highResPhoto == null
          ? const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            )
          : null,
    );
  }

  // Widget pentru fiecare statistica
  Widget _buildStatItem(
      IconData icon, String label, Stream<int> streamValue) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF10B981), size: 28),
          const SizedBox(height: 4),
          StreamBuilder<int>(
            stream: streamValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const SizedBox(
                  height: 14,
                  width: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                );
              }

              return Text(
                "${snapshot.data ?? 0}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            },
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Buton de logout cu confirmare
  Widget _buildLogoutButton(
      BuildContext context, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          bool? confirm = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                "Deconectare",
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                "Sigur vrei sa iesi din cont?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    "Nu",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    "Da",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await authService.signOut();

            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(),
                ),
                (route) => false,
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withOpacity(0.1),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.red),
          ),
        ),
        icon: const Icon(Icons.logout),
        label: const Text(
          "Deconectare",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
