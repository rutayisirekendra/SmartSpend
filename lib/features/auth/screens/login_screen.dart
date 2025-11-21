import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
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

    try {
      if (kDebugMode) {
        print('🔐 Starting login process...');
        print('   Email: ${_emailController.text.trim()}');
      }
      
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted && userCredential != null) {
        if (kDebugMode) {
          print('✅ Login successful!');
        }
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Welcome back!'),
              ],
            ),
            backgroundColor: AppTheme.getSuccessColor(context),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // User is automatically logged in
        // The AuthChecker will automatically navigate to MainScreen
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
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
              onPressed: _login,
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
    _emailController.dispose();
    _passwordController.dispose();
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
              height: MediaQuery.of(context).size.height * 0.9,
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
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppTheme.primaryTeal,
                          const Color(0xFF4CAF50), // Bright green
                          AppTheme.getSuccessColor(context),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
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
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accentOrange, Color(0xFFFF8A50)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentOrange.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'LOGIN',
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

