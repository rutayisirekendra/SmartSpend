import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/auth/widgets/auth_form_field.dart';
import 'package:smart_expense_tracker/features/auth/widgets/auth_toggle_switch.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSwitchToLogin;
  const SignUpScreen({super.key, required this.onSwitchToLogin});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _agreedToTerms = false;

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must agree to the terms and conditions.'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
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
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
            height: MediaQuery.of(context).size.height * 0.95,
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
                    isLogin: false,
                    onLoginTapped: widget.onSwitchToLogin,
                    onSignUpTapped: () {},
                  ),
                  const SizedBox(height: 24),

                  AuthFormField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    iconData: Icons.person_outline,
                    validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Please enter your full name' : null,
                  ),
                  const SizedBox(height: 16),

                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
                    iconData: Icons.email_outlined,
                    validator: (value) =>
                    (value?.isEmpty ?? true) ? 'Please enter an email' : null,
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
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    iconData: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AppTheme.primaryTeal,
                      ),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(color: AppTheme.darkGrey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _isLoading
                      ? const CircularProgressIndicator(
                      color: AppTheme.accentOrange)
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading || !_agreedToTerms ? null : _signUp,
                      child: const Text('SIGN UP'),
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

