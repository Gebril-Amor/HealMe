// lib/pages/therapist_chat_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_scaffold.dart';

class TherapistChatPage extends StatefulWidget {
  final int patientId;
  final User patient;

  const TherapistChatPage({
    super.key,
    required this.patientId,
    required this.patient,
  });

  @override
  _TherapistChatPageState createState() => _TherapistChatPageState();
}

class _TherapistChatPageState extends State<TherapistChatPage> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = true;
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();
  late int _therapistId;
  late AuthService _authService;

  StreamSubscription<List<Message>>? _messagesSub;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    // Use therapistId from AuthService (was incorrectly using patientId)
    _therapistId = _authService.therapistId ?? 0;
    if (_therapistId == 0) {
      debugPrint('Warning: therapistId is not set in AuthService.');
    }
    // Subscribe to real-time messages
    _messagesSub = ChatService()
        .messagesStream(widget.patientId, _therapistId)
        .listen((messages) {
      if (mounted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(messages);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }, onError: (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Therapist chat stream error: $e');
    });

    // Mark messages as read for this conversation (messages sent by patient)
    if (_therapistId != 0) {
      ChatService().markAllRead(widget.patientId, _therapistId, forSender: 'patient');
    }
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAutoRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _loadMessages();
    });
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ApiService().getMessages(
        widget.patientId,
        _therapistId,
      );
      if (mounted) {
        setState(() {
          _messages
            ..clear()
            ..addAll(messages);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final String messageText = _messageController.text.trim();
    _messageController.clear();

    if (_therapistId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot send message: therapist ID not found.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await ChatService().sendMessage(
        contenu: messageText,
        patientId: widget.patientId,
        therapistId: _therapistId,
        senderType: 'therapeute',
      );

      // Add message locally for immediate UI update
      setState(() {
        _messages.add(Message(
          id: DateTime.now().millisecondsSinceEpoch,
          contenu: messageText,
          date: DateTime.now(),
          senderType: 'therapeute',
          patientId: widget.patientId,
          therapistId: _therapistId,
        ));
      });
      _scrollToBottom();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send message: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Add message locally for better UX even if failed
      setState(() {
        _messages.add(Message(
          id: DateTime.now().millisecondsSinceEpoch,
          contenu: messageText,
          date: DateTime.now(),
          senderType: 'therapeute',
          patientId: widget.patientId,
          therapistId: _therapistId,
        ));
      });
      _scrollToBottom();
    }
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

  Widget _buildMessageBubble(Message message) {
    final isTherapist = message.senderType == 'therapeute';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isTherapist ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isTherapist) ...[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isTherapist 
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
                  Text(
                    message.contenu,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isTherapist ? Colors.white : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.date.hour}:${message.date.minute.toString().padLeft(2, '0')}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isTherapist ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isTherapist) ...[
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.psychology, size: 16, color: Colors.white),
              ),
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
              widget.patient.username,
              style: AppTextStyles.headline2.copyWith(color: AppColors.text),
            ),
            Text(
              widget.patient.email,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _messages.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textSecondary),
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
                              'Start the conversation with ${widget.patient.username}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
          ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glass,
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.glass.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
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