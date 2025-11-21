import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'package:smart_expense_tracker/services/session_service.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

/// Debug widget to show authentication status
/// This can be useful for testing and debugging auth flow
class AuthStatusDebugWidget extends StatefulWidget {
  const AuthStatusDebugWidget({super.key});

  @override
  State<AuthStatusDebugWidget> createState() => _AuthStatusDebugWidgetState();
}

class _AuthStatusDebugWidgetState extends State<AuthStatusDebugWidget> {
  String _sessionStatus = 'Loading...';
  String _firebaseStatus = 'Loading...';

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    final authService = context.read<AuthService>();
    final isLoggedIn = await SessionService.isLoggedIn();
    final userEmail = await SessionService.getUserEmail();
    final userDisplayName = await SessionService.getUserDisplayName();
    final currentStreak = await SessionService.getCurrentStreak();

    setState(() {
      _sessionStatus = '''
Local Session: ${isLoggedIn ? 'Logged In' : 'Logged Out'}
Email: ${userEmail ?? 'None'}
Name: ${userDisplayName ?? 'None'}
Streak: $currentStreak days
''';

      _firebaseStatus = '''
Firebase User: ${authService.currentUser?.email ?? 'None'}
Display Name: ${authService.currentUser?.displayName ?? 'None'}
UID: ${authService.currentUser?.uid ?? 'None'}
Authenticated: ${authService.isAuthenticated}
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: AppTheme.getPrimaryColor(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Auth Debug Info',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _updateStatus,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Session Service:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Text(
            _sessionStatus,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Firebase Auth:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          Text(
            _firebaseStatus,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await SessionService.clearUserSession();
                    _updateStatus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Session data cleared')),
                    );
                  },
                  child: const Text('Clear Session'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await context.read<AuthService>().signOut();
                      _updateStatus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Signed out')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
