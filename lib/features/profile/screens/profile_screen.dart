import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/profile/screens/category_management_screen.dart'; // Add this import
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Profile Section --- //
          _buildProfileSection(context),
          const SizedBox(height: 24),

          // --- General Settings Section --- //
          _buildSection(
            title: 'General',
            children: [
              _buildSettingsTile(
                icon: Icons.category_outlined,
                title: 'Manage Categories',
                subtitle: 'Customize your expense categories',
                onTap: () {
                  // Navigate to Category Management Screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CategoryManagementScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Spending alerts and reminders',
                onTap: () {
                  // TODO: Navigate to Notification Settings Screen
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.backup_rounded,
                title: 'Backup & Sync',
                subtitle: 'Cloud backup and data synchronization',
                onTap: () {
                  // TODO: Navigate to Backup Settings Screen
                  _showComingSoonSnackbar(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Appearance Section --- //
          _buildSection(
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                value: false, // Placeholder - Theme logic to be added
                onChanged: (value) {
                  // TODO: Implement theme switching logic
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.palette_rounded,
                title: 'Theme Customization',
                subtitle: 'Choose your preferred color scheme',
                onTap: () {
                  // TODO: Navigate to Theme Settings
                  _showComingSoonSnackbar(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Data Management Section --- //
          _buildSection(
            title: 'Data Management',
            children: [
              _buildSettingsTile(
                icon: Icons.analytics_rounded,
                title: 'Export Data',
                subtitle: 'Download your expense reports',
                onTap: () {
                  // TODO: Implement data export
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.restore_rounded,
                title: 'Clear Data',
                subtitle: 'Reset all your expense records',
                onTap: () {
                  // TODO: Implement data clearing
                  _showComingSoonSnackbar(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- About Section --- //
          _buildSection(
            title: 'About',
            children: [
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'Version',
                subtitle: '1.0.0',
              ),
              _buildSettingsTile(
                icon: Icons.star_rounded,
                title: 'Rate App',
                subtitle: 'Share your feedback with us',
                onTap: () {
                  // TODO: Link to app store
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.share_rounded,
                title: 'Share App',
                subtitle: 'Share with friends and family',
                onTap: () {
                  // TODO: Implement share functionality
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // TODO: Link to privacy policy URL
                  _showComingSoonSnackbar(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.description_rounded,
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                onTap: () {
                  // TODO: Link to terms of service
                  _showComingSoonSnackbar(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // --- Sign Out Button --- //
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showSignOutConfirmation(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'SIGN OUT',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthService>().signOut();
              // Pop all routes until the auth checker, taking user back to login
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'SIGN OUT',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.construction_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Feature coming soon! 🚀'),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final userName = user?.displayName ?? 'User';
    final userEmail = user?.email ?? 'user@email.com';
    final theme = Theme.of(context);

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryTeal, Color(0xFF4ECDC4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Premium User',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppTheme.accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to Edit Profile Screen
              _showComingSoonSnackbar(context);
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_rounded, color: AppTheme.primaryTeal),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
        ),
        ModernCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.darkGrey,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ) : null,
      trailing: onTap != null ? Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.chevron_right_rounded, color: Colors.grey[500], size: 20),
      ) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryTeal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryTeal, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.darkGrey,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentOrange,
        activeTrackColor: AppTheme.accentOrange.withOpacity(0.3),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}