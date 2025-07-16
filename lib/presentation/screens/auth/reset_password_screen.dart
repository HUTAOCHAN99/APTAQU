import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:al_quran/presentation/screens/auth/otp_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _emailSent = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _emailSent ? _buildSuccessUI() : _buildResetForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Masukkan email untuk menerima kode OTP reset password:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: const OutlineInputBorder(),
            errorText: _errorMessage,
            filled: true,
            fillColor: Colors.white.withOpacity(0.9),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 25),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _isLoading ? null : _sendResetOTP,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text(
                    'Kirim OTP',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 72, color: Colors.green),
          const SizedBox(height: 20),
          Text(
            'OTP telah dikirim ke ${_emailController.text}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OTPScreen(
                    email: _emailController.text,
                    isRegistration: false,
                  ),
                ),
              );
            },
            child: const Text('Masukkan Kode OTP'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Masukkan email yang valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().sendPasswordResetOTP(email);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(email: email, isRegistration: false),
        ),
      );
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
    _emailController.dispose();
    super.dispose();
  }
}
