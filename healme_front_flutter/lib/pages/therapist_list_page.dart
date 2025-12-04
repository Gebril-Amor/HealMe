// lib/pages/therapist_list_page.dart
import 'package:flutter/material.dart';
import 'package:healme_front_flutter/pages/ai_chat_page.dart';
import 'package:healme_front_flutter/pages/anon_chat_page.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../models/therapist.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import 'chat_page.dart';
import '../widgets/bottom_nav_bar.dart';

class TherapistListPage extends StatefulWidget {
  @override
  _TherapistListPageState createState() => _TherapistListPageState();
}

class _TherapistListPageState extends State<TherapistListPage> {
  List<Therapist> _therapists = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTherapists();
  }

  Future<void> _loadTherapists() async {
    try {
      final therapists = await ApiService().getTherapists();
      
      // ✅ Filter only valid therapists with a linked user
      final validTherapists = therapists.where((t) => t.userId != null).toList();

      setState(() {
        _therapists = validTherapists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load therapists: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<Therapist> get _filteredTherapists {
    if (_searchQuery.isEmpty) return _therapists;
    return _therapists.where((therapist) =>
      therapist.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      therapist.specialty.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  Future<void> _shareTherapist(Therapist therapist) async {
    try {
      await Share.share(
        'Check out ${therapist.name} - ${therapist.specialty} specialist with years experience. '
        'Available for consultations on HealMe App!',
        subject: 'Therapist Recommendation: ${therapist.name}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share therapist info'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildTherapistCard(Therapist therapist) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                therapistId: therapist.userId!,
                therapist: therapist,
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
                // Therapist Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                
                // Therapist Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        therapist.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        therapist.specialty,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        therapist.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.share, size: 20, color: AppColors.textSecondary),
                      onPressed: () => _shareTherapist(therapist),
                      tooltip: 'Share therapist',
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.chat, size: 20, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                therapistId: therapist.userId!,
                                therapist: therapist,
                              ),
                            ),
                          );
                        },
                        tooltip: 'Start chat',
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
    return AppScaffold(
appBar: AppBar(
  title: Text(
    'Our Therapists',
    style: AppTextStyles.headline1,
  ),
  backgroundColor: AppColors.primary,
  elevation: 0,
  actions: [
    // AI Chat Button
    IconButton(
      icon: Icon(Icons.smart_toy, color: Colors.white),
      tooltip: "Talk to AI",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AiChatPage(),
          ),
        );
      },
    ),

    // Anonymous Chat Button
    IconButton(
      icon: Icon(Icons.group, color: Colors.white),
      tooltip: "Join Anonymous Chat",
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>  AnonChatPage(),
          ),
        );
      },
    ),
  ],
),

      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    decoration: AppDecorations.glassCard,
                    child: TextField(
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: 'Search therapists...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.glass.withOpacity(0.5),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredTherapists.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.psychology, size: 64, color: AppColors.textSecondary),
                              SizedBox(height: 16),
                              Text(
                                'No Therapists Found',
                                style: AppTextStyles.headline2.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No therapists available at the moment'
                                    : 'No therapists match your search',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredTherapists.length,
                          itemBuilder: (context, index) {
                            final therapist = _filteredTherapists[index];
                            return _buildTherapistCard(therapist);
                          },
                        ),
                ),
              ],
            ),
                       
  bottomNavigationBar: CustomBottomNavBar(
    currentIndex: 4, // Journal tab index
    onTap: (index) {
      if (index == 4) return; // Stay on journal page

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
        case 2:
          Navigator.pushReplacementNamed(context, '/sleep');
          break;
        default:
          return;
      }
    },
  ),
            
    );
  }
}