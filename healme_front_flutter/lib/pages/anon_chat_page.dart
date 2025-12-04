// lib/pages/anon_chat_page.dart
import 'package:flutter/material.dart';
import '../services/anon_chat_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import 'dart:async';

class AnonChatPage extends StatefulWidget {
  const AnonChatPage({Key? key}) : super(key: key);

  @override
  State<AnonChatPage> createState() => _AnonChatPageState();
}

class _AnonChatPageState extends State<AnonChatPage> {
  final AnonChatService service = AnonChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? username;
  String? roomId;
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _messagesSub;

  @override
  void initState() {
    super.initState();
    _joinRoomAndListen();
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _joinRoomAndListen() async {
    final result = await service.autoJoinRoom();
    roomId = result["roomId"];
    username = result["username"];

    // Listen to messages
    _messagesSub = service.messagesStream(roomId!).listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final list = data.entries.map((e) {
          return {
            "sender": e.value["sender"],
            "text": e.value["text"],
            "timestamp": e.value["timestamp"],
          };
        }).toList();

        list.sort((a, b) => a["timestamp"].compareTo(b["timestamp"]));

        setState(() {
          _messages = list;
          _isLoading = false;
        });

        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _sendMessage() {
    if (roomId == null || username == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    service.sendMessage(roomId!, username!, text);
    _messageController.clear();
  }

Widget _buildMessageBubble(Map<String, dynamic> msg) {
  final isMe = msg["sender"] == username;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.person_outline, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isMe
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [AppColors.glass, AppColors.glass.withOpacity(0.8)],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Add sender alias
                Text(
                  msg["sender"],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // Message text
                Text(
                  msg["text"],
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isMe ? Colors.white : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                // Timestamp
                Text(
                  "${DateTime.fromMillisecondsSinceEpoch(msg["timestamp"]).hour}:${DateTime.fromMillisecondsSinceEpoch(msg["timestamp"]).minute.toString().padLeft(2, '0')}",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isMe ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.transparent,
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
 appBar: AppBar(
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        username ?? "Anonymous", // Your alias
        style: AppTextStyles.headline2.copyWith(color: Colors.white),
      ),
      Text(
        "Room: ${roomId ?? '...' }", // Room ID
        style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
      ),
    ],
  ),
  backgroundColor: AppColors.primary,
  elevation: 0,
 
  
),
 body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: AppTextStyles.headline2.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start chatting anonymously!',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) =>
                            _buildMessageBubble(_messages[index]),
                      ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glass,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.glass.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle:
                            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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
