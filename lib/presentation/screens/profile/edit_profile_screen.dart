import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:al_quran/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  String? _errorMessage;
  final _supabase = AppConfig.supabase; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController = TextEditingController(
      text: authProvider.currentUser?.userMetadata?['username'] ?? '',
    );
    _phoneController = TextEditingController(
      text: authProvider.currentUser?.userMetadata?['phone'] ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user != null) {
        // Update profile di tabel profiles
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'username': _usernameController.text,
          'phone': _phoneController.text,
        });

        // Update user metadata in auth
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'username': _usernameController.text,
              'phone': _phoneController.text,
            },
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
      });
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
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}