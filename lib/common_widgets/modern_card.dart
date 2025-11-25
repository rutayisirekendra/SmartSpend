import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
          color: color ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.12),
              blurRadius: 30,
              spreadRadius: isDark ? 5 : 2,
              offset: const Offset(0, 10),
            ),
            // Add second shadow for light mode for better depth
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
          ],
          border: Border.all(
            color: isDark 
                ? Colors.grey.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            width: 1.5,
          )
      ),
      child: child,
    );
  }
}
