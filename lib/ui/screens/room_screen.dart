import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../logic/player_provider.dart';
import '../../logic/room_provider.dart';
import '../../logic/chat_provider.dart';
import '../../core/constants/utils/theme/app_theme.dart';
import 'search_screen.dart';
import 'chat_screen.dart';

import 'package:playdate/logic/theme_provider.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final roomProv = context.read<RoomProvider>();
      final playerProv = context.read<PlayerProvider>();
      final theme = Theme.of(context);

      roomProv.listenRoom(
        playerProv,
        () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Host has left the room. Sending you home..."),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        onJoinerLeft: () {
          if (mounted && roomProv.isHost) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("Your partner has left the room."),
                backgroundColor: theme.primaryColor,
              ),
            );
          }
        },
      );
    });
  }

  Future<bool> _onWillPop() async {
    final roomProv = context.read<RoomProvider>();
    final theme = Theme.of(context);
    if (!roomProv.isHost) {
      await roomProv.leaveRoom();
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text("Leave Room?"),
        content: const Text(
          "As the host, if you leave, the room will be closed for everyone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == true) {
      await roomProv.leaveRoom();
    }
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    final room = context.watch<RoomProvider>();
    final chat = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isLove = themeProvider.isLoveTheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: MediaQuery.of(context).viewInsets.bottom > 0
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  isLove ? "Our Love Room" : "Our Play Room",
                  style: GoogleFonts.pacifico(
                    color: theme.primaryColor,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
                iconTheme: IconThemeData(color: theme.primaryColor),
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
                          color: theme.primaryColor.withOpacity(0.1),
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
                                      color: theme.primaryColor.withOpacity(
                                        0.4,
                                      ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () => _onWillPop().then((value) {
                      if (value && mounted) Navigator.pop(context);
                    }),
                  ),
                ],
              ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primaryColor.withOpacity(0.1), Colors.white],
            ),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).size.height * 0.15
                    : MediaQuery.of(context).size.height * 0.28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: player.controller != null
                    ? YoutubePlayer(
                        key: ValueKey(player.currentVideoId),
                        controller: player.controller!,
                        showVideoProgressIndicator: true,
                        progressIndicatorColor: theme.primaryColor,
                        bottomActions: [
                          const SizedBox(width: 14.0),
                          CurrentPosition(),
                          const SizedBox(width: 8.0),
                          ProgressBar(
                            isExpanded: true,
                            colors: ProgressBarColors(
                              playedColor: theme.primaryColor,
                              handleColor: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          RemainingDuration(),
                        ],
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(seconds: 2),
                              builder: (context, double value, child) {
                                return Icon(
                                  isLove
                                      ? Icons.favorite
                                      : Icons.sentiment_very_satisfied,
                                  size: 60 + (value * 20),
                                  color: theme.primaryColor.withOpacity(0.6),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isLove
                                  ? "Waiting for a romantic tune..."
                                  : "Let's pick something to watch!",
                              style: TextStyle(
                                color: theme.primaryColor.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    context.read<ChatProvider>().setChatVisible(index == 1);
                  },
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: isLove
                                ? Colors.orangeAccent
                                : theme.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isLove
                                ? "Together with you"
                                : "Hanging out with friends",
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGrey,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            player.controller != null
                                ? "🎶 Watching together"
                                : "Find something to watch!",
                            style: TextStyle(
                              color: theme.primaryColor,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const SearchScreen(),
                              );
                            },
                            child: Container(
                              height: 180,
                              width: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withOpacity(0.25),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  height: 140,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.primaryColor,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isLove
                                            ? Icons.favorite
                                            : Icons.movie_outlined,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        isLove
                                            ? "Add Love\nMusic"
                                            : "Add Fun\nVideo",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Room ID: ${room.currentRoomId}",
                            style: TextStyle(
                              color: AppTheme.textGrey.withOpacity(0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ChatScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
            ? const SizedBox.shrink()
            : BottomNavigationBar(
                currentIndex: _currentIndex,
                backgroundColor: AppTheme.pureWhite,
                selectedItemColor: theme.primaryColor,
                unselectedItemColor: AppTheme.textGrey,
                onTap: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.movie_outlined),
                    label: "Content",
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.chat),
                        if (chat.unreadCount > 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${chat.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: "Chat",
                  ),
                ],
              ),
      ),
    );
  }
}
