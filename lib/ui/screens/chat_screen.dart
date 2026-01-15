import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' as math;
import '../../logic/chat_provider.dart';
import '../../logic/auth_provider.dart';
import '../../core/constants/utils/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _hearts = [];
  int _lastProcessedTimestamp = 0;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userName = context.read<AuthProvider>().userName ?? "Anonymous";

    context.read<ChatProvider>().sendMessage(
      sender: userName,
      senderId: userName, // Using name as ID for simplicity
      text: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendReaction() {
    final userName = context.read<AuthProvider>().userName ?? "Anonymous";
    context.read<ChatProvider>().sendLoveReaction(userName);
    _showHeartAnimation();
  }

  void _showHeartAnimation() {
    if (!mounted) return;
    setState(() {
      _hearts.add(const HeartBurst());
    });
    // Remove after animation completes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _hearts.isNotEmpty) {
        setState(() {
          _hearts.removeAt(0);
        });
      }
    });
  }

  void _scrollToBottom() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildQuickReaction(String emoji) {
    return GestureDetector(
      onTap: () {
        final userName = context.read<AuthProvider>().userName ?? "Anonymous";
        context.read<ChatProvider>().sendMessage(
          sender: userName,
          senderId: userName,
          text: emoji,
        );
        _scrollToBottom();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.lightPink),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPink.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUserName = context.watch<AuthProvider>().userName;

    return Stack(
      children: [
        // Attractive Background
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(
                      AppTheme.lightPink.withOpacity(0.4),
                      AppTheme.lightPink.withOpacity(0.6),
                      _bgController.value,
                    )!,
                    Colors.white,
                    Color.lerp(
                      AppTheme.lightPink.withOpacity(0.2),
                      AppTheme.lightPink.withOpacity(0.4),
                      _bgController.value,
                    )!,
                  ],
                ),
              ),
            );
          },
        ),

        // Faint Decorative Background Icons
        AnimatedBuilder(
          animation: _bgController,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: 100 + (_bgController.value * 30),
                  right: -30 - (_bgController.value * 20),
                  child: Icon(
                    Icons.favorite,
                    size: 200,
                    color: AppTheme.primaryPink.withOpacity(0.04),
                  ),
                ),
                Positioned(
                  bottom: 150 - (_bgController.value * 40),
                  left: -50 + (_bgController.value * 20),
                  child: Icon(
                    Icons.favorite,
                    size: 250,
                    color: AppTheme.primaryPink.withOpacity(0.04),
                  ),
                ),
                Positioned(
                  top: 300 - (_bgController.value * 50),
                  left: 150 + (_bgController.value * 40),
                  child: Icon(
                    Icons.favorite,
                    size: 100,
                    color: AppTheme.primaryPink.withOpacity(0.03),
                  ),
                ),
              ],
            );
          },
        ),

        Column(
          children: [
            // Chat Messages
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: StreamBuilder<DatabaseEvent>(
                  stream: chatProvider.messageStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data?.snapshot.value == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message_outlined,
                              size: 60,
                              color: AppTheme.primaryPink.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Share your feelings...",
                              style: GoogleFonts.poppins(
                                color: AppTheme.textGrey.withOpacity(0.5),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final messagesData = Map<dynamic, dynamic>.from(
                      snapshot.data!.snapshot.value as Map,
                    );
                    final messages = messagesData.entries.toList()
                      ..sort((a, b) {
                        final aTime = (a.value['timestamp'] ?? 0) as int;
                        final bTime = (b.value['timestamp'] ?? 0) as int;
                        return bTime.compareTo(aTime);
                      });

                    // Trigger animation for new reaction messages from partner
                    if (messages.isNotEmpty) {
                      final latest = Map<String, dynamic>.from(
                        messages.first.value,
                      );
                      final timestamp = (latest['timestamp'] ?? 0) as int;

                      if (latest['type'] == 'reaction' &&
                          latest['sender'] != currentUserName &&
                          timestamp > _lastProcessedTimestamp) {
                        _lastProcessedTimestamp = timestamp;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _showHeartAnimation();
                        });
                      }
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = Map<String, dynamic>.from(
                          messages[index].value,
                        );
                        final sender = message['sender'] ?? 'Unknown';
                        final text = message['text'] ?? '';
                        final timestamp = message['timestamp'] as int?;
                        final bool isMe = sender == currentUserName;
                        final bool isReaction = message['type'] == 'reaction';
                        String timeStr = "";
                        if (timestamp != null) {
                          final date = DateTime.fromMillisecondsSinceEpoch(
                            timestamp,
                          );
                          timeStr = DateFormat('HH:mm').format(date);
                        }

                        if (isReaction) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightPink.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$sender sent a ❤️",
                                style: const TextStyle(
                                  color: AppTheme.primaryPink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }

                        return ChatBubble(
                          sender: sender,
                          message: text,
                          isMe: isMe,
                          time: timeStr,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPink.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Quick Reactions Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickReaction("❤️"),
                        _buildQuickReaction("😍"),
                        _buildQuickReaction("😘"),
                        _buildQuickReaction("🥰"),
                        _buildQuickReaction("🌹"),
                        _buildQuickReaction("🍿"),
                        _buildQuickReaction("🔥"),
                        _buildQuickReaction("😲"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _sendReaction,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.lightPink,
                            shape: BoxShape.circle,
                          ),
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0.9, end: 1.1),
                            duration: const Duration(seconds: 1),
                            builder: (context, double value, child) {
                              return Transform.scale(
                                scale: value,
                                child: const Icon(
                                  Icons.favorite,
                                  color: AppTheme.primaryPink,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: AppTheme.textBlack),
                          decoration: InputDecoration(
                            hintText: "Type a sweet message...",
                            hintStyle: const TextStyle(
                              color: AppTheme.textGrey,
                            ),
                            filled: true,
                            fillColor: AppTheme.softGrey,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // Overlaid hearts
        ..._hearts,
      ],
    );
  }
}

class HeartBurst extends StatefulWidget {
  const HeartBurst({super.key});

  @override
  State<HeartBurst> createState() => _HeartBurstState();
}

class _HeartBurstState extends State<HeartBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Point> _points = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000), // Slower animation
    );

    final random = math.Random();
    // 6 big hearts flying towards Top, Left, and Right
    for (int i = 0; i < 6; i++) {
      // Restrict direction to Top, Left, and Right (PI to 2*PI)
      double direction = math.pi + (random.nextDouble() * math.pi);
      // Distance multiplier
      double distance = 400 + random.nextDouble() * 400;

      _points.add(
        Point(
          x: math.cos(direction) * distance,
          y: math.sin(direction) * distance,
          size: 100 + random.nextDouble() * 120,
          angle: random.nextDouble() * math.pi * 2,
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _points.map((p) {
            final progress = _controller.value;

            // Curved movement using an ease-out curve for the distance
            final curvedProgress = Curves.easeOutCubic.transform(progress);

            final xOffset = p.x * curvedProgress;
            final yOffset = p.y * curvedProgress;

            final opacity = (1 - progress).clamp(0.0, 1.0);

            // Pulsing scale that grows and then shrinks slightly at the end
            final scale = 0.5 + (math.sin(progress * math.pi) * 0.8);

            return Positioned(
              left: centerX + xOffset - (p.size / 2),
              top: centerY + yOffset - (p.size / 2),
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: p.angle + (progress * 3), // Faster rotation
                  child: Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.favorite,
                      color: AppTheme.primaryPink.withOpacity(0.85),
                      size: p.size,
                      shadows: [
                        const Shadow(color: Colors.white, blurRadius: 20),
                        Shadow(
                          color: AppTheme.primaryPink.withOpacity(0.6),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class Point {
  final double x;
  final double y;
  final double size;
  final double angle;
  Point({
    required this.x,
    required this.y,
    required this.size,
    required this.angle,
  });
}
