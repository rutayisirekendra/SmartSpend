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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';

class FinancialFactCard extends StatelessWidget {
  final String fact;
  final String author; // Add author field

  const FinancialFactCard({
    Key? key,
    required this.fact,
    this.author = "", // Default to empty string
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      color: AppTheme.getCardColor(context),
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Changed from lightbulb to dollar sign
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getAccentColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.getAccentColor(context)),
            ),
            child: Icon(Icons.attach_money_rounded, // Dollar sign icon
                size: 20, color: AppTheme.getAccentColor(context)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MONEY MANTRA',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getSecondaryTextColor(context),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                // Quote styling with italic and better typography
                Text(
                  '"$fact"', // Added quotation marks
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.getTextColor(context),
                    height: 1.5,
                    fontStyle: FontStyle.italic, // Italic for quote
                  ),
                ),
                // Author attribution (only if author is provided)
                if (author.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '— $author',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}