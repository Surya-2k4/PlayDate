import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class ChatProvider extends ChangeNotifier {
  DatabaseReference? _chatRef;
  DatabaseReference? _typingRef;
  int _unreadCount = 0;
  bool _isChatVisible = false;
  Map<String, bool> _typingUsers = {};

  int get unreadCount => _unreadCount;
  Map<String, bool> get typingUsers => _typingUsers;

  void setChatVisible(bool visible) {
    _isChatVisible = visible;
    if (visible) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void attachRoom(String roomId) {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
    );
    _chatRef = db.ref("$roomId/messages");
    _typingRef = db.ref("$roomId/typing");

    _chatRef?.onChildAdded.listen((event) {
      if (!_isChatVisible) {
        _unreadCount++;
        notifyListeners();
      }
    });

    _typingRef?.onValue.listen((event) {
      if (event.snapshot.value != null) {
        _typingUsers = Map<String, bool>.from(event.snapshot.value as Map);
      } else {
        _typingUsers = {};
      }
      notifyListeners();
    });
  }

  Stream<DatabaseEvent>? get messageStream => _chatRef?.onValue;

  Future<void> setTyping(String userId, bool isTyping) async {
    if (_typingRef == null) return;
    await _typingRef!.child(userId).set(isTyping);
  }

  Future<void> sendMessage({
    required String sender,
    required String senderId,
    required String text,
    String? type,
  }) async {
    if (_chatRef == null) return;

    await _chatRef!.push().set({
      "sender": sender,
      "senderId": senderId,
      "text": text,
      "type": type ?? "text",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "reactions": {},
    });
  }

  Future<void> reactToMessage(
    String messageId,
    String emoji,
    String userId,
  ) async {
    if (_chatRef == null) return;
    await _chatRef!
        .child(messageId)
        .child("reactions")
        .child(userId)
        .set(emoji);
  }

  Future<void> sendLoveReaction(String sender) async {
    if (_chatRef == null) return;
    await _chatRef!.push().set({
      "sender": sender,
      "type": "reaction",
      "text": "❤️",
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }
}
