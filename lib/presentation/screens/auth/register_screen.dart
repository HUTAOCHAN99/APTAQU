import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:al_quran/presentation/screens/auth/otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Hanya boleh mengandung angka';
    }
    if (phone.length < 10 || phone.length > 15) {
      return 'Panjang nomor 10-15 digit';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userData: {
          'username': _usernameController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            email: _emailController.text.trim(),
            isRegistration: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = context.read<AuthProvider>().getFriendlyError();
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background image with overlay
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Content
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (_errorMessage != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red[800],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nama Lengkap',
                                    prefixIcon: Icon(Icons.person),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama lengkap wajib diisi';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email wajib diisi';
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(value)) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nomor Telepon',
                                    prefixIcon: Icon(Icons.phone),
                                    prefixText: '+62 ',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: const Icon(Icons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password wajib diisi';
                                    }
                                    if (value.length < 6) {
                                      return 'Minimal 6 karakter';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'Konfirmasi Password',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      ),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Password tidak cocok';
                                    }
                                    return null;
                                  },
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : const Text(
                                            'DAFTAR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,   
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Sudah punya akun?'),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Masuk disini'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
