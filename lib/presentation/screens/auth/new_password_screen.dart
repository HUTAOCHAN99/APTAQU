import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Baru'),
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
                                TextFormField(
                                  initialValue: widget.email,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    prefixIcon: Icon(Icons.email),
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password Baru',
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
                                    if (value == null || value.isEmpty)
                                      return 'Wajib diisi';
                                    if (value.length < 6)
                                      return 'Minimal 6 karakter';
                                    return null;
                                  },
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
                                ),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _updatePassword,
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : const Text('Update Password'),
                                  ),
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

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().updatePassword(
        newPassword: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil diupdate!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      setState(
        () => _errorMessage = context.read<AuthProvider>().getFriendlyError(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
