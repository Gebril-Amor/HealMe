// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  int? _patientId; // Store patient ID separately

  User? get currentUser => _currentUser;
  int? get patientId => _patientId; // Return the stored patient ID
  bool get isLoading => _isLoading;

  Future<void> saveUser(User user, {int? patientId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', json.encode(user.toJson()));
    
    // Save patient ID if provided
    if (patientId != null) {
      await prefs.setInt('patientId', patientId);
      _patientId = patientId;
    }
    
    _currentUser = user;
    notifyListeners();
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
      
      // Load patient ID from shared preferences
      _patientId = prefs.getInt('patientId');
      
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