// lib/pages/home_page.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:healme_front_flutter/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/mood.dart';
import '../models/sleep.dart';
import '../models/journal.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import 'therapist_list_page.dart';
import 'mood_tracker_page.dart';
import 'sleep_tracker_page.dart';
import 'therapist_home_page.dart';
import 'journal_tracker_page.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _moodInsight = '';
  String _sleepInsight = '';
  String _journalInsight = '';
  bool _insightsLoading = true;
  List<Mood> _recentMoods = [];
  List<Sleep> _recentSleep = [];
  List<Journal> _recentJournals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }

  Future<void> _loadRecentData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;

    if (userId == null) return;

    try {
      // Load all data first
      final allMoods = await ApiService().getUserMood(userId);
      final allSleep = await ApiService().getUserSleep(userId);
      final allJournals = await ApiService().getUserJournal(userId);

      setState(() {
        // Get last 5 moods
        _recentMoods = allMoods.take(5).toList();
        // Get last 7 sleep entries for graph
        _recentSleep = allSleep.take(7).toList();
        // Get last journal entry
        _recentJournals = allJournals.take(1).toList();
        _isLoading = false;
      });

      // Then load insights separately
      try {
        final moodInsight = await ApiService().getUserMoodInsight(userId);
        final sleepInsight = await ApiService().getUserSleepInsight(userId);
        final journalInsight = await ApiService().getUserJournalInsight(userId);

        setState(() {
          _moodInsight = moodInsight;
          _sleepInsight = sleepInsight;
          _journalInsight = journalInsight;
          _insightsLoading = false;
        });
      } catch (e) {
        print('Failed to load insights: $e');
        setState(() {
          _insightsLoading = false;
        });
      }

    } catch (e) {
      print('Failed to load data: $e');
      setState(() {
        _isLoading = false;
        _insightsLoading = false;
      });
    }
  }

  String _getMoodEmoji(int level) {
    if (level <= 2) return '😢';
    if (level <= 4) return '😔';
    if (level <= 6) return '😐';
    if (level <= 8) return '😊';
    return '😄';
  }

  Widget _buildMoodCard() {
    return Container(
      decoration: AppDecorations.glassCard,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mood, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Mood',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoodTrackerPage()),
                    );
                  },
                  child: Text(
                    'See All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_recentMoods.isEmpty)
              Text(
                'No mood data yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                children: _recentMoods.map((mood) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          _getMoodEmoji(mood.niveau),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${mood.niveau}/10',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        Text(
                          '${mood.date.day}/${mood.date.month}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            
            // Mood Insight
            if (_recentMoods.isNotEmpty && _moodInsight.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights, size: 16, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _moodInsight,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_recentMoods.isNotEmpty && _insightsLoading) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Analyzing your mood patterns...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSleepGraph() {
    if (_recentSleep.isEmpty) {
      return Container(
        decoration: AppDecorations.glassCard,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bedtime, color: AppColors.tertiary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Sleep History',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SleepTrackerPage()),
                      );
                    },
                    child: Text(
                      'Track Sleep',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'No sleep data yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by date
    _recentSleep.sort((a, b) => a.date.compareTo(b.date));

    return Container(
      decoration: AppDecorations.glassCard,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime, color: AppColors.tertiary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sleep History',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SleepTrackerPage()),
                    );
                  },
                  child: Text(
                    'See All',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            // Line Chart
            Container(
              height: 150,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: AppColors.textSecondary.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < _recentSleep.length) {
                            final sleep = _recentSleep[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '${sleep.date.day}/${sleep.date.month}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  minX: 0,
                  maxX: (_recentSleep.length - 1).toDouble(),
                  minY: 0,
                  maxY: _recentSleep.map((e) => e.hours).reduce((a, b) => a > b ? a : b).ceilToDouble() + 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _recentSleep.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.hours);
                      }).toList(),
                      isCurved: true,
                      color: AppColors.tertiary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.tertiary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.tertiary.withOpacity(0.3),
                            AppColors.tertiary.withOpacity(0.1),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last ${_recentSleep.length} days',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Goal: 7-9h',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ),
              ],
            ),

            // Sleep Insight
            if (_recentSleep.isNotEmpty && _sleepInsight.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.tertiary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights, size: 16, color: AppColors.tertiary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _sleepInsight,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_recentSleep.isNotEmpty && _insightsLoading) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.tertiary,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Analyzing your sleep patterns...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard() {
    return Container(
      decoration: AppDecorations.glassCard,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.book, color: AppColors.quadra, size: 20),
                SizedBox(width: 8),
                Text(
                  'Latest Journal',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JournalTrackerPage()),
                    );
                  },
                  child: Text(
                    'Write',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (_recentJournals.isEmpty)
              Text(
                'No journal entries yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _recentJournals.first.date.toIso8601String().split('T').first,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    _recentJournals.first.contenu.length > 100
                        ? '${_recentJournals.first.contenu.substring(0, 100)}...'
                        : _recentJournals.first.contenu,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_recentJournals.first.date.day}/${_recentJournals.first.date.month}/${_recentJournals.first.date.year}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

            // Journal Insight
            if (_recentJournals.isNotEmpty && _journalInsight.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.quadra.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.quadra.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insights, size: 16, color: AppColors.quadra),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _journalInsight,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_recentJournals.isNotEmpty && _insightsLoading) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.quadra.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.quadra,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Analyzing your journal entries...',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Redirect therapists to therapist home
    if (user.userType == 'therapeute') {
      return TherapistHomePage();
    }

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'HealMe',
          style: AppTextStyles.headline1.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF64FF),
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Welcome Section
            Container(
              decoration: AppDecorations.glassCard,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome back,',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.username,
                      style: AppTextStyles.headline1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Data Overview Section
            Text(
              'Your Overview',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: 16),

            // Data Cards
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : ListView(
                      children: [
                        _buildMoodCard(),
                        SizedBox(height: 16),
                        _buildSleepGraph(),
                        SizedBox(height: 16),
                        _buildJournalCard(),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MoodTrackerPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SleepTrackerPage()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TherapistListPage()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TherapistListPage()),
              );
              break;
          }
        },
      ),
    );
  }
}