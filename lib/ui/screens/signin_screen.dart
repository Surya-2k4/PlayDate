import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/utils/theme/app_theme.dart';
import '../../../logic/auth_provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
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
    _floatingController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signInWithEmail(email, password);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
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

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.sendPasswordReset(email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Password Reset'),
            content: Text('A password reset link has been sent to $email'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                const SizedBox(height: 20),
                // Illustration (Hot air balloon placeholder using icons)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Clouds
                      Positioned(
                        top: 20,
                        left: 40,
                        child: Icon(
                          Icons.cloud,
                          color: Colors.white.withOpacity(0.8),
                          size: 40,
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 60,
                        child: Icon(
                          Icons.cloud,
                          color: Colors.white.withOpacity(0.8),
                          size: 30,
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 80,
                        child: Icon(
                          Icons.cloud,
                          color: Colors.white.withOpacity(0.8),
                          size: 50,
                        ),
                      ),

                      // The "Balloon"
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 100,
                            color: AppTheme.primaryPink,
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sign In',
                            style: AppTheme.lightTheme.textTheme.displayMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Email',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'example@email.com',
                          prefixIcon: const Icon(Icons.email_outlined),
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
                        decoration: InputDecoration(
                          hintText: '*********',
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: _rememberMe,
                                onChanged: (val) =>
                                    setState(() => _rememberMe = val),
                                activeColor: AppTheme.primaryPink,
                              ),
                              Text(
                                'Remember',
                                style: AppTheme.lightTheme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: _handleForgotPassword,
                            child: const Text(
                              'Forgot password',
                              style: TextStyle(color: AppTheme.primaryPink),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSignIn,
                          child: const Text('Sign In'),
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
                            'Sign in with Google',
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
                              'Don\'t have an account? ',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignUpScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Register',
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
