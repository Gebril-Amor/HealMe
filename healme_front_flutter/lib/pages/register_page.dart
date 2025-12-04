// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_decorations.dart';
import '../widgets/app_scaffold.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedUserType = 'patient';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return AppScaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              // Header
              Text(
                'Join HealMe',
                style: AppTextStyles.headline1.copyWith(
                  foreground: Paint()
                    ..shader = AppColors.textGradient.createShader(
                      Rect.fromLTWH(0, 0, 200, 70),
                    ),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your account to get started',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 40),

              // Form Container
              Container(
                decoration: AppDecorations.glassCard,
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      
                      TextFormField(
                        controller: _usernameController,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.person, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.email, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                               SizedBox(height: 20),                // User Type Selection
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.glass.withOpacity(0.5),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUserType,
                            isExpanded: true,
                            dropdownColor: AppColors.glass,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                            items: [
                              DropdownMenuItem(
                                value: 'patient',
                                child: Text('Patient'),
                              ),
                              DropdownMenuItem(
                                value: 'therapeute',
                                child: Text('Therapist'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedUserType = value!;
                              });
                            },
                          ),
                        ),
                      ),
                   
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.lock, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.text),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.textSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          filled: true,
                          fillColor: AppColors.glass.withOpacity(0.5),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authService.isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: authService.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: AppTextStyles.button,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    authService.setLoading(true);

    try {
      final response = await ApiService().register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedUserType,
      );

      final user = User.fromJson(response['user']);
      await authService.saveUser(user);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      authService.setLoading(false);
    }
  }
}