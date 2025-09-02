import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleSignInService {
  static GoogleSignIn? _googleSignIn;
  static SupabaseClient? _supabase;

  static Future<void> initialize() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );
      _supabase = Supabase.instance.client;
      print('GoogleSignInService initialized successfully');
    } catch (e) {
      print('Error initializing GoogleSignInService: $e');
    }
  }

  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      if (_googleSignIn == null) {
        throw Exception('GoogleSignInService not initialized');
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // Sign in with Supabase using Google credentials
      final AuthResponse response = await _supabase!.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken!,
      );

      if (response.user != null) {
        print('Successfully signed in with Google: ${response.user!.email}');
        return {
          'user': response.user,
          'session': response.session,
          'googleUser': googleUser,
        };
      } else {
        throw Exception('Failed to authenticate with Supabase');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
      await _supabase?.auth.signOut();
      print('Successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      final session = _supabase?.auth.currentSession;
      return session != null;
    } catch (e) {
      print('Error checking sign-in status: $e');
      return false;
    }
  }

  static User? getCurrentUser() {
    return _supabase?.auth.currentUser;
  }
}
