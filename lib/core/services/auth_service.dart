import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_quran/core/config/app_config.dart';

class AuthService {
  final SupabaseClient _supabase = AppConfig.supabase;

  // Email + Password Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // OTP Registration
  Future<void> sendSignUpOTP(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'yourapp://auth-callback',
    );
  }

  // Password Reset
  Future<void> sendPasswordResetOTP(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
      emailRedirectTo: 'yourapp://reset-password',
    );
  }

  // Verify OTP
  Future<void> verifyOTP({
    required String email,
    required String token,
    required bool isRegistration,
  }) async {
    await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: isRegistration ? OtpType.signup : OtpType.recovery,
    );
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Current User
  User? get currentUser => _supabase.auth.currentUser;
}