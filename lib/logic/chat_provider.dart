import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ChatProvider extends ChangeNotifier {
  DatabaseReference? _chatRef;
  int _unreadCount = 0;
  bool _isChatVisible = false;

  int get unreadCount => _unreadCount;

  void setChatVisible(bool visible) {
    _isChatVisible = visible;
    if (visible) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void attachRoom(String roomId) {
    _chatRef = FirebaseDatabase.instance.ref("$roomId/messages");
    _chatRef?.onChildAdded.listen((event) {
      if (!_isChatVisible) {
        _unreadCount++;
        notifyListeners();
      }
    });
  }

  Stream<DatabaseEvent>? get messageStream => _chatRef?.onValue;

  Future<void> sendMessage({
    required String sender,
    required String senderId,
    required String text,
  }) async {
    if (_chatRef == null) return;

    await _chatRef!.push().set({
      "sender": sender,
      "senderId": senderId,
      "text": text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
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
