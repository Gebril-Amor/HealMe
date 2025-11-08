// lib/models/journal.dart
class Journal {
  final int id;
  final String contenu;
  final DateTime date;
  final int patientId;

  Journal({
    required this.id,
    required this.contenu,
    required this.date,
    required this.patientId,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'],
      contenu: json['contenu'] ?? '',
      date: DateTime.parse(json['date']),
      patientId: json['patient'] ?? 0,
    );
  }
}