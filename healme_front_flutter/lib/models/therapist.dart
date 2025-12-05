class Therapist {
  final int id;          // therapist table id
  final int userId;      // user id (used for chat)
  final String name;
  final String email;
  final String specialty;
  final int unreadCount;

  Therapist({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.specialty,
    required this.unreadCount,
  });

  factory Therapist.fromJson(Map<String, dynamic> json) {
    return Therapist(
      id: json['id'],
      userId: json['user_id'],   
      name: json['username'] ?? 'Therapist',  
      email: json['email'] ?? '',
      specialty: json['specialite'] ?? 'Mental Health',
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
