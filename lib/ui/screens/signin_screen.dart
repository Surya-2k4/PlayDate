import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/utils/theme/app_theme.dart';
import '../../../logic/auth_provider.dart';
import '../../../logic/theme_provider.dart';
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
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isLove = themeProvider.isLoveTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [theme.primaryColor.withOpacity(0.12), Colors.white],
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
                      child: Icon(
                        isLove
                            ? Icons.favorite
                            : Icons.sentiment_very_satisfied,
                        size: 250,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30 + (_floatingController.value * 30),
                    left: -40 - (_floatingController.value * 10),
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        isLove ? Icons.favorite : Icons.mood,
                        size: 200,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100 - (_floatingController.value * 15),
                    left: 40 + (_floatingController.value * 5),
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(
                        isLove ? Icons.favorite : Icons.auto_awesome,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 200 + (_floatingController.value * 20),
                    right: 20,
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(
                        isLove ? Icons.favorite : Icons.celebration,
                        size: 100,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Modern Theme Toggle
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: () => themeProvider.toggleTheme(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 75,
                height: 36,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.3),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 400),
                      alignment: isLove
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isLove ? Icons.favorite : Icons.people,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Align(
                      alignment: isLove
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          isLove ? Icons.people : Icons.favorite,
                          size: 14,
                          color: theme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    Icon(
                      isLove ? Icons.favorite : Icons.sentiment_very_satisfied,
                      color: theme.primaryColor,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PlayDate',
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        color: theme.primaryColor,
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
                          Icon(
                            isLove ? Icons.favorite : Icons.movie_outlined,
                            size: 100,
                            color: theme.primaryColor,
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isLove
                                  ? Colors.orange.shade300
                                  : theme.colorScheme.secondary,
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
                            child: Text(
                              'Forgot password',
                              style: TextStyle(color: theme.primaryColor),
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
                              child: Text(
                                'Register',
                                style: TextStyle(
                                  color: theme.primaryColor,
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
