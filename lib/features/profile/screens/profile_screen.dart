import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/app/theme/theme_provider.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/features/profile/screens/category_management_screen.dart';
import 'package:smart_expense_tracker/features/profile/screens/edit_profile_screen.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'package:smart_expense_tracker/services/session_service.dart';
import 'package:smart_expense_tracker/services/data_cleanup_service.dart';
import 'package:smart_expense_tracker/services/data_cleanup_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Custom Glassmorphic Header
            _buildGlassmorphicHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- Profile Section --- //
                  _buildProfileSection(context),
                  const SizedBox(height: 24),

                  // --- General Settings Section --- //
                  _buildSection(
                    context: context,
                    title: 'General',
                    children: [
                      _buildSettingsTile(
                        context: context,
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
                        context: context,
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Spending alerts and reminders',
                        onTap: () {
                          // TODO: Navigate to Notification Settings Screen
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.backup_rounded,
                        title: 'Backup & Sync',
                        subtitle: 'Cloud backup and data synchronization',
                        onTap: () {
                          // TODO: Navigate to Backup Settings Screen
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      if (kDebugMode)
                        _buildSettingsTile(
                          context: context,
                          icon: Icons.storage_rounded,
                          title: 'Data Management (Debug)',
                          subtitle: 'View and manage local data',
                          onTap: () => _showDataManagementDialog(context),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Appearance Section --- //
                  _buildSection(
                    context: context,
                    title: 'Appearance',
                    children: [
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return _buildSwitchTile(
                            context: context,
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Enable dark theme',
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        value ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(value ? 'Dark mode enabled' : 'Light mode enabled'),
                                    ],
                                  ),
                                  backgroundColor: AppTheme.getPrimaryColor(context),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),                                );
                            },
                          );
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
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
                    context: context,
                    title: 'Data Management',
                    children: [
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.analytics_rounded,
                        title: 'Export Data',
                        subtitle: 'Download your expense reports',
                        onTap: () {
                          // TODO: Implement data export
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
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
                    context: context,
                    title: 'About',
                    children: [
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.info_outline_rounded,
                        title: 'Version',
                        subtitle: '1.0.0',
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.star_rounded,
                        title: 'Rate App',
                        subtitle: 'Share your feedback with us',
                        onTap: () {
                          // TODO: Link to app store
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.share_rounded,
                        title: 'Share App',
                        subtitle: 'Share with friends and family',
                        onTap: () {
                          // TODO: Implement share functionality
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {
                          // TODO: Link to privacy policy URL
                          _showComingSoonSnackbar(context);
                        },
                      ),
                      _buildSettingsTile(
                        context: context,
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
                          color: Colors.redAccent.withValues(alpha: 0.3),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: AppTheme.getGlassmorphicHeaderDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button and Title Row
          Row(
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
                    color: AppTheme.getHeaderTextColor(context)
                  ),
                  style: IconButton.styleFrom(padding: EdgeInsets.all(8)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile & Settings',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage your account and preferences',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSignOutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out? You will need to sign in again to access your data.',
          style: GoogleFonts.poppins(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Signing out...',
                          style: GoogleFonts.poppins(
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              try {
                // Navigate to onboarding FIRST (before signing out)
                // This prevents the AuthChecker from briefly showing the login screen
                if (context.mounted) {
                  // Close the loading dialog
                  Navigator.of(context).pop();
                  
                  // Navigate to onboarding and remove all previous routes
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/onboarding',
                    (route) => false,
                  );
                }
                
                // Clear any local data/cache if needed
                await _clearLocalData();
                
                // Sign out from Firebase (this will also clear session data)
                // This happens AFTER navigation so user doesn't see the flash
                await context.read<AuthService>().signOut();
                
              } catch (e) {
                // Close loading dialog if still showing
                if (context.mounted) {
                  Navigator.of(context).pop();
                  
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: AppTheme.getErrorColor(context),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'SIGN OUT',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getErrorColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearLocalData() async {
    try {
      // SessionService.clearUserSession() will be called by AuthService.signOut()
      // but we can do additional cleanup here if needed
      
      // Optional: Clear other app-specific data that should be reset on logout
      // For example, clear any cached data, reset app state, etc.
      
      print('Local data cleared successfully');
    } catch (e) {
      print('Error clearing local data: $e');
    }
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
        backgroundColor: AppTheme.getPrimaryTealColor(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showDataManagementDialog(BuildContext context) async {
    final currentUserId = context.read<AuthService>().currentUser?.uid;
    final stats = await DataCleanupService.getDataStatistics(currentUserId);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.storage_rounded, color: AppTheme.getPrimaryColor(context)),
            SizedBox(width: 8),
            Text(
              'Data Management',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current User Data',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),
              SizedBox(height: 8),
              _buildStatItem('Budgets', stats['userBudgets'].toString(), stats['otherBudgets'].toString()),
              _buildStatItem('Expenses', stats['userExpenses'].toString(), stats['otherExpenses'].toString()),
              _buildStatItem('Notes', stats['userNotes'].toString(), stats['otherNotes'].toString()),
              _buildStatItem('Goals', stats['userGoals'].toString(), stats['otherGoals'].toString()),
              SizedBox(height: 16),
              if (stats['otherBudgets'] > 0 || stats['otherExpenses'] > 0 || 
                  stats['otherNotes'] > 0 || stats['otherGoals'] > 0)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data from other users detected',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          if (stats['otherBudgets'] > 0 || stats['otherExpenses'] > 0 || 
              stats['otherNotes'] > 0 || stats['otherGoals'] > 0)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                _showCleanupConfirmation(context, currentUserId!);
              },
              child: Text(
                'CLEANUP',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CLOSE',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String userCount, String otherCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          Text(
            '$userCount (yours) / $otherCount (others)',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: otherCount != '0' ? Colors.orange : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCleanupConfirmation(BuildContext context, String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Cleanup Data?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        content: Text(
          'This will remove all data that doesn\'t belong to your account. Your data will not be affected.',
          style: GoogleFonts.poppins(
            color: AppTheme.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cleaning up...',
                          style: GoogleFonts.poppins(
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
              
              await DataCleanupService.cleanupOrphanedData(userId);
              
              if (context.mounted) {
                Navigator.of(context).pop(); // Close loading
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Data cleaned up successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                
                // Refresh the UI
                setState(() {});
              }
            },
            child: Text(
              'CLEANUP',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final userName = user?.displayName ?? 'User';
    final userEmail = user?.email ?? 'user@email.com';

    return ModernCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.getPrimaryTealColor(context), Color(0xFF4ECDC4)],
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
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userEmail,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              // Navigate to Edit Profile Screen and wait for result
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(),
                ),
              );
              
              // If profile was updated, refresh the UI
              if (result == true && mounted) {
                setState(() {
                  // Force rebuild to show updated profile info
                });
              }
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryTealColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_rounded, color: AppTheme.getPrimaryTealColor(context)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required List<Widget> children}) {
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
              color: AppTheme.getSecondaryTextColor(context),
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

  Widget _buildSettingsTile({required BuildContext context, required IconData icon, required String title, String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.getPrimaryTealColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.getPrimaryTealColor(context), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextColor(context),
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ) : null,
      trailing: onTap != null ? Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.chevron_right_rounded, color: AppTheme.getSecondaryTextColor(context), size: 20),
      ) : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSwitchTile({required BuildContext context, required IconData icon, required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.getPrimaryTealColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.getPrimaryTealColor(context), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextColor(context),
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppTheme.getSecondaryTextColor(context),
        ),
      ) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.getOriginalAccentColor(context),
        activeTrackColor: AppTheme.getOriginalAccentColor(context).withOpacity(0.3),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
