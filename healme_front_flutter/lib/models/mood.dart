// lib/models/mood.dart
class Mood {
  final int id;
  final int niveau;
  final String notes;
  final DateTime date;
  final int patientId;

  Mood({
    required this.id,
    required this.niveau,
    required this.notes,
    required this.date,
    required this.patientId,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'],
      niveau: json['niveau'],
      notes: json['notes'] ?? '',
      date: DateTime.parse(json['date']),
      patientId: json['patient'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'niveau': niveau,
      'notes': notes,
      'date': date.toIso8601String(),
      'patient': patientId,
    };
  }
}