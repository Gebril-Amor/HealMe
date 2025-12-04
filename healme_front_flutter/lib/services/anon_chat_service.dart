import 'dart:math';
import 'package:firebase_database/firebase_database.dart';

class AnonChatService {
  final db = FirebaseDatabase.instance.ref();

  // Generate random username like USER57
  String generateAnonName() {
    final r = Random().nextInt(999);
    return "USER$r";
  }

  // Join a room (or create if it does not exist)
  Future<String> joinRoom(String roomId) async {
    final roomRef = db.child("rooms/$roomId/users");

    final snapshot = await roomRef.get();

    // Check if room has space
    if (snapshot.exists && snapshot.children.length >= 5) {
      throw Exception("Room full (5 users max)");
    }

    // Create random anonymous username
    final username = generateAnonName();

    // Add user to the room
    await roomRef.child(username).set(true);

    return username;
  }

  // Send message
  Future<void> sendMessage(String roomId, String sender, String text) async {
    await db.child("rooms/$roomId/messages").push().set({
      "sender": sender,
      "text": text,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Listen to messages in real-time
  Stream<DatabaseEvent> messagesStream(String roomId) {
    return db.child("rooms/$roomId/messages").onValue;
  }

  Future<Map<String, String>> autoJoinRoom() async {
  int roomNumber = 1;

  while (true) {
    final roomId = "room$roomNumber";
    final usersRef = db.child("rooms/$roomId/users");
    final snapshot = await usersRef.get();

    if (!snapshot.exists || snapshot.children.length < 5) {
      // JOIN THIS ROOM
      final username = await joinRoom(roomId);
      return {"roomId": roomId, "username": username};
    }

    roomNumber++;
  }
}

}
