import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:playdate/logic/auth_provider.dart';
import 'package:playdate/logic/room_provider.dart';
import 'package:provider/provider.dart';
import 'core/constants/utils/theme/app_theme.dart';
import 'logic/player_provider.dart';
import 'package:playdate/logic/chat_provider.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("[PlayDate] Firebase initialized successfully");
  } catch (e) {
    debugPrint("[PlayDate] Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => RoomProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const PlayDateApp(),
    ),
  );
}

class PlayDateApp extends StatelessWidget {
  const PlayDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlayDate',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
