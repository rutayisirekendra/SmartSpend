import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/features/auth/screens/login_screen.dart';
import 'package:smart_expense_tracker/features/auth/screens/signup_screen.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

/// This widget is the main gatekeeper of the app.
/// It listens to the authentication state and shows the appropriate screen.
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the AuthService from the Provider
    final authService = context.watch<AuthService>();

    // Use a StreamBuilder to listen to authentication state changes
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading screen while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading SmartSpend...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle connection errors
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app or check your connection',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to refresh the auth state
                      authService.reloadUser();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // If a user is logged in (snapshot has data and user is not null)
        if (snapshot.hasData && snapshot.data != null) {
          // Show the MainScreen which contains the bottom navigation
          return const MainScreen();
        }

        // If no user is logged in or user is null
        return const AuthPage(); // Show the Login/SignUp page flipper
      },
    );
  }
}

/// This widget will manage showing the Login or Sign Up screen.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showLoginPage = true;

  void _toggleScreens() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoginPage) {
      return LoginScreen(onSwitchToSignUp: _toggleScreens);
    } else {
      return SignUpScreen(onSwitchToLogin: _toggleScreens);
    }
  }
}
