// lib/pages/ai_chat_page.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';
import 'dart:async';

import '../services/api_service.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({Key? key}) : super(key: key);

  @override
  _AiChatPageState createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ApiService api = ApiService();
  bool _isThinking = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Display the user's message
    setState(() {
      _messages.add({
        "sender": "user",
        "message": text,
        "time": DateTime.now(),
      });
      _isThinking = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // 🔥 CALL AI ENDPOINT (NO USER ID)
      final aiReply = await api.aiChatReply(text);

      setState(() {
        _messages.add({
          "sender": "ai",
          "message": aiReply,
          "time": DateTime.now(),
        });
        _isThinking = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "ai",
          "message": "⚠️ Error: $e",
          "time": DateTime.now(),
        });
        _isThinking = false;
      });
    }

    _scrollToBottom();
  }

  Widget _buildBubble(Map msg) {
    final bool isUser = msg["sender"] == "user";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppColors.glass,
                          AppColors.glass.withOpacity(0.8)
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                msg["message"],
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isUser ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          "AI Assistant",
          style: AppTextStyles.headline2.copyWith(color: AppColors.text),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy,
                            size: 70, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          "Start a conversation with your AI assistant",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isThinking ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isThinking && index == _messages.length) {
                        return const Text("AI is typing...");
                      }
                      return _buildBubble(_messages[index]);
                    },
                  ),
          ),

          // --- INPUT BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration:
                        const InputDecoration(hintText: "Type your message..."),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
