import 'package:flutter/material.dart';
import '../core/constants/utils/theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  final String? messageId;
  final String sender;
  final String message;
  final bool isMe;
  final String time;
  final String? type;
  final Map<dynamic, dynamic>? reactions;
  final Function(String emoji)? onReactionSelected;

  const ChatBubble({
    super.key,
    this.messageId,
    required this.sender,
    required this.message,
    required this.isMe,
    required this.time,
    this.type,
    this.reactions,
    this.onReactionSelected,
  });

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['❤️', '😂', '😮', '😢', '🔥', '👍'].map((emoji) {
            return GestureDetector(
              onTap: () {
                onReactionSelected?.call(emoji);
                Navigator.pop(context);
              },
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSticker = type == 'sticker';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text(
                sender,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          GestureDetector(
            onLongPress: () => _showReactionPicker(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: isSticker
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: isSticker
                        ? Colors.transparent
                        : (isMe
                              ? theme.primaryColor
                              : theme.primaryColor.withValues(alpha: 0.1)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                    boxShadow: isSticker
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (isSticker)
                        Text(message, style: const TextStyle(fontSize: 80))
                      else
                        Text(
                          message,
                          style: TextStyle(
                            color: isMe ? Colors.white : AppTheme.textBlack,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      if (!isSticker) const SizedBox(height: 6),
                      if (!isSticker)
                        Text(
                          time,
                          style: TextStyle(
                            color: (isMe ? Colors.white : AppTheme.textBlack)
                                .withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                    ],
                  ),
                ),
                if (reactions != null && reactions!.isNotEmpty)
                  Positioned(
                    bottom: -15,
                    right: isMe ? null : -10,
                    left: isMe ? -10 : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: reactions!.values.toSet().map((emoji) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: Text(
                              emoji.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
