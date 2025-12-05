// lib/models/message.dart
class Message {
  final int id;
  final String contenu;
  final DateTime date;
  final String senderType;
  final int patientId;
  final int therapistId;

  Message({
    required this.id,
    required this.contenu,
    required this.date,
    required this.senderType,
    required this.patientId,
    required this.therapistId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
     return Message(
      id: json['id'],
      contenu: json['contenu'] ?? '',  
      date: DateTime.parse(json['date']),
      senderType: json['sender_type'] ?? 'patient',
      patientId: json['patient'] ?? 0,  
      therapistId: json['therapeute'] ?? 0, 
    );
  }
}