// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// // import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
// //
// // class FinancialFactCard extends StatelessWidget {
// //   const FinancialFactCard({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return ModernCard(
// //       color: AppTheme.accentOrange.withOpacity(0.08),
// //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: AppTheme.accentOrange.withOpacity(0.2),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: const Icon(
// //                   // FIX: Changed icon to a money-related one as requested.
// //                   Icons.monetization_on_outlined,
// //                   color: AppTheme.accentOrange,
// //                   size: 24,
// //                 ),
// //               ),
// //               const SizedBox(width: 12),
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Money Mantra',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: AppTheme.darkGrey,
// //                     ),
// //                   ),
// //                   Text(
// //                     'Stay motivated and focused',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 12,
// //                       color: AppTheme.darkGrey.withOpacity(0.6),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 20),
// //           Container(
// //             width: double.infinity,
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(15),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.grey.withOpacity(0.05),
// //                   blurRadius: 20,
// //                   offset: const Offset(0, 5),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   '"Do not save what is left after spending, but spend what is left after saving."',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 15,
// //                     fontWeight: FontWeight.w500,
// //                     color: AppTheme.darkGrey.withOpacity(0.8),
// //                     fontStyle: FontStyle.italic,
// //                     height: 1.5,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Align(
// //                   alignment: Alignment.centerRight,
// //                   child: Text(
// //                     '— Warren Buffett',
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 12,
// //                       color: AppTheme.darkGrey.withOpacity(0.5),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
//
// class FinancialFactCard extends StatelessWidget {
//   // --- MODIFIED: Accept a fact string ---
//   final String fact;
//
//   const FinancialFactCard({
//     Key? key,
//     required this.fact,
//   }) : super(key: key);
//   // --- END MODIFIED ---
//
//   @override
//   Widget build(BuildContext context) {
//     return ModernCard(
//       padding: EdgeInsets.all(20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppTheme.accentOrange.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: AppTheme.accentOrange),
//             ),
//             child: Icon(Icons.lightbulb_rounded,
//                 size: 20, color: AppTheme.accentOrange),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'MONEY MANTRA',
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[600],
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 // --- MODIFIED: Use dynamic fact string ---
//                 Text(
//                   fact,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: AppTheme.darkGrey,
//                     height: 1.5,
//                   ),
//                 ),
//                 // --- END MODIFIED ---
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/glassmorphic_card.dart';

class FinancialFactCard extends StatelessWidget {
  final String fact;
  final String author;

  const FinancialFactCard({
    Key? key,
    required this.fact,
    this.author = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Match the exact colors from the screenshots
    final cardBgColor = isDark 
        ? const Color(0xFF4A3A2F) // Dark brown from dark mode screenshot
        : const Color(0xFFE8D5C4); // Light peachy beige from light mode screenshot
    
    final iconBgColor = isDark
        ? const Color(0xFF6B4423).withOpacity(0.6) // Darker brown for icon
        : const Color(0xFFD4A574).withOpacity(0.4); // Medium tan
    
    final iconColor = isDark
        ? const Color(0xFFFFB74D) // Light orange
        : const Color(0xFFE67E22); // Deeper orange
    
    final quoteBoxBg = isDark
        ? Colors.black.withOpacity(0.25) // Dark semi-transparent
        : Colors.white.withOpacity(0.8); // Light semi-transparent white
    
    final titleColor = isDark
        ? Colors.white // White in dark mode
        : const Color(0xFF2C2C2C); // Dark gray/black in light mode
    
    final subtitleColor = isDark
        ? Colors.white.withOpacity(0.65) // Semi-transparent white in dark
        : const Color(0xFF6B6B6B); // Gray in light mode
    
    final quoteTextColor = isDark
        ? Colors.white.withOpacity(0.95) // Bright white in dark
        : const Color(0xFF2C2C2C); // Dark text in light mode
    
    final authorColor = isDark
        ? Colors.white.withOpacity(0.55) // Dim white in dark
        : const Color(0xFF8B8B8B); // Gray in light mode
    
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.attach_money_rounded,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Money Mantra',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      'Stay motivated and focused',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Quote box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: quoteBoxBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$fact"',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: quoteTextColor,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (author.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '— $author',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: authorColor,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}