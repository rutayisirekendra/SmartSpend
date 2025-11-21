import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';

class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool enabled;
  final int maxLines;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final FocusNode? focusNode;

  const ModernTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixText,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.focusNode,
  }) : super(key: key);

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDark && _isFocused
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryTeal.withOpacity(0.1),
                      AppTheme.primaryTeal.withOpacity(0.05),
                    ],
                  )
                : null,
            boxShadow: [
              if (_isFocused) ...[
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ] else if (!isDark) ...[
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppTheme.getTextColor(context),
              height: 1.4,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixText: widget.prefixText,
              suffixIcon: widget.suffixIcon,
              prefixIcon: widget.prefixIcon,
              
              // Label styling
              labelStyle: GoogleFonts.poppins(
                fontSize: _isFocused ? 14 : 16,
                fontWeight: FontWeight.w500,
                color: _isFocused 
                    ? AppTheme.primaryTeal 
                    : AppTheme.getTextColor(context).withOpacity(0.6),
              ),
              floatingLabelStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTeal,
              ),
              
              // Hint styling
              hintStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.getTextColor(context).withOpacity(0.4),
              ),
              
              // Prefix styling
              prefixStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
              
              // Content padding
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              
              // Border styling
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark 
                      ? AppTheme.getTextColor(context).withOpacity(0.1)
                      : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark 
                      ? AppTheme.getTextColor(context).withOpacity(0.1)
                      : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppTheme.primaryTeal,
                  width: 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              
              // Fill styling for dark mode
              filled: isDark,
              fillColor: isDark 
                  ? AppTheme.getTextColor(context).withOpacity(0.03)
                  : null,
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Dropdown Component
class ModernDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const ModernDropdown({
    Key? key,
    this.value,
    required this.items,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.getTextColor(context),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon,
          
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextColor(context).withOpacity(0.6),
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryTeal,
          ),
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppTheme.getTextColor(context).withOpacity(0.4),
          ),
          
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark 
                  ? AppTheme.getTextColor(context).withOpacity(0.1)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark 
                  ? AppTheme.getTextColor(context).withOpacity(0.1)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryTeal,
              width: 2.0,
            ),
          ),
          
          filled: isDark,
          fillColor: isDark 
              ? AppTheme.getTextColor(context).withOpacity(0.03)
              : null,
        ),
        
        dropdownColor: isDark 
            ? AppTheme.cardBackground(context)
            : Colors.white,
        
        icon: Container(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.getTextColor(context).withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

// Modern Date Picker Field
class ModernDateField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Function(DateTime?)? onDateSelected;
  final VoidCallback? onClear;

  const ModernDateField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onClear,
  }) : super(key: key);

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryTeal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText ?? 'Select date',
      readOnly: true,
      onTap: () => _selectDate(context),
      prefixIcon: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          Icons.calendar_today_rounded,
          size: 20,
          color: AppTheme.primaryTeal,
        ),
      ),
      suffixIcon: controller.text.isNotEmpty && onClear != null
          ? IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.clear_rounded,
                color: AppTheme.getTextColor(context).withOpacity(0.6),
              ),
            )
          : Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppTheme.getTextColor(context).withOpacity(0.6),
            ),
    );
  }
}