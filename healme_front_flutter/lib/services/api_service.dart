// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/therapist.dart';
import '../models/message.dart';
import '../models/mood.dart';
import '../models/sleep.dart';
import '../models/journal.dart';
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api'; // Your URLs don't have /api prefix

  final Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  // Auth endpoints - CORRECT (matches your URLs)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String userType,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      headers: headers,
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'user_type': userType,        // Must include
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Therapist endpoints - CORRECT (from router)
  Future<List<Therapist>> getTherapists() async {
    final response = await http.get(
      Uri.parse('$baseUrl/therapists/'), // ✅ From router.urls
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Therapist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load therapists: ${response.statusCode}');
    }
  }

  // Message endpoints - UPDATED to match your exact URLs
  Future<List<Message>> getMessages(int patientId, int therapistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversation/$patientId/$therapistId/'), // ✅ Your exact URL
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  Future<void> sendMessage({
    required String contenu,
    required int patientId,
    required int therapistId,
    required String senderType,
  }) async {
    final messageData = {
      'patient_id': patientId,
      'therapist_id': therapistId,
      'contenu': contenu,
      'sender_type': senderType,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/send-message/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(messageData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }

  // Mood tracking endpoints - UPDATED to match your URLs
  Future<List<Mood>> getUserMood(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/mood/'), // ✅ Matches path('users/<int:user_id>/mood/', ...)
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mood.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mood data: ${response.statusCode}');
    }
  }

  Future<Mood> addMood(Map<String, dynamic> moodData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/humeurs/'), // ✅ From router.urls
      headers: headers,
      body: json.encode(moodData),
    );

    if (response.statusCode == 201) {
      return Mood.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add mood data: ${response.statusCode}. Response: ${response.body}');
    }
  }

  // Sleep tracking endpoints - UPDATED to match your URLs
  Future<List<Sleep>> getUserSleep(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/sleep/'), // ✅ Matches path('users/<int:user_id>/sleep/', ...)
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Sleep.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sleep data: ${response.statusCode}');
    }
  }

  Future<Sleep> addSleep(Map<String, dynamic> sleepData) async {
    
    final response = await http.post(
      Uri.parse('$baseUrl/sommeils/'), // ✅ From router.urls
      headers: headers,
      body: json.encode(sleepData),
    );

    if (response.statusCode == 201) {
      return Sleep.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add sleep data: ${response.statusCode}. Response: ${response.body}');
    }
  }

  // Additional endpoints from your URLs
  Future<List<dynamic>> getAllPatients() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all-patients/'), // ✅ Your URL
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patients: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getTherapistConversations(int therapistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/therapist/$therapistId/conversations/'), // ✅ Fixed: removed duplicate /api
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load therapist conversations: ${response.statusCode}');
    }
  }

  // In lib/services/api_service.dart

// Journal endpoints
Future<List<Journal>> getUserJournal(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/users/$userId/journal/'), // Matches your route
    headers: headers,
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Journal.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load journal data: ${response.statusCode}');
  }
}

Future<Journal> addJournal(Map<String, dynamic> journalData) async {
  final response = await http.post(
    Uri.parse('$baseUrl/journaux/'), // Matches your route
    headers: headers,
    body: json.encode(journalData),
  );

  if (response.statusCode == 201) {
    return Journal.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to add journal data: ${response.statusCode}. Response: ${response.body}');
  }
}

 // In your ApiService class
Future<String> getUserMoodInsight(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/moods/$userId/insights/'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // Extract the ai_insight from the JSON response
    return jsonResponse['ai_insight'] ?? 'No mood insight available';
  } else {
    throw Exception('Failed to load mood insights: ${response.statusCode}');
  }
}

Future<String> getUserSleepInsight(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/sleep/$userId/insights/'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // Extract the ai_insight from the JSON response
    return jsonResponse['ai_insight'] ?? 'No sleep insight available';
  } else {
    throw Exception('Failed to load sleep insights: ${response.statusCode}');
  }
}

Future<String> getUserJournalInsight(int userId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/journal/$userId/insights/'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // Extract the ai_insight from the JSON response
    return jsonResponse['ai_insight'] ?? 'No journal insight available';
  } else {
    throw Exception('Failed to load journal insights: ${response.statusCode}');
  }
}

Future<String> aiChatReply(String message) async {
  final response = await http.post(
    Uri.parse('$baseUrl/ai-chat/'),
    headers: headers,
    body: json.encode({
      "message": message,
     
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    // Extract the reply text
    return jsonResponse['reply'] ?? 'No AI reply available';
  } else {
    throw Exception('Failed to get AI reply: ${response.statusCode}');
  }
}

}