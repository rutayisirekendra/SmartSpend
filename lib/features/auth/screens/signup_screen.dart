import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
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
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('You must agree to the terms and conditions.'),
            ],
          ),
          backgroundColor: AppTheme.getErrorColor(context),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kDebugMode) {
        print('🔐 Starting signup process...');
        print('   Email: ${_emailController.text.trim()}');
      }
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );

      if (mounted && userCredential != null) {
        if (kDebugMode) {
          print('✅ Signup successful!');
        }
        
        // Sign out the user immediately after signup
        await authService.signOut();
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Account created successfully! Please log in to continue.'),
                  ),
                ],
              ),
              backgroundColor: AppTheme.getSuccessColor(context),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );

          // Wait a moment for the user to see the success message
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Switch to login screen
          widget.onSwitchToLogin();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Signup error: $e');
      }
      
      if (mounted) {
        // Extract clean error message
        String errorMessage = e.toString();
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getErrorColor(context),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _signUp,
            ),
          ),
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
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                        size: 60, color: AppTheme.getHeaderPrimaryColor(context)),
                    const SizedBox(height: 16),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primaryTeal,
                          AppTheme.getSuccessColor(context),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'SmartSpend',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Text(
                      'Your personal finance co-pilot',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
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
                      Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions',
                          style: TextStyle(
                            color: AppTheme.getHeaderTextColor(context),
                          ),
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
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _agreedToTerms 
                              ? [AppTheme.accentOrange, const Color(0xFFFF8A50)]
                              : [Colors.grey.shade400, Colors.grey.shade500],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _agreedToTerms ? [
                          BoxShadow(
                            color: AppTheme.accentOrange.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ] : [],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading || !_agreedToTerms ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.transparent,
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}

