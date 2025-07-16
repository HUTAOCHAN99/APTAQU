import 'package:al_quran/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_quran/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = AppConfig.supabase;
  final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._authService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _authService.currentUser;

  Future<bool> isLoggedInAndVerified() async {
    return _authService.currentUser != null &&
        _authService.currentUser!.emailConfirmedAt != null;
  }

  String getFriendlyError() {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      await _authService.login(email: email, password: password);
    } on AuthException catch (e) {
      _errorMessage = getAuthErrorMessage(e);
      rethrow;
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'alquranapp://reset-password',
        shouldCreateUser: false,
      );
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String token,
    required bool isRegistration,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: isRegistration ? OtpType.signup : OtpType.recovery,
      );

      if (response.session == null && !isRegistration) {
        return;
      }
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    _setLoading(true);
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    _setLoading(true);
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': userData['username'], 'phone': userData['phone']},
        emailRedirectTo: _getRedirectUrl(),
      );

      if (response.user == null) {
        throw Exception(getFriendlyError());
      }

      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'username': userData['username'],
        'phone': userData['phone'],
      });
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithOTP(String email) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: _getRedirectUrl(),
        shouldCreateUser: false,
      );
    } catch (e) {
      _errorMessage = getFriendlyError();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String _getRedirectUrl() {
    return const bool.fromEnvironment('dart.vm.product')
        ? 'alquranapp://auth-callback'
        : 'io.supabase.flutterquickstart://login-callback';
  }

  Future<Map<String, dynamic>> getProfile(String userId) async {
    _setLoading(true);
    try {
      // Coba ambil data profile
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Tambahkan email dari auth user
      response['email'] = _supabase.auth.currentUser?.email ?? '-';
      return response;
    } on PostgrestException catch (e) {
      // Jika profile tidak ditemukan, buat yang baru
      if (e.code == 'PGRST116') {
        // Error code untuk data tidak ditemukan
        final newProfile = {
          'id': userId,
          'username': 'User',
          'phone': '',
          'email': _supabase.auth.currentUser?.email ?? '-',
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('profiles').upsert(newProfile);
        return newProfile;
      }
      throw Exception('Failed to get profile: ${e.message}');
    } catch (e) {
      debugPrint('Error getting profile: $e');
      throw Exception('Failed to get profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  String getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        return 'Email atau password salah. Silakan coba lagi.';
      } else if (error.message.toLowerCase().contains('email not confirmed')) {
        return 'Email belum diverifikasi. Cek email Anda untuk link verifikasi.';
      }
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
