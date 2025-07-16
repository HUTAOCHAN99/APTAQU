import 'dart:async';

import 'package:al_quran/presentation/screens/auth/new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:al_quran/core/provider/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final bool isRegistration;

  const OTPScreen({
    super.key,
    required this.email,
    this.isRegistration = false,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  late Timer _resendTimer;
  int _resendCooldown = 30;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _resendTimer.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() => _resendCooldown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorMessage = 'Masukkan 6 digit kode');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().verifyOTP(
        email: widget.email,
        token: _otpController.text,
        isRegistration: widget.isRegistration,
      );

      if (!mounted) return;

      if (widget.isRegistration) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordScreen(
              email: widget.email,
              token: _otpController.text,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = context.read<AuthProvider>().getFriendlyError(),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOTP() async {
    setState(() {
      _resendCooldown = 30;
      _errorMessage = null;
    });
    _startResendTimer();

    try {
      if (widget.isRegistration) {
        await context.read<AuthProvider>().registerWithOTP(widget.email);
      } else {
        await context.read<AuthProvider>().sendPasswordResetOTP(widget.email);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kode OTP baru telah dikirim')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _errorMessage = context.read<AuthProvider>().getFriendlyError(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi OTP'),
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
                          child: Column(
                            children: [
                              Text(
                                'Kode dikirim ke',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                widget.email,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 30),
                              TextField(
                                controller: _otpController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                                decoration: InputDecoration(
                                  hintText: '••••••',
                                  counterText: '',
                                  errorText: _errorMessage,
                                  border: const OutlineInputBorder(),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _verifyOTP,
                                  child: _isLoading
                                      ? const CircularProgressIndicator()
                                      : const Text('Verifikasi'),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: _resendCooldown > 0 || _isLoading
                                    ? null
                                    : _resendOTP,
                                child: Text(
                                  _resendCooldown > 0
                                      ? 'Kirim ulang dalam $_resendCooldown detik'
                                      : 'Kirim ulang OTP',
                                ),
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
}
