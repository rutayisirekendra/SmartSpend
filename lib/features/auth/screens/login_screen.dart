import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/auth/widgets/auth_form_field.dart';
import 'package:smart_expense_tracker/features/auth/widgets/auth_toggle_switch.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSwitchToSignUp;
  const LoginScreen({super.key, required this.onSwitchToSignUp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Icon(Icons.wallet_outlined,
                      size: 60, color: AppTheme.primaryTeal),
                  const SizedBox(height: 16),
                  Text(
                    'SmartSpend',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Your personal finance co-pilot',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),

                  AuthToggleSwitch(
                    isLogin: true,
                    onLoginTapped: () {},
                    onSignUpTapped: widget.onSwitchToSignUp,
                  ),
                  const SizedBox(height: 32),

                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    iconData: Icons.email_outlined,
                    validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    iconData: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Password must be at least 6 characters'
                        : null,
                  ),
                  const SizedBox(height: 8),

                  // FIX: Added "Forgot Password?" link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password logic
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _isLoading
                      ? const CircularProgressIndicator(
                      color: AppTheme.accentOrange)
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      child: const Text('LOGIN'),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

