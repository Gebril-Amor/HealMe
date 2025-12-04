// lib/pages/therapist_home_page.dart
import 'package:flutter/material.dart';
import 'package:healme_front_flutter/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import 'therapist_chat_page.dart';

class TherapistHomePage extends StatefulWidget {
  const TherapistHomePage({super.key});

  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  List<dynamic> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      // Use therapist-specific conversations endpoint so we get unread counts and last message
      final authService = Provider.of<AuthService>(context, listen: false);
      final therapistId = authService.therapistId;
      if (therapistId == null) {
        throw Exception('Therapist ID not found. Please login as a therapist.');
      }
      final conversations = await ApiService().getTherapistConversations(therapistId);
      setState(() {
        // conversations is a list of maps with patient_id, patient_name, patient_email, last_message, unread_count
        _patients = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load patients: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPatientCard(dynamic patient) {
    final patientId = patient['patient_id'] ?? 0;
    final patientName = patient['patient_name'] ?? 'Unknown Patient';
    final patientEmail = patient['patient_email'] ?? 'No email';
    final unreadCount = patient['unread_count'] ?? 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapistChatPage(
                patientId: patientId,
                patient: User(
                  id: patientId,
                  username: patientName,
                  email: patientEmail,
                  userType: 'patient',
                ),
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 12),
          decoration: AppDecorations.glassCard,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Patient Avatar (highlight if unread)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: unreadCount > 0
                        ? LinearGradient(
                            colors: [Colors.orange, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [AppColors.secondary, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                
                // Patient Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        patientEmail,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chat Icon with unread badge
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.chat_bubble_outline, size: 20, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TherapistChatPage(
                                patientId: patientId,
                                patient: User(
                                  id: patientId,
                                  username: patientName,
                                  email: patientEmail,
                                  userType: 'patient',
                                ),
                              ),
                            ),
                          );
                        },
                        tooltip: 'Start chat',
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.currentUser;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Therapist Dashboard',
          style: AppTextStyles.headline1,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.text),
           onPressed: () async {
              await authService.logout();
             Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
  );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _patients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No Patients Yet',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Patients will appear here when they message you',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Container(
                        decoration: AppDecorations.glassCard,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user?.username ?? 'Therapist',
                                style: AppTextStyles.headline1.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'You have ${_patients.length} patient${_patients.length == 1 ? '' : 's'}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      
                      // Patients List
                      Text(
                        'Your Patients',
                        style: AppTextStyles.headline2.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      ..._patients.map((patient) => _buildPatientCard(patient)),
                    ],
                  ),
                ),
    );
  }
}