class Patient {
  final int id;
  final int userId;
  final String? phone;
  final DateTime? dateNaissance;

  Patient({
    required this.id,
    required this.userId,
    this.phone,
    this.dateNaissance,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      userId: json['user'] is int ? json['user'] : json['user']['id'],
      phone: json['phone'],
      dateNaissance: json['dateNaissance'] != null 
          ? DateTime.parse(json['dateNaissance'])
          : null,
    );
  }
}