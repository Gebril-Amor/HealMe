// lib/services/chat_service.dart
import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../models/message.dart';
import 'api_service.dart';

class ChatService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  String _conversationPath(int patientId, int therapistId) =>
      'conversations/patient_${patientId}_therapist_$therapistId';

  /// Stream of messages for a conversation between a patient and a therapist.
  /// Returns a list of `Message` sorted by date ascending.
  Stream<List<Message>> messagesStream(int patientId, int therapistId) {
    final ref = _db.child('${_conversationPath(patientId, therapistId)}/messages');
    return ref.onValue.map((event) {
      final snap = event.snapshot;
      if (snap.value == null) return <Message>[];
      final map = Map<String, dynamic>.from(snap.value as Map);
      final List<Message> list = [];
      final seenIds = <int>{};
      map.forEach((key, value) {
        try {
          final v = Map<String, dynamic>.from(value as Map);
          final dateStr = v['date']?.toString() ?? DateTime.now().toIso8601String();
          final parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
          final int msgId = (v['id'] is int)
              ? v['id'] as int
              : DateTime.now().millisecondsSinceEpoch;
          if (seenIds.contains(msgId)) return; // skip duplicates
          seenIds.add(msgId);
          list.add(Message(
            id: msgId,
            contenu: v['contenu'] ?? '',
            date: parsedDate,
            senderType: v['sender_type'] ?? v['senderType'] ?? 'patient',
            patientId: v['patient_id'] ?? v['patient'] ?? patientId,
            therapistId: v['therapist_id'] ?? v['therapeute'] ?? therapistId,
          ));
        } catch (_) {}
      });
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  /// Send a message to the conversation using Realtime Database push.
  Future<void> sendMessage({
    required String contenu,
    required int patientId,
    required int therapistId,
    required String senderType,
  }) async {
    final path = '${_conversationPath(patientId, therapistId)}/messages';
    final ref = _db.child(path).push();
    if (kDebugMode) {
      print('ChatService: writing to path: $path');
    }
    final now = DateTime.now().toIso8601String();
    final payload = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'contenu': contenu,
      'date': now,
      'sender_type': senderType,
      'patient_id': patientId,
      'therapist_id': therapistId,
      'is_read': false,
    };
    await ref.set(payload);

    // Also mirror the message to the Django backend so server-side views (therapist_conversations)
    // see the message and unread counts are accurate. This performs a best-effort POST.
    try {
      await ApiService().sendMessage(
        contenu: contenu,
        patientId: patientId,
        therapistId: therapistId,
        senderType: senderType,
      );
      if (kDebugMode) print('ChatService: mirrored message to API for patient=$patientId therapist=$therapistId');
    } catch (e) {
      // Log but don't fail the Firebase write
      if (kDebugMode) print('ChatService: failed to mirror message to API: $e');
    }
  }

  /// Mark all messages as read for the given conversation where sender is the other party.
  Future<void> markAllRead(int patientId, int therapistId, {required String forSender}) async {
    final path = '${_conversationPath(patientId, therapistId)}/messages';
    final ref = _db.child(path);
    final snapshot = await ref.get();
    if (snapshot.exists && snapshot.value != null) {
      final map = Map<String, dynamic>.from(snapshot.value as Map);
      final updates = <String, dynamic>{};
      map.forEach((key, value) {
        final v = Map<String, dynamic>.from(value as Map);
        if (v['sender_type'] != forSender && v['is_read'] == false) {
          updates['$key/is_read'] = true;
        }
      });
      if (updates.isNotEmpty) await ref.update(updates);
    }
  }
}
