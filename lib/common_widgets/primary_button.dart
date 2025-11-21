// import 'package:flutter/material.dart';
// import 'package:smart_expense_tracker/app/theme/app_theme.dart';
//
// class PrimaryButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;
//   final IconData? icon;
//   final Color backgroundColor;
//   final Color foregroundColor;
//
//   const PrimaryButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//     this.isLoading = false,
//     this.icon,
//     this.backgroundColor = AppTheme.accentOrange,
//     this.foregroundColor = Colors.white,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isLoading ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           foregroundColor: foregroundColor,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 2,
//         ),
//         child: isLoading
//             ? const SizedBox(
//           height: 24,
//           width: 24,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 3,
//           ),
//         )
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (icon != null) ...[
//               Icon(icon, size: 20),
//               SizedBox(width: 8),
//             ],
//             Text(
//               text,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool buttonEnabled = isEnabled && !isLoading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: buttonEnabled 
          ? AppTheme.getGradientButtonDecoration()
          : BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(16),
            ),
      child: ElevatedButton(
        onPressed: buttonEnabled ? onPressed : null,
        style: AppTheme.getGradientButtonStyle(),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}