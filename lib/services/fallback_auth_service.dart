import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fallback authentication service for when Firebase is unavailable
/// This is for testing purposes only and should be removed in production
class FallbackAuthService {
  static const String _isLoggedInKey = 'fallback_is_logged_in';
  static const String _emailKey = 'fallback_email';
  static const String _nameKey = 'fallback_name';

  /// Create a test account (for development only)
  static Future<bool> createTestAccount(String email, String password, String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store test user data
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_nameKey, name);
      
      if (kDebugMode) {
        print('Test account created: $email');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to create test account: $e');
      }
      return false;
    }
  }

  /// Check if test user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get test user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_emailKey),
      'name': prefs.getString(_nameKey),
    };
  }

  /// Sign out test user
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    
    if (kDebugMode) {
      print('Test user signed out');
    }
  }

  /// Clear all test data
  static Future<void> clearTestData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
