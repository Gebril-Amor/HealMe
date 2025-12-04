// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  int? _patientId; // Store patient ID separately
  int? _therapistId; // Store therapist ID separately

  User? get currentUser => _currentUser;
  int? get patientId => _patientId; // Return the stored patient ID
  int? get therapistId => _therapistId; // Return the stored therapist ID
  bool get isLoading => _isLoading;

  Future<void> saveUser(User user, {int? patientId, int? therapistId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', json.encode(user.toJson()));
    
    // Save patient ID if provided
    if (patientId != null) {
      await prefs.setInt('patientId', patientId);
      _patientId = patientId;
    }
    // Save therapist ID if provided
    if (therapistId != null) {
      await prefs.setInt('therapistId', therapistId);
      _therapistId = therapistId;
    }
    
    _currentUser = user;
    notifyListeners();
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      
      // Load patient and therapist IDs from shared preferences
      _patientId = prefs.getInt('patientId');
      _therapistId = prefs.getInt('therapistId');
      
      notifyListeners();
      return _currentUser;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('patientId');
    _currentUser = null;
    _patientId = null;
    notifyListeners();

  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}