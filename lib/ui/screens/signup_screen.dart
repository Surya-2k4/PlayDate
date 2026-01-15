import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/utils/theme/app_theme.dart';
import '../../../logic/auth_provider.dart';

import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }
    if (password.isEmpty || password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signUpWithEmail(email, password);
      if (mounted) Navigator.pop(context); // Go back to sign in
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed: ${e.toString()}')),
        );
      }
    }
  }

  void _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signInWithGoogle();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        if (errorMessage.contains('12500')) {
          errorMessage =
              "Configuration Error: Please ensure you have added the SHA-1 fingerprint and Support Email in Firebase Console.";
        } else if (errorMessage.contains('sign_in_canceled')) {
          errorMessage = "Sign in was canceled.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign in failed: $errorMessage'),
            backgroundColor: AppTheme.primaryPink,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.lightPink, Colors.white],
              ),
            ),
          ),

          // Floating Background Hearts
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -50 + (_floatingController.value * 40),
                    right: -50 + (_floatingController.value * 40),
                    child: Opacity(
                      opacity: 0.1,
                      child: const Icon(
                        Icons.favorite,
                        size: 250,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30 + (_floatingController.value * 30),
                    left: -40 - (_floatingController.value * 10),
                    child: Opacity(
                      opacity: 0.1,
                      child: const Icon(
                        Icons.favorite,
                        size: 200,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100 - (_floatingController.value * 15),
                    left: 40 + (_floatingController.value * 5),
                    child: Opacity(
                      opacity: 0.05,
                      child: const Icon(
                        Icons.favorite,
                        size: 80,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 200 + (_floatingController.value * 20),
                    right: 20,
                    child: Opacity(
                      opacity: 0.05,
                      child: const Icon(
                        Icons.favorite,
                        size: 100,
                        color: AppTheme.primaryPink,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: AppTheme.primaryPink,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PlayDate',
                      style: AppTheme.lightTheme.textTheme.displayLarge
                          ?.copyWith(
                            fontSize: 24,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.primaryPink,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Content Container
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Account',
                        style: AppTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Email',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Password',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '*********',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Confirm Password',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: '*********',
                          prefixIcon: Icon(Icons.lock_reset),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSignUp,
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Google Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleGoogleSignIn,
                          icon: Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                            height: 24,
                          ),
                          label: const Text(
                            'Sign up with Google',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
