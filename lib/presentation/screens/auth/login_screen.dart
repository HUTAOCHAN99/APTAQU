import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),

              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      // App Name
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/title.png',
                            height:
                                MediaQuery.of(context).size.height *
                                0.20, // 15% dari tinggi layar
                            width:
                                MediaQuery.of(context).size.width *
                                0.20, // 60% dari lebar layar
                            fit: BoxFit.contain, // Gambar tidak terdistorsi
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Masuk untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Login Form
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (authProvider.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    authProvider.errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                ),
                                validator: (value) => !value!.contains('@')
                                    ? 'Email tidak valid'
                                    : null,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
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
                                      color: Colors.grey,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Password wajib diisi'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    '/reset-password',
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Lupa Password?',
                                    style: TextStyle(color: Colors.indigo),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : const Text(
                                          'MASUK',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun?',
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                    ), // Adjusted text color
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/register',
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.only(left: 5),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Daftar disini',
                                      style: TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<AuthProvider>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().getAuthErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<AuthProvider>().getFriendlyError()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
