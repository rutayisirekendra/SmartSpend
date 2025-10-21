import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// FIX: Changed import from glass_card.dart to our new modern_card.dart
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';

class BudgetSummaryCard extends StatelessWidget {
  const BudgetSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - this will come from your database later
    final double budget = 2000.00;
    final double spent = 1231.95;
    final double remaining = budget - spent;
    final double percentage = spent / budget;

    // FIX: Using the new ModernCard widget
    return ModernCard(
      color: AppTheme.primaryTeal.withOpacity(0.05),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Budget',
            style: GoogleFonts.poppins(
              // FIX: Changed text color for readability
                color: AppTheme.darkGrey.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${spent.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              // FIX: Changed text color for readability
              color: AppTheme.darkGrey,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: AppTheme.primaryTeal.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\$${remaining.toStringAsFixed(2)} remaining',
              style: GoogleFonts.poppins(
                // FIX: Changed text color for readability
                color: AppTheme.darkGrey.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ),
          const Divider(color: Colors.black12, height: 40),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Categories',
                      style: GoogleFonts.poppins(
                        // FIX: Changed text color for readability
                          color: AppTheme.darkGrey.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryIndicator(Colors.cyan, 'Food & Drink'),
                    _buildCategoryIndicator(Colors.amber, 'Shopping'),
                    _buildCategoryIndicator(Colors.pink, 'Transport'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 100,
                  width: 100,
                  child: PieChart(
                    PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 25,
                        sections: [
                          PieChartSectionData(value: 40, color: Colors.cyan, showTitle: false, radius: 20),
                          PieChartSectionData(value: 30, color: Colors.amber, showTitle: false, radius: 20),
                          PieChartSectionData(value: 15, color: Colors.pink, showTitle: false, radius: 20),
                          PieChartSectionData(value: 15, color: Colors.green, showTitle: false, radius: 20),
                        ]
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryIndicator(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // FIX: Changed text color for readability
          Text(text, style: GoogleFonts.poppins(color: AppTheme.darkGrey, fontSize: 14)),
        ],
      ),
    );
  }
}

