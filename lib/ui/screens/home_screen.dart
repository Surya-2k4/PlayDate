import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playdate/ui/screens/signin_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constants/utils/theme/app_theme.dart';
import '../../logic/room_provider.dart';
import '../../logic/player_provider.dart';
import '../../logic/chat_provider.dart';
import '../../logic/auth_provider.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _floatingController;

  void _handleLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return;
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showNameDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("What's your name?", textAlign: TextAlign.center),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Enter your name",
            filled: true,
            fillColor: AppTheme.darkBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  context.read<AuthProvider>().setUserName(
                    _nameController.text.trim(),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Save & Start",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().userName == null) {
        _showNameDialog();
      }
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  String _generateRoomId() {
    final r = Random();
    return List.generate(6, (_) => r.nextInt(10)).join();
  }

  void _createRoom() async {
    final userName = context.read<AuthProvider>().userName;
    if (userName == null || userName.isEmpty) {
      _showNameDialog();
      return;
    }

    final roomId = _generateRoomId();
    await context.read<RoomProvider>().createRoom(
      roomId,
      context.read<PlayerProvider>(),
      context.read<ChatProvider>(),
    );
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoomScreen()),
    );
  }

  void _showJoinDialog() {
    final userName = context.read<AuthProvider>().userName;
    if (userName == null || userName.isEmpty) {
      _showNameDialog();
      return;
    }

    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Join Room", textAlign: TextAlign.center),
        content: TextField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter 6-digit code",
            filled: true,
            fillColor: AppTheme.darkBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textAlign: TextAlign.center,
          maxLength: 6,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (codeController.text.length == 6) {
                      await context.read<RoomProvider>().joinRoom(
                        codeController.text,
                        context.read<PlayerProvider>(),
                        context.read<ChatProvider>(),
                      );
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoomScreen()),
                      );
                    }
                  },
                  child: const Text(
                    "Join",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().userName ?? "Love";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppTheme.primaryPink),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.lightPink, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating background hearts
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
                        child: Icon(
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
                        child: Icon(
                          Icons.favorite,
                          size: 80,
                          color: AppTheme.primaryPink,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Animated Heart with Glow
                      _buildMainHeart(),
                      const SizedBox(height: 30),

                      // Welcome Text
                      Text(
                        "Hello, $userName! ❤️",
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppTheme.textBlack,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "PlayDate",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: AppTheme.primaryPink,
                              fontFamily:
                                  'Pacifico', // Use the script font for romance
                              fontSize: 48,
                              letterSpacing: 1.2,
                            ),
                      ),

                      const SizedBox(height: 20),
                      // Romantic Status Card
                      _buildLoversCard(),

                      const SizedBox(height: 50),
                      // Action Buttons with staggered entrance
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Column(
                                children: [
                                  _buildHomeButton(
                                    label: "Create a Love Nest",
                                    icon: Icons.favorite_border,
                                    onPressed: _createRoom,
                                    isPrimary: true,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildHomeButton(
                                    label: "Join Your Partner",
                                    icon: Icons.people_outline,
                                    onPressed: () => _showJoinDialog(),
                                    isPrimary: false,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),
                      // Daily Love Quote (Optional but eye-catchy)
                      _buildQuoteSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainHeart() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryPink.withOpacity(0.2 * value),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: const Icon(
              Icons.favorite,
              size: 140,
              color: AppTheme.primaryPink,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoversCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightPink,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: AppTheme.primaryPink),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Together is a beautiful place to be",
                  style: TextStyle(
                    color: AppTheme.primaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Start watching together now",
                  style: TextStyle(
                    color: const Color.fromARGB(255, 69, 68, 68),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteSection() {
    return Opacity(
      opacity: 0.8,
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: AppTheme.primaryPink),
          const SizedBox(height: 10),
          Text(
            "\"Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.\"",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textGrey,
              fontStyle: FontStyle.italic,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.primaryPink.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppTheme.primaryPink : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppTheme.primaryPink,
          side: const BorderSide(color: AppTheme.primaryPink, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
