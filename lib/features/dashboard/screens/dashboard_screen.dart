import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/budget_summary_card.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/financial_fact_card.dart';
import 'package:smart_expense_tracker/features/dashboard/widgets/quick_actions_card.dart';
import 'package:smart_expense_tracker/features/notifications/screens/notification_screen.dart';
import 'package:smart_expense_tracker/features/profile/screens/profile_screen.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? 'User';

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Custom Header --- //
            _buildHeader(context, userName),
            const SizedBox(height: 24),

            // --- Budget "Hero" Card --- //
            const BudgetSummaryCard(),
            const SizedBox(height: 24),

            // --- Money Mantra Card --- //
            const FinancialFactCard(),
            const SizedBox(height: 24),

            // --- Quick Actions Section --- //
            Text(
              "Quick Actions",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            const QuickActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, ${userName.split(' ').first}', // Show only the first name
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            Text(
              'Welcome back!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: Icon(Icons.notifications_none_rounded, color: Colors.grey[700], size: 28),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: AppTheme.accentOrange,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

