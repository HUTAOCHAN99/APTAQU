import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:al_quran/core/constant/colors.dart';
import 'dart:ui'; // For ImageFilter

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'unknown date';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return 'invalid date';
    }
  }

  Widget _buildMenuItem({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(imagePath, width: 24, height: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Anda yakin ingin keluar dari aplikasi?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await authProvider.signOut();
                if (mounted) {
                  navigator.pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final userMetadata = currentUser?.userMetadata ?? {};

    return Stack(
      children: [
        // Blurred Background
        Positioned.fill(
          child: Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text(
              'APTAQU',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppColors.primaryBlue.withOpacity(0.7),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                icon: const Icon(Icons.settings, color: Colors.white),
              ),
            ],
          ),
          body: Column(
            children: [
              // Bagian atas (info akun)
              if (currentUser != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.85),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userMetadata['username'] != null)
                                  Text(
                                    userMetadata['username'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  currentUser.email ?? 'No email',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Member since ${_formatDate(currentUser.createdAt)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/edit-profile'),
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Bagian tengah (menu utama yang bisa discroll)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        imagePath: 'assets/images/tafsir_bahasa.png',
                        title: "Tafsir Bahasa",
                        onTap: () =>
                            Navigator.pushNamed(context, '/tafsir-bahasa'),
                      ),
                      _buildMenuItem(
                        imagePath: 'assets/images/tafsir_ilmi.png',
                        title: "Tafsir Ilmi",
                        onTap: () =>
                            Navigator.pushNamed(context, '/tafsir-ilmi'),
                      ),
                      _buildMenuItem(
                        imagePath: 'assets/images/tafsir_tematik.png',
                        title: "Tafsir Tematik",
                        onTap: () =>
                            Navigator.pushNamed(context, '/tafsir-tematik'),
                      ),
                      _buildMenuItem(
                        imagePath: 'assets/images/tafsir_tarikh.png',
                        title: "Tafsir Tarikh",
                        onTap: () =>
                            Navigator.pushNamed(context, '/tafsir-tarikh'),
                      ),
                      _buildMenuItem(
                        imagePath: 'assets/images/game.jpeg',
                        title: "Game",
                        onTap: () => Navigator.pushNamed(context, '/game'),
                      ),
                      _buildMenuItem(
                        imagePath: 'assets/images/leaderboard.jpeg',
                        title: "Leaderboard",
                        onTap: () =>
                            Navigator.pushNamed(context, '/leaderboard'),
                      ),
                    ],
                  ),
                ),
              ),

              // Bagian bawah (tombol logout)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => _showLogoutDialog(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
