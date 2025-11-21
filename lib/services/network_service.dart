import 'dart:io';
import 'package:flutter/foundation.dart';

/// Service to check network connectivity and Firebase reachability
class NetworkService {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Network connectivity check failed: $e');
      }
      return false;
    }
  }

  /// Check if Firebase services are reachable
  static Future<bool> canReachFirebase() async {
    try {
      final result = await InternetAddress.lookup('firebase.google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase connectivity check failed: $e');
      }
      return false;
    }
  }

  /// Perform comprehensive network check
  static Future<NetworkStatus> checkNetworkStatus() async {
    try {
      // Check general internet connectivity
      final hasInternet = await hasInternetConnection();
      if (!hasInternet) {
        return NetworkStatus.noInternet;
      }

      // Check Firebase connectivity
      final canReachFB = await canReachFirebase();
      if (!canReachFB) {
        return NetworkStatus.firebaseUnreachable;
      }

      return NetworkStatus.connected;
    } catch (e) {
      if (kDebugMode) {
        print('Network status check error: $e');
      }
      return NetworkStatus.unknown;
    }
  }

  /// Get user-friendly network status message
  static String getNetworkStatusMessage(NetworkStatus status) {
    switch (status) {
      case NetworkStatus.connected:
        return 'Connected';
      case NetworkStatus.noInternet:
        return 'No internet connection. Please check your network settings.';
      case NetworkStatus.firebaseUnreachable:
        return 'Cannot reach Firebase services. Please try again later.';
      case NetworkStatus.unknown:
        return 'Network status unknown. Please check your connection.';
    }
  }
}

enum NetworkStatus {
  connected,
  noInternet,
  firebaseUnreachable,
  unknown,
}
