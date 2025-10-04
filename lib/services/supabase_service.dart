import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tracker_app/logger.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  final logger = getLogger(className: "SupabaseService");

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://psblxphtjqyymlexuydi.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBzYmx4cGh0anF5eW1sZXh1eWRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg5MjU3NzcsImV4cCI6MjA3NDUwMTc3N30.JP8_bgmTvjO4_nqDSDddSfTtSmm45AxvK2zleuEgh10',
    );
  }

  /// Get current user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated {
    try {
      return currentUser != null;
    } catch (e) {
      // Supabase not initialized yet
      return false;
    }
  }

  /// Send OTP code for passwordless sign in
  Future<void> sendOtpCode(String email) async {
    try {
      // Method 1: Try without emailRedirectTo (should send OTP if template is configured)
      await client.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
      );
      logger.i('OTP code sent to $email');
    } catch (e) {
      logger.e('Failed to send OTP code: $e');
      rethrow;
    }
  }

  /// Verify OTP code and sign in user
  Future<AuthResponse> verifyOtpCode(String email, String otpCode) async {
    try {
      final response = await client.auth.verifyOTP(
        type: OtpType.email,
        token: otpCode,
        email: email,
      );
      logger.i('User signed in with OTP successfully');
      return response;
    } catch (e) {
      logger.e('OTP verification failed: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      logger.i('User signed out successfully');
    } catch (e) {
      logger.e('Sign out failed: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteUserAccount() async {
    try {
      if (!isAuthenticated) {
        throw Exception('No user is currently signed in');
      }

      // Delete user account using the admin API
      // Note: This requires the service role key, not the anon key
      // For production, this should be handled server-side
      await client.auth.admin.deleteUser(currentUser!.id);
      logger.i('User account deleted successfully');
    } catch (e) {
      logger.e('Account deletion failed: $e');
      // If admin deletion fails, fall back to signing out and clearing local data
      logger.w('Falling back to sign out and local data clearing');
      await client.auth.signOut();
      rethrow;
    }
  }

  /// Get current user email
  String? get currentUserEmail => currentUser?.email;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
