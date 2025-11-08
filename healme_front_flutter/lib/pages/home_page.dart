// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:healme_front_flutter/pages/login_page.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/background_bubbles.dart';
import '../widgets/app_scaffold.dart';
import 'therapist_list_page.dart';
import 'mood_tracker_page.dart';
import 'sleep_tracker_page.dart';
import 'therapist_home_page.dart';
import 'journal_tracker_page.dart';
import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatelessWidget {
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
                    SizedBox(height: 8),
                    Text(
                      'How are you feeling today?',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTextStyles.headline2,
            ),
            SizedBox(height: 16),

            // Action Grid
            Expanded(
              child: GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                children: [
                  // Therapists Card
                  _buildActionCard(
                    icon: Icons.people,
                    title: 'Therapists',
                    subtitle: 'Chat with professionals',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TherapistListPage()),
                      );
                    },
                  ),

                  // Mood Tracking Card
                  _buildActionCard(
                    icon: Icons.mood,
                    title: 'Mood Tracker',
                    subtitle: 'Log your emotions',
                    color: AppColors.secondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MoodTrackerPage()),
                      );
                    },
                  ),

                  // Sleep Tracking Card
                  _buildActionCard(
                    icon: Icons.bedtime,
                    title: 'Sleep Tracker',
                    subtitle: 'Monitor your sleep',
                    color: AppColors.tertiary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SleepTrackerPage()),
                      );
                    },
                  ),

                  // Journal Card
                  _buildActionCard(
                    icon: Icons.book,
                    title: 'Journal',
                    subtitle: 'Write your thoughts',
                    color: AppColors.quadra,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JournalTrackerPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ), bottomNavigationBar: CustomBottomNavBar( // ← ADD THIS
    currentIndex: 0, // Home is first item
    onTap: (index) {
      // Add navigation logic here
      switch (index) {
        case 0:
          // Already on home page
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
  ),    );
  }

  Widget _buildActionCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
  required VoidCallback onTap,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: AppDecorations.glassCard,
        child: Container(
          padding: EdgeInsets.all(12), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10), // Reduced icon padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(icon, size: 24, color: color), // Smaller icon
              ),
              SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith( // Use smaller text
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2), // Minimal spacing
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith( // Use smallest text
                  color: AppColors.textSecondary,
                  fontSize: 10, // Even smaller font size
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Allow 2 lines for subtitle
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}