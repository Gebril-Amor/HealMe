// lib/pages/journal_tracker_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/journal.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';

class JournalTrackerPage extends StatefulWidget {
  const JournalTrackerPage({super.key});

  @override
  _JournalTrackerPageState createState() => _JournalTrackerPageState();
}

class _JournalTrackerPageState extends State<JournalTrackerPage> {
  final List<Journal> _journalHistory = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  
  // Form data
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJournalHistory();
  }

  Future<void> _loadJournalHistory() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;
    
    if (userId == null) return;

    try {
      final journals = await ApiService().getUserJournal(userId);
      setState(() {
        _journalHistory.clear();
        _journalHistory.addAll(journals);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitJournal() async {
    if (_isSubmitting) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.id;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login to add journal entry'),
          backgroundColor: AppColors.quadra,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please write something in your journal'),
          backgroundColor: AppColors.quadra,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService().addJournal({
        'patient': userId,
        'contenu': _contentController.text.trim(),
        'date': DateTime.now().toIso8601String().split('T')[0],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Journal entry saved successfully!'),
          backgroundColor: AppColors.quadra,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Reset form
      _contentController.clear();

      // Reload history
      _loadJournalHistory();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save journal: $e'),
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

  Widget _buildJournalEntry(Journal journal) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12),
        decoration: AppDecorations.glassCard,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${journal.date.day}/${journal.date.month}/${journal.date.year}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.quadra,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.book, color: Colors.white, size: 12),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                journal.contenu,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.text,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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
          'Journal',
          style: AppTextStyles.headline1,
        ),
        backgroundColor: AppColors.quadra,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journal Input Section
            Container(
              decoration: AppDecorations.glassCard,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Write in your Journal',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Content
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _contentController,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: 'Write your thoughts...',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          hintText: 'Express your feelings, thoughts, or experiences...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        maxLines: 8,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitJournal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.quadra,
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
                                'Save Journal Entry',
                                style: AppTextStyles.button,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // Journal History
            Text(
              'Recent Journal Entries',
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.text,
              ),
            ),
            SizedBox(height: 16),
            
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppColors.quadra),
                  )
                : _journalHistory.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(20),
                        decoration: AppDecorations.glassCard,
                        child: Column(
                          children: [
                            Icon(Icons.book, size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text(
                              'No journal entries yet',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start writing to reflect on your thoughts and feelings',
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
                        itemCount: _journalHistory.length,
                        itemBuilder: (context, index) {
                          final journal = _journalHistory[index];
                          return _buildJournalEntry(journal);
                        },
                      ),
          ],
        ),
      ),
    );
  }
}