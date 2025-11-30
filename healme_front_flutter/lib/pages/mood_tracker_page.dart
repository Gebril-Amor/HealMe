// lib/pages/mood_tracker_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/mood.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_page.dart';
import 'sleep_tracker_page.dart';
import 'therapist_list_page.dart';
import 'journal_tracker_page.dart';

class MoodTrackerPage extends StatefulWidget {
  @override
  _MoodTrackerPageState createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  final List<Mood> _moodHistory = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  int _moodLevel = 5;
  String _notes = '';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMoodHistory();
  }

  Future<void> _loadMoodHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;

    if (userId == null) return;

    try {
      final moods = await ApiService().getUserMood(userId);
      setState(() {
        _moodHistory.clear();
        _moodHistory.addAll(moods);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitMood() async {
    if (_isSubmitting) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to track mood'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiService().addMood({
        'niveau': _moodLevel,
        'description': _notes,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'patient': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mood recorded successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _moodLevel = 5;
        _notes = '';
        _notesController.clear();
      });

      _loadMoodHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record mood: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _getMoodEmoji(int level) {
    if (level <= 2) return '😢';
    if (level <= 4) return '😔';
    if (level <= 6) return '😐';
    if (level <= 8) return '😊';
    return '😄';
  }

  String _getMoodDescription(int level) {
    if (level <= 2) return 'Very Poor';
    if (level <= 4) return 'Poor';
    if (level <= 6) return 'Neutral';
    if (level <= 8) return 'Good';
    return 'Excellent';
  }

  Color _getMoodColor(int level) {
    if (level <= 2) return Colors.red.withOpacity(0.3);
    if (level <= 4) return Colors.orange.withOpacity(0.3);
    if (level <= 6) return Colors.yellow.withOpacity(0.3);
    if (level <= 8) return Colors.lightGreen.withOpacity(0.3);
    return Colors.green.withOpacity(0.3);
  }

  Color _getMoodTextColor(int level) {
    if (level <= 2) return Colors.red[400]!;
    if (level <= 4) return Colors.orange[400]!;
    if (level <= 6) return Colors.yellow[700]!;
    if (level <= 8) return Colors.lightGreen[400]!;
    return Colors.green[400]!;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('Mood Tracker', style: AppTextStyles.headline1),
        backgroundColor: AppColors.secondary,
        elevation: 0,
      ),

      // 👉 BOTTOM NAV BAR ADDED HERE
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Mood Page
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomePage()),
              );
              break;
            case 1:
              break; // Already on Mood
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SleepTrackerPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => JournalTrackerPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => TherapistListPage()),
              );
              break;
          }
        },
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Mood Input Section
            Container(
              decoration: AppDecorations.glassCard,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 20),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.glass.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getMoodEmoji(_moodLevel),
                            style: TextStyle(fontSize: 48),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '$_moodLevel/10 - ${_getMoodDescription(_moodLevel)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getMoodTextColor(_moodLevel),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    Column(
                      children: [
                        Slider(
                          value: _moodLevel.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$_moodLevel',
                          onChanged: (value) =>
                              setState(() => _moodLevel = value.round()),
                          activeColor: AppColors.secondary,
                          inactiveColor: AppColors.glass,
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _notesController,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Notes (optional)',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          hintText: 'Any thoughts about your mood...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _notes = value,
                      ),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitMood,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Record Mood',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Recent Mood History',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),

            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _moodHistory.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(20),
                        decoration: AppDecorations.glassCard,
                        child: Column(
                          children: [
                            Icon(Icons.insights,
                                size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              'No mood data yet',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start tracking your mood to see insights here',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _moodHistory.length,
                        itemBuilder: (context, index) {
                          final mood = _moodHistory[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: AppDecorations.glassCard,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getMoodColor(mood.niveau),
                                child: Text(
                                  _getMoodEmoji(mood.niveau),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              title: Text(
                                '${mood.niveau}/10 - ${_getMoodDescription(mood.niveau)}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              subtitle: mood.notes.isNotEmpty
                                  ? Text(
                                      mood.notes,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    )
                                  : null,
                              trailing: Text(
                                '${mood.date.day}/${mood.date.month}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
