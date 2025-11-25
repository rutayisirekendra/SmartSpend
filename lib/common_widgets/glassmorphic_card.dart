import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderColor,
    this.borderWidth = 1.5,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.12),
            blurRadius: blur,
            offset: const Offset(0, 4),
            spreadRadius: isDark ? 0 : 1,
          ),
          // Add second shadow for light mode for better depth
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: blur * 2,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(opacity)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? 
                    (isDark 
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.25)),
                width: borderWidth,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Gradient? gradient;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient ?? (isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.darkBackgroundGradientStart,
                  AppTheme.darkBackgroundGradientEnd,
                  AppTheme.darkBackground,
                ],
                stops: const [0.0, 0.5, 1.0],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.offWhite,
                  Colors.white,
                ],
              )),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
