import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        final response = await authProvider.getProfile(user.id);
        if (mounted) {
          setState(() => _profileData = response);
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage = 'User not logged in');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _errorMessage != null
          ? FloatingActionButton(
              onPressed: _loadProfile,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_profileData == null) {
      return const Center(child: Text('Tidak ada data profil'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 20),
          _buildProfileItem('Nama', _profileData!['username'] ?? '-'),
          _buildProfileItem('Email', _profileData!['email'] ?? '-'),
          _buildProfileItem('Nomor Telepon', _profileData!['phone'] ?? '-'),
          _buildProfileItem(
            'Tanggal Daftar',
            _formatDate(_profileData!['created_at']),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}