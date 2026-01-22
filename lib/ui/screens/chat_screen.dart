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

import 'package:playdate/logic/theme_provider.dart';

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
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isTyping = _messageController.text.isNotEmpty;
    if (_isTyping != isTyping) {
      _isTyping = isTyping;
      final authProvider = context.read<AuthProvider>();
      final userName = authProvider.userName ?? "Anonymous";
      final userId = authProvider.user?.uid ?? userName;
      context.read<ChatProvider>().setTyping(userId, isTyping);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.userName ?? "Anonymous";
    final userId = authProvider.user?.uid ?? userName;

    context.read<ChatProvider>().sendMessage(
      sender: userName,
      senderId: userId,
      text: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendSticker(String emoji) {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.userName ?? "Anonymous";
    final userId = authProvider.user?.uid ?? userName;
    context.read<ChatProvider>().sendMessage(
      sender: userName,
      senderId: userId,
      text: emoji,
      type: 'sticker',
    );
    _scrollToBottom();
  }

  void _sendReaction() {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.userName ?? "Anonymous";
    final userId = authProvider.user?.uid ?? userName;
    context.read<ChatProvider>().sendLoveReaction(userName, userId);
    _showHeartAnimation();
  }

  void _showHeartAnimation() {
    if (!mounted) return;
    setState(() {
      _hearts.add(const HeartBurst());
    });
    Future.delayed(const Duration(seconds: 4), () {
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

  void _showStickerPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: DefaultTabController(
            length: 6,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: "Recent"),
                    Tab(text: "Funny"),
                    Tab(text: "Animals"),
                    Tab(text: "Food"),
                    Tab(text: "Love"),
                    Tab(text: "Fun"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildStickerGrid(controller, [
                        '🎉',
                        '😂',
                        '🤣',
                        '🥺',
                        '😍',
                        '✨',
                        '🔥',
                        '💖',
                        '🚀',
                        '�',
                        '⭐',
                        '🌈',
                        '🍭',
                        '🧸',
                        '👻',
                        '💀',
                      ]),
                      _buildStickerGrid(controller, [
                        '🤡',
                        '💩',
                        '🤪',
                        '👺',
                        '👻',
                        '💀',
                        '👽',
                        '�',
                        '�',
                        '🤮',
                        '🤧',
                        '🤯',
                        '🤠',
                        '🥳',
                        '🥴',
                        '�',
                        '�',
                        '🤤',
                        '🥵',
                        '🥶',
                        '🧐',
                        '🤓',
                        '👾',
                        '🤮',
                        '🧟',
                        '🧞',
                        '🧛',
                        '🧙',
                        '🧜',
                        '🧝',
                        '�',
                        '🐲',
                        '🙈',
                        '🙉',
                        '🙊',
                        '🐵',
                        '🦍',
                        '�',
                        '🐕',
                        '🐩',
                      ]),
                      _buildStickerGrid(controller, [
                        '🐶',
                        '🐱',
                        '🐭',
                        '🐹',
                        '🐰',
                        '🦊',
                        '🐻',
                        '🐼',
                        '🐨',
                        '🐯',
                        '🦁',
                        '🐮',
                        '🐷',
                        '🐸',
                        '🐵',
                        '🐔',
                        '🐧',
                        '🐦',
                        '🐤',
                        '�',
                        '�',
                        '🦉',
                        '�',
                        '🐺',
                        '🐗',
                        '🐴',
                        '🦄',
                        '🐝',
                        '🐛',
                        '🦋',
                        '🐌',
                        '🐞',
                      ]),
                      _buildStickerGrid(controller, [
                        '🍎',
                        '🍐',
                        '🍊',
                        '🍋',
                        '🍌',
                        '🍉',
                        '🍇',
                        '🍓',
                        '🍈',
                        '🍒',
                        '🍑',
                        '🥭',
                        '🍍',
                        '🥥',
                        '🥝',
                        '🍅',
                        '🍆',
                        '🥑',
                        '🥦',
                        '🥬',
                        '🌽',
                        '🥕',
                        '🥔',
                        '🍠',
                        '🥐',
                        '🥯',
                        '🍞',
                        '🥖',
                        '🥨',
                        '🧀',
                        '�',
                        '🍳',
                      ]),
                      _buildStickerGrid(controller, [
                        '❤️',
                        '🧡',
                        '💛',
                        '💚',
                        '💙',
                        '💜',
                        '�',
                        '🤍',
                        '🤎',
                        '�',
                        '❣️',
                        '💕',
                        '💞',
                        '💓',
                        '💗',
                        '💖',
                        '💘',
                        '💝',
                        '💟',
                        '💌',
                        '💍',
                        '💎',
                        '💐',
                        '🌹',
                        '🥀',
                        '🌺',
                        '🌷',
                        '🌸',
                        '🌼',
                        '🌻',
                        '🌞',
                        '🌝',
                      ]),
                      _buildStickerGrid(controller, [
                        '⚽',
                        '🏀',
                        '🏈',
                        '⚾',
                        '🥎',
                        '🎾',
                        '🏐',
                        '🏉',
                        '🎱',
                        '🏓',
                        '🏸',
                        '🏒',
                        '🏑',
                        '🥍',
                        '🏏',
                        '🥅',
                        '⛳',
                        '🏹',
                        '🎣',
                        '🥊',
                        '🥋',
                        '🎽',
                        '🛹',
                        '🛷',
                        '⛸',
                        '🥌',
                        '🎿',
                        '⛷',
                        '🏂',
                        '🏋️',
                        '🤼',
                        '🤽',
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerGrid(ScrollController controller, List<String> emojis) {
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () {
          _sendSticker(emojis[index]);
          Navigator.pop(context);
        },
        child: Center(
          child: Text(emojis[index], style: const TextStyle(fontSize: 32)),
        ),
      ),
    );
  }

  Widget _buildQuickReaction(String emoji) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        final authProvider = context.read<AuthProvider>();
        final userName = authProvider.userName ?? "Anonymous";
        final userId = authProvider.user?.uid ?? userName;
        context.read<ChatProvider>().sendMessage(
          sender: userName,
          senderId: userId,
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
          border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.05),
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
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final currentUserName = authProvider.userName;
    final currentUserId = authProvider.user?.uid ?? currentUserName;
    final theme = Theme.of(context);
    final isLove = themeProvider.isLoveTheme;

    // Filter typing users (excluding me)
    final typingText = chatProvider.typingUsers.entries
        .where((e) => e.key != currentUserId && e.value)
        .map((e) => e.key)
        .join(", ");

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background - Mesh Gradient Style
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final activeColor = theme.primaryColor;
              return Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withValues(alpha: 0.2),
                      Colors.white,
                      activeColor.withValues(alpha: 0.1),
                    ],
                    transform: GradientRotation(
                      _bgController.value * 2 * math.pi,
                    ),
                  ),
                ),
              );
            },
          ),

          // Decorative Icons
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              final icon = isLove
                  ? Icons.favorite
                  : Icons.sentiment_very_satisfied;
              return Stack(
                children: [
                  Positioned(
                    top:
                        100 +
                        (math.sin(_bgController.value * 2 * math.pi) * 20),
                    right: -30,
                    child: Icon(
                      icon,
                      size: 200,
                      color: theme.primaryColor.withValues(alpha: 0.04),
                    ),
                  ),
                  Positioned(
                    bottom:
                        150 +
                        (math.cos(_bgController.value * 2 * math.pi) * 20),
                    left: -50,
                    child: Icon(
                      icon,
                      size: 250,
                      color: theme.primaryColor.withValues(alpha: 0.04),
                    ),
                  ),
                ],
              );
            },
          ),

          Column(
            children: [
              Expanded(
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
                              color: theme.primaryColor.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Start a conversation...",
                              style: GoogleFonts.poppins(
                                color: AppTheme.textGrey.withValues(alpha: 0.5),
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

                    if (messages.isNotEmpty) {
                      final latest = Map<String, dynamic>.from(
                        messages.first.value,
                      );
                      final timestamp = (latest['timestamp'] ?? 0) as int;
                      if (latest['type'] == 'reaction' &&
                          latest['senderId'] != currentUserId &&
                          timestamp > _lastProcessedTimestamp) {
                        _lastProcessedTimestamp = timestamp;
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _showHeartAnimation(),
                        );
                      }
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 100,
                        bottom: 16,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageKey = messages[index].key as String;
                        final message = Map<String, dynamic>.from(
                          messages[index].value,
                        );
                        final sender = message['sender'] ?? 'Unknown';
                        final senderId = message['senderId'] ?? sender;
                        final text = message['text'] ?? '';
                        final timestamp = message['timestamp'] as int?;
                        final type = message['type'] as String?;
                        final reactions =
                            message['reactions'] as Map<dynamic, dynamic>?;
                        final bool isMe = senderId == currentUserId;

                        if (type == 'reaction') {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$sender sent a ${isLove ? '❤️' : '😊'}",
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        }

                        String timeStr = "";
                        if (timestamp != null) {
                          timeStr = DateFormat('HH:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(timestamp),
                          );
                        }

                        return ChatBubble(
                          messageId: messageKey,
                          sender: sender,
                          message: text,
                          isMe: isMe,
                          time: timeStr,
                          type: type,
                          reactions: reactions,
                          onReactionSelected: (emoji) {
                            chatProvider.reactToMessage(
                              messageKey,
                              emoji,
                              currentUserName ?? "Anonymous",
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // Typing Indicator
              if (typingText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        "$typingText is typing...",
                        style: TextStyle(
                          color: theme.primaryColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

              // Message Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickReaction("❤️"),
                          _buildQuickReaction("😍"),
                          _buildQuickReaction("😂"),
                          _buildQuickReaction("🔥"),
                          _buildQuickReaction("👍"),
                          _buildQuickReaction("😲"),
                          _buildQuickReaction("😢"),
                          _buildQuickReaction("🌹"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLove
                                ? Icons.favorite
                                : Icons.sentiment_very_satisfied,
                            color: theme.primaryColor,
                          ),
                          onPressed: _sendReaction,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.sticky_note_2_outlined,
                            color: theme.primaryColor,
                          ),
                          onPressed: _showStickerPicker,
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: AppTheme.textBlack),
                            decoration: InputDecoration(
                              hintText: "Type a message...",
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
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
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
          ..._hearts,
        ],
      ),
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
      duration: const Duration(milliseconds: 2000),
    );
    final random = math.Random();
    for (int i = 0; i < 4; i++) {
      double direction = math.pi + (random.nextDouble() * math.pi);
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
    final isLove = context.watch<ThemeProvider>().isLoveTheme;
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    final emoji = isLove ? "💖" : "😂";

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final curvedProgress = Curves.easeOutCubic.transform(progress);
          final opacity = (1 - progress).clamp(0.0, 1.0);
          final scale = 0.5 + (math.sin(progress * math.pi) * 0.8);
          final rotation = progress * 3;

          return Stack(
            children: _points.map((p) {
              final xOffset = p.x * curvedProgress;
              final yOffset = p.y * curvedProgress;

              return Positioned(
                left: centerX + xOffset - (p.size / 2),
                top: centerY + yOffset - (p.size / 2),
                child: Opacity(
                  opacity: opacity,
                  child: Transform.rotate(
                    angle: p.angle + rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: Text(emoji, style: TextStyle(fontSize: p.size)),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
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
