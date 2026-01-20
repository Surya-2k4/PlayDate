import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'player_provider.dart';
import 'chat_provider.dart';

class RoomProvider extends ChangeNotifier {
  DatabaseReference? _roomRef;
  Stream<DatabaseEvent>? _roomStream;
  bool _isHost = false;
  String? _currentRoomId;
  bool _wasJoinerEverHere = false;

  bool get isHost => _isHost;
  String? get currentRoomId => _currentRoomId;

  Future<void> createRoom(
    String roomId,
    PlayerProvider player,
    ChatProvider chat,
    String initialTheme,
  ) async {
    _roomRef = FirebaseDatabase.instance.ref(roomId);
    _currentRoomId = roomId;
    _isHost = true;
    _wasJoinerEverHere = false;

    await _roomRef!.set({
      "isPlaying": false,
      "positionMs": 0,
      "videoId": null,
      "messages": {},
      "hostActive": true,
      "joinerActive": false,
      "theme": initialTheme,
    });

    // Automatically clean up room if host disconnects unexpectedly
    _roomRef!.onDisconnect().remove();

    player.attachRoom(roomId, true);
    chat.attachRoom(roomId);
    notifyListeners();
  }

  Future<void> joinRoom(
    String roomId,
    PlayerProvider player,
    ChatProvider chat,
  ) async {
    _roomRef = FirebaseDatabase.instance.ref(roomId);
    _currentRoomId = roomId;
    _isHost = false;

    await _roomRef!.update({"joinerActive": true});

    // Mark joiner as inactive if they disconnect unexpectedly
    _roomRef!.child("joinerActive").onDisconnect().set(false);

    player.attachRoom(roomId, false);
    chat.attachRoom(roomId);
    notifyListeners();
  }

  void listenRoom(
    PlayerProvider player,
    void Function(String) onThemeChanged,
    VoidCallback onHostLeft, {
    VoidCallback? onJoinerLeft,
  }) {
    if (_roomRef == null) return;

    _roomStream ??= _roomRef!.onValue;

    _roomStream!.listen((event) {
      if (event.snapshot.value == null) {
        if (!_isHost) onHostLeft();
        return;
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      if (data['hostActive'] == false && !_isHost) {
        onHostLeft();
        return;
      }

      // Updated Partner Join/Leave Logic
      if (_isHost && onJoinerLeft != null) {
        bool isPartnerPresent = data['joinerActive'] ?? false;

        if (isPartnerPresent && !_wasJoinerEverHere) {
          _wasJoinerEverHere = true; // Partner joined for the first time
        } else if (!isPartnerPresent && _wasJoinerEverHere) {
          _wasJoinerEverHere = false; // Partner was here, now they left
          onJoinerLeft();
        }
      }

      // Sync Player state ONLY if changed or significantly drifted
      final bool isPlaying = data['isPlaying'] ?? false;
      final int positionMs = data['positionMs'] ?? 0;
      final String? videoId = data['videoId'];

      List<Map<String, dynamic>>? queue;
      if (data['queue'] != null) {
        queue = (data['queue'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }

      player.syncFromRoom(
        isPlaying: isPlaying,
        positionMs: positionMs,
        videoId: videoId,
        queue: queue,
      );

      // Sync Theme
      final String? themeType = data['theme'];
      if (themeType != null) {
        onThemeChanged(themeType);
      }
    });
  }

  Future<void> updateRoomTheme(String themeType) async {
    if (_roomRef != null) {
      await _roomRef!.update({"theme": themeType});
    }
  }

  Future<void> leaveRoom() async {
    if (_roomRef != null) {
      if (_isHost) {
        // As a host, mark inactive and then wipe everything
        await _roomRef!.update({"hostActive": false});
        // Short delay to allow joiners to receive the "hostActive: false" update
        await Future.delayed(const Duration(milliseconds: 500));
        await _roomRef!.remove();
      } else {
        // As a joiner, just mark joiner as inactive
        await _roomRef!.update({"joinerActive": false});
      }
    }
    _roomRef = null;
    _roomStream = null;
    _currentRoomId = null;
    _isHost = false;
    notifyListeners();
  }
}
