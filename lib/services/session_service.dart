import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user session data and app state
class SessionService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userEmailKey = 'user_email';
  static const String _lastLoginDateKey = 'last_login_date';
  static const String _currentStreakKey = 'current_streak';
  static const String _userDisplayNameKey = 'user_display_name';

  /// Save user session data
  static Future<void> saveUserSession({
    required String email,
    String? displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userEmailKey, email);
    if (displayName != null) {
      await prefs.setString(_userDisplayNameKey, displayName);
    }
    
    // Update login streak
    await _updateLoginStreak(prefs);
  }

  /// Clear user session data
  static Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_isLoggedInKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userDisplayNameKey);
    await prefs.remove(_lastLoginDateKey);
    await prefs.remove(_currentStreakKey);
  }

  /// Check if user is logged in locally
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Get stored user email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Get stored user display name
  static Future<String?> getUserDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDisplayNameKey);
  }

  /// Update login streak
  static Future<void> _updateLoginStreak(SharedPreferences prefs) async {
    final currentDate = DateTime.now();
    final today = DateTime(currentDate.year, currentDate.month, currentDate.day);
    
    final lastLoginString = prefs.getString(_lastLoginDateKey);
    
    // If first time user, initialize with streak of 1
    if (lastLoginString == null) {
      await prefs.setString(_lastLoginDateKey, today.toIso8601String());
      await prefs.setInt(_currentStreakKey, 1);
      return;
    }

    final lastLogin = DateTime.parse(lastLoginString);
    final lastLoginDate = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

    // Check if already logged in today
    if (lastLoginDate.isAtSameMomentAs(today)) {
      return; // No change needed
    }

    // Check if consecutive day (yesterday)
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastLoginDate.isAtSameMomentAs(yesterday)) {
      // Consecutive day - increment streak
      final currentStreak = prefs.getInt(_currentStreakKey) ?? 1;
      await prefs.setInt(_currentStreakKey, currentStreak + 1);
    } else {
      // Streak broken - reset to 1
      await prefs.setInt(_currentStreakKey, 1);
    }
    
    await prefs.setString(_lastLoginDateKey, today.toIso8601String());
  }

  /// Get current login streak
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStreakKey) ?? 0;
  }

  /// Force clear all app data (for debugging or data reset)
  static Future<void> clearAllAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
