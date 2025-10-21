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
        // If the connection is still waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If a user is logged in (snapshot has data)
        if (snapshot.hasData) {
          // Show the MainScreen which contains the bottom navigation
          return const MainScreen();
        }

        // If no user is logged in
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
