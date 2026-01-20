import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_database/firebase_database.dart';

class PlayerProvider extends ChangeNotifier {
  YoutubePlayerController? _controller;
  String? _currentVideoId;
  DatabaseReference? _roomRef;
  bool _isSyncing = false;
  StreamSubscription? _syncSubscription;
  List<Map<String, dynamic>> _queue = [];

  bool _isHost = false;

  YoutubePlayerController? get controller => _controller;
  String? get currentVideoId => _currentVideoId;
  List<Map<String, dynamic>> get queue => _queue;
  bool get isHost => _isHost;

  /// Called by RoomProvider when room is created/joined
  void attachRoom(String roomId, bool isHost) {
    _roomRef = FirebaseDatabase.instance.ref(roomId);
    _isHost = isHost;
  }

  /// Called when user taps a song or from sync
  void playVideo(String videoId, {bool fromSync = false}) {
    if (_currentVideoId == videoId && _controller != null) {
      if (!fromSync) _controller?.load(videoId);
      return;
    }

    _currentVideoId = videoId;
    _controller?.dispose();
    _syncSubscription?.cancel();

    _lastPositionMs = 0;
    _lastIsPlaying = true; // Video starts playing usually

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );

    if (!fromSync && _roomRef != null) {
      _roomRef!.update({
        "videoId": videoId,
        "isPlaying": true,
        "positionMs": 0,
      });
    }

    notifyListeners();
    _attachPlayerListener();
  }

  Future<void> addToQueue(Map<String, dynamic> video) async {
    if (_roomRef == null) return;

    // Check if it's already playing or in queue to prevent double entry if desired
    // For now, allow multiple entries.

    final newQueue = List<Map<String, dynamic>>.from(_queue);
    newQueue.add(video);

    await _roomRef!.update({"queue": newQueue});
  }

  Future<void> removeFromQueue(int index) async {
    if (_roomRef == null) return;

    final newQueue = List<Map<String, dynamic>>.from(_queue);
    if (index >= 0 && index < newQueue.length) {
      newQueue.removeAt(index);
      await _roomRef!.update({"queue": newQueue});
    }
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (_roomRef == null) return;

    final newQueue = List<Map<String, dynamic>>.from(_queue);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);

    await _roomRef!.update({"queue": newQueue});
  }

  void playNext() {
    if (_queue.isNotEmpty) {
      final nextSong = _queue.first;
      // Advance locally for zero-delay feel
      playVideo(nextSong['id']);

      // Only the host manages the queue advancement in Firebase
      if (_isHost) {
        removeFromQueue(0);
      }
    }
  }

  bool _lastIsPlaying = false;
  int _lastPositionMs = 0;

  void _attachPlayerListener() {
    _controller?.addListener(() {
      if (_controller == null || _roomRef == null || _isSyncing) return;

      final value = _controller!.value;

      // Auto-play next song when current finishes
      final isEnded = value.playerState == PlayerState.ended;
      final isAtEnd =
          value.isReady &&
          value.position >=
              (value.metaData.duration - const Duration(milliseconds: 500)) &&
          value.metaData.duration.inSeconds > 0;

      if (isEnded || isAtEnd) {
        // Debounce to prevent multiple triggers for the same video
        if (_isSyncing) return;
        _isSyncing = true;
        playNext();
        Future.delayed(const Duration(milliseconds: 2000), () {
          _isSyncing = false;
        });
        return;
      }

      if (!value.isReady) return;

      final currentIsPlaying = value.isPlaying;
      final currentPositionMs = value.position.inMilliseconds;

      bool stateChanged = currentIsPlaying != _lastIsPlaying;
      bool seekOccurred =
          (currentPositionMs - (_lastPositionMs + 500)).abs() > 2000;

      if (stateChanged || seekOccurred) {
        _lastIsPlaying = currentIsPlaying;
        _lastPositionMs = currentPositionMs;

        // We only update if we are not currently syncing from a remote update
        _roomRef!.update({
          "isPlaying": currentIsPlaying,
          "positionMs": currentPositionMs,
          "videoId": _currentVideoId,
        });
      }
    });

    // Periodic update (every 2 seconds)
    _syncSubscription = Stream.periodic(const Duration(seconds: 2)).listen((_) {
      if (_controller == null || _roomRef == null || _isSyncing) return;

      // Don't sync if not ready or not playing
      if (!_controller!.value.isReady || !_controller!.value.isPlaying) return;

      _roomRef!.update({
        "positionMs": _controller!.value.position.inMilliseconds,
      });
    });
  }

  /// Called by RoomProvider when Firebase updates
  Future<void> syncFromRoom({
    required bool isPlaying,
    required int positionMs,
    String? videoId,
    List<Map<String, dynamic>>? queue,
  }) async {
    // Sync Queue
    if (queue != null) {
      _queue = queue;
      notifyListeners();
    } else {
      _queue = [];
      notifyListeners();
    }

    // 1. Handle video change
    if (videoId != null && videoId != _currentVideoId) {
      _isSyncing = true;

      // If we are host and this video just started playing (likely triggered by partner), remove from queue
      if (_isHost && _queue.isNotEmpty && _queue.first['id'] == videoId) {
        removeFromQueue(0);
      }

      playVideo(videoId, fromSync: true);
      // We stay in syncing mode for a bit to let the player load
      await Future.delayed(const Duration(milliseconds: 1500));
      _isSyncing = false;
      return;
    }

    if (_controller == null || _isSyncing) return;

    final value = _controller!.value;
    if (!value.isReady) return;

    final localPos = value.position.inMilliseconds;

    _isSyncing = true;

    // Sync Play/Pause
    if (isPlaying && !value.isPlaying) {
      _controller!.play();
    } else if (!isPlaying && value.isPlaying) {
      _controller!.pause();
    }

    // Sync Position (if drift > 3 seconds)
    if ((positionMs - localPos).abs() > 3000) {
      _controller!.seekTo(Duration(milliseconds: positionMs));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _isSyncing = false;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }
}
