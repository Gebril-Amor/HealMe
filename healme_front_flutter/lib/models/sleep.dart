// lib/models/sleep.dart
class Sleep {
  final int id;
  final double hours;
  final String quality;
  final DateTime date;
  final int patientId;

  Sleep({
    required this.id,
    required this.hours,
    required this.quality,
    required this.date,
    required this.patientId,
  });

factory Sleep.fromJson(Map<String, dynamic> json) {
  return Sleep(
    id: json['id'],
    hours: (json['dureeHeures'] as num?)?.toDouble() ?? 0.0,  // ← Expect 'dureeHeures'
    quality: json['qualite'] ?? '',
    date: DateTime.parse(json['date'] as String? ?? DateTime.now().toIso8601String()),
    patientId: json['patient'] ?? 0,
  );
}

Map<String, dynamic> toJson() {
  return {
    'dureeHeures': hours,    // ← Also update toJson to be consistent
    'qualite': quality,
    'date': date.toIso8601String(),
    'patient': patientId,
  };
}
}