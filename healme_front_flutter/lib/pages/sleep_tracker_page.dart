// lib/pages/sleep_tracker_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/sleep.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/bottom_nav_bar.dart';
class SleepTrackerPage extends StatefulWidget {
  @override
  _SleepTrackerPageState createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  final List<Sleep> _sleepHistory = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  // Form data
  double _sleepHours = 7.0;
  String _sleepQuality = 'good';
  final TextEditingController _notesController = TextEditingController();

  final Map<String, String> _qualityOptions = {
    'excellent': '😊 Excellent',
    'good': '🙂 Good', 
    'fair': '😐 Fair',
    'poor': '😔 Poor',
  };

  @override
  void initState() {
    super.initState();
    _loadSleepHistory();
  }

  Future<void> _loadSleepHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;
    
    if (userId == null) return;

    try {
      final sleepData = await ApiService().getUserSleep(userId);
      setState(() {
        _sleepHistory.clear();
        _sleepHistory.addAll(sleepData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitSleep() async {
    if (_isSubmitting) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to track sleep'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService().addSleep({
        'dureeHeures': _sleepHours,
        'qualite': _sleepQuality,
        'date': DateTime.now().toIso8601String().split('T')[0],
        'patient': userId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sleep recorded successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset form
      setState(() {
        _sleepHours = 7.0;
        _sleepQuality = 'good';
        _notesController.clear();
      });

      // Reload history
      _loadSleepHistory();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to record sleep: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _getSleepEmoji(String quality) {
    switch (quality) {
      case 'excellent': return '😊';
      case 'good': return '🙂';
      case 'fair': return '😐';
      case 'poor': return '😔';
      default: return '😐';
    }
  }

  Color _getSleepColor(String quality) {
    switch (quality) {
      case 'excellent': return Colors.green.withOpacity(0.3);
      case 'good': return Colors.lightGreen.withOpacity(0.3);
      case 'fair': return Colors.yellow.withOpacity(0.3);
      case 'poor': return Colors.red.withOpacity(0.3);
      default: return Colors.grey.withOpacity(0.3);
    }
  }

  Color _getSleepTextColor(String quality) {
    switch (quality) {
      case 'excellent': return Colors.green[400]!;
      case 'good': return Colors.lightGreen[400]!;
      case 'fair': return Colors.yellow[700]!;
      case 'poor': return Colors.red[400]!;
      default: return Colors.grey[400]!;
    }
  }

  Widget _buildQualityChip(String key, String value) {
    final isSelected = _sleepQuality == key;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _sleepQuality = key;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.tertiary],
                  )
                : null,
            color: isSelected ? null : AppColors.glass.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Sleep Tracker',
          style: AppTextStyles.headline1,
        ),
        backgroundColor: AppColors.tertiary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep Input Section
            Container(
              decoration: AppDecorations.glassCard,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'How did you sleep last night?',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Sleep Hours
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
                            '$_sleepHours hours',
                            style: AppTextStyles.headline1.copyWith(
                              color: AppColors.tertiary,
                              fontSize: 28,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _sleepHours >= 7 ? 'Good duration! 🎉' : 'Consider getting more sleep',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Sleep Hours Slider
                    Column(
                      children: [
                        Slider(
                          value: _sleepHours,
                          min: 0,
                          max: 12,
                          divisions: 24,
                          label: '$_sleepHours hours',
                          onChanged: (value) {
                            setState(() {
                              _sleepHours = value;
                            });
                          },
                          activeColor: AppColors.tertiary,
                          inactiveColor: AppColors.glass,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('0h', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                            Text('12h', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    
                    // Sleep Quality
                    Text(
                      'Sleep Quality',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _qualityOptions.entries.map((entry) {
                        return _buildQualityChip(entry.key, entry.value);
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitSleep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Record Sleep',
                                style: AppTextStyles.button,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Sleep History
            Text(
              'Recent Sleep History',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : _sleepHistory.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(20),
                        decoration: AppDecorations.glassCard,
                        child: Column(
                          children: [
                            Icon(Icons.bedtime_outlined, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              'No sleep data yet',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start tracking your sleep to see insights here',
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
                        itemCount: _sleepHistory.length,
                        itemBuilder: (context, index) {
                          final sleep = _sleepHistory[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: AppDecorations.glassCard,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getSleepColor(sleep.quality),
                                child: Text(
                                  _getSleepEmoji(sleep.quality),
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              title: Text(
                                '${sleep.hours} hours',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                              subtitle: Text(
                                _qualityOptions[sleep.quality] ?? sleep.quality,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: _getSleepTextColor(sleep.quality),
                                ),
                              ),
                              trailing: Text(
                                '${sleep.date.day}/${sleep.date.month}',
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
           
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: 2, // Journal tab index
    onTap: (index) {
      if (index == 2) return; // Stay on journal page

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/mood');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/journal');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/therapists');
          break;
        default:
          return;
      }
    },
  ),
    );
  }
}