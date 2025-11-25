import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/auth/widgets/auth_form_field.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

import '../../../common_widgets/primary_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.updateUserProfile(
        fullName: _nameController.text.trim(),
        imageFile: _selectedImage,
      );
      
      if (mounted) {
        // Pop with true to indicate successful update
        Navigator.of(context).pop(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: AppTheme.getGlassmorphicHeaderDecoration(context),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.getHeaderIconBackground(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.getHeaderTextColor(context),
                      ),
                      style: IconButton.styleFrom(padding: EdgeInsets.all(8)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Picture Card
                      ModernCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              'Profile Picture',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 70,
                                    backgroundColor: isDark
                                        ? AppTheme.darkCard
                                        : AppTheme.getPrimaryColor(context).withOpacity(0.1),
                                    backgroundImage: _selectedImage != null
                                        ? FileImage(_selectedImage!)
                                        : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null)
                                    as ImageProvider?,
                                    child: (_selectedImage == null && user?.photoURL == null)
                                        ? Text(
                                      user?.displayName?.isNotEmpty ?? false 
                                          ? user!.displayName![0].toUpperCase() 
                                          : 'U',
                                      style: GoogleFonts.poppins(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.getPrimaryColor(context),
                                      ),
                                    )
                                        : null,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _pickImage,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppTheme.getPrimaryColor(context),
                                              AppTheme.getPrimaryColor(context).withOpacity(0.8),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.getPrimaryColor(context).withOpacity(0.5),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt_rounded, 
                                          color: Colors.white, 
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tap the camera icon to change',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.getSecondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Profile Information Card
                      ModernCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: AppTheme.getPrimaryColor(context),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Profile Information',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Full Name Field
                            Text(
                              'FULL NAME',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getSecondaryTextColor(context),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppTheme.getTextColor(context),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter your full name',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.getSecondaryTextColor(context).withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: AppTheme.getPrimaryColor(context),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppTheme.getPrimaryColor(context),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) => 
                                  (value?.isEmpty ?? true) ? 'Please enter your name' : null,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Email Field (Read-only)
                            Text(
                              'EMAIL ADDRESS',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getSecondaryTextColor(context),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.03)
                                    : Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      user?.email ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: AppTheme.getSecondaryTextColor(context),
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: AppTheme.getSecondaryTextColor(context).withOpacity(0.5),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: AppTheme.getSecondaryTextColor(context).withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Email cannot be changed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.getSecondaryTextColor(context).withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Save Button
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.getPrimaryColor(context),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.getPrimaryColor(context),
                                        AppTheme.getPrimaryColor(context).withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.getPrimaryColor(context).withOpacity(0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.save_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Save Changes',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

