import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playdate/ui/screens/signin_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constants/utils/theme/app_theme.dart';
import '../../logic/room_provider.dart';
import '../../logic/player_provider.dart';
import '../../logic/chat_provider.dart';
import '../../logic/auth_provider.dart';
import '../../logic/theme_provider.dart';
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
    final theme = Theme.of(context);
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
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
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
    final theme = Theme.of(context);
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
                backgroundColor: theme.primaryColor,
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

    try {
      final roomId = _generateRoomId();
      await context.read<RoomProvider>().createRoom(
        roomId,
        context.read<PlayerProvider>(),
        context.read<ChatProvider>(),
        context.read<ThemeProvider>().themeType,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoomScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to create room: ${e.toString()}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showJoinDialog() {
    final userName = context.read<AuthProvider>().userName;
    if (userName == null || userName.isEmpty) {
      _showNameDialog();
      return;
    }

    final theme = Theme.of(context);
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
                    backgroundColor: theme.primaryColor,
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
    final userName = context.watch<AuthProvider>().userName ?? "Mate";
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final isLove = themeProvider.isLoveTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Center(
            child: GestureDetector(
              onTap: () => themeProvider.toggleTheme(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: 75,
                height: 36,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
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
                              color: theme.primaryColor.withValues(alpha: 0.4),
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
                          color: theme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: theme.primaryColor),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primaryColor.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Decorative floating background icons
            AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final icon = isLove
                    ? Icons.favorite
                    : Icons.sentiment_very_satisfied;
                return Stack(
                  children: [
                    Positioned(
                      top: -50 + (_floatingController.value * 40),
                      right: -50 + (_floatingController.value * 40),
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(icon, size: 250, color: theme.primaryColor),
                      ),
                    ),
                    Positioned(
                      bottom: -30 + (_floatingController.value * 30),
                      left: -40 - (_floatingController.value * 10),
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(icon, size: 200, color: theme.primaryColor),
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
                      _buildMainIcon(isLove, theme.primaryColor),
                      const SizedBox(height: 30),

                      Text(
                        "Hello, $userName! ${isLove ? "❤️" : "👋"}",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "PlayDate",
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.primaryColor,
                          fontFamily: 'Pacifico',
                          fontSize: 48,
                          letterSpacing: 1.2,
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildInfoCard(isLove, theme.primaryColor),

                      const SizedBox(height: 50),
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
                                    label: isLove
                                        ? "Create a Love Nest"
                                        : "Create a Fun Room",
                                    icon: isLove
                                        ? Icons.favorite_border
                                        : Icons.add_circle_outline,
                                    onPressed: _createRoom,
                                    isPrimary: true,
                                    themeColor: theme.primaryColor,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildHomeButton(
                                    label: isLove
                                        ? "Join Your Partner"
                                        : "Join Your Friend",
                                    icon: Icons.people_outline,
                                    onPressed: () => _showJoinDialog(),
                                    isPrimary: false,
                                    themeColor: theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),
                      _buildQuoteSection(isLove, theme.primaryColor),
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

  Widget _buildMainIcon(bool isLove, Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2 * value),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Transform.scale(
            scale: 0.9 + (value * 0.1),
            child: Icon(
              isLove ? Icons.favorite : Icons.sentiment_very_satisfied,
              size: 140,
              color: color,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(bool isLove, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLove
                      ? "Together is a beautiful place to be"
                      : "Friends make everything better",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isLove
                      ? "Start watching together now"
                      : "Connect and watch movies",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 69, 68, 68),
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

  Widget _buildQuoteSection(bool isLove, Color color) {
    return Opacity(
      opacity: 0.8,
      child: Column(
        children: [
          Icon(Icons.format_quote, color: color),
          const SizedBox(height: 10),
          Text(
            isLove
                ? "\"Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.\""
                : "\"True friendship comes when the silence between two people is comfortable.\"",
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    required Color themeColor,
  }) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? themeColor : Colors.white,
          foregroundColor: isPrimary ? Colors.white : themeColor,
          side: BorderSide(color: themeColor, width: 2),
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
