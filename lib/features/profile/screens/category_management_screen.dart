import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:uuid/uuid.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() => _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final _nameController = TextEditingController();
  IconData _selectedIcon = Icons.category_rounded;
  Color _selectedColor = AppTheme.primaryTeal;
  final _formKey = GlobalKey<FormState>();

  // Expanded color palette with more vibrant options
  final List<Color> _colorOptions = [
    // Original colors
    AppTheme.primaryTeal,
    AppTheme.accentOrange,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.green,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
    // Additional vibrant colors
    Colors.deepPurple,
    Colors.cyan,
    Colors.teal,
    Colors.lime,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.blueGrey,
    const Color(0xFFE91E63), // Pink accent
    const Color(0xFF9C27B0), // Purple accent
    const Color(0xFF673AB7), // Deep Purple accent
    const Color(0xFF3F51B5), // Indigo accent
    const Color(0xFF2196F3), // Blue accent
    const Color(0xFF00BCD4), // Cyan accent
    const Color(0xFF009688), // Teal accent
    const Color(0xFF4CAF50), // Green accent
    const Color(0xFF8BC34A), // Light Green accent
    const Color(0xFFCDDC39), // Lime accent
    const Color(0xFFFFEB3B), // Yellow accent
    const Color(0xFFFFC107), // Amber accent
    const Color(0xFFFF9800), // Orange accent
    const Color(0xFFFF5722), // Deep Orange accent
    const Color(0xFF795548), // Brown accent
    const Color(0xFF607D8B), // Blue Grey accent
  ];

  final List<Map<String, dynamic>> _iconOptions = [
    // Food & Dining
    {'icon': Icons.restaurant_rounded, 'name': 'Food'},
    {'icon': Icons.fastfood_rounded, 'name': 'Fast Food'},
    {'icon': Icons.local_cafe_rounded, 'name': 'Coffee'},
    {'icon': Icons.local_pizza_rounded, 'name': 'Pizza'},
    {'icon': Icons.cake_rounded, 'name': 'Dessert'},
    {'icon': Icons.lunch_dining_rounded, 'name': 'Lunch'},
    {'icon': Icons.dinner_dining_rounded, 'name': 'Dinner'},
    {'icon': Icons.breakfast_dining_rounded, 'name': 'Breakfast'},
    {'icon': Icons.local_bar_rounded, 'name': 'Bar'},
    {'icon': Icons.icecream_rounded, 'name': 'Ice Cream'},
    
    // Transportation
    {'icon': Icons.directions_car_rounded, 'name': 'Transport'},
    {'icon': Icons.local_gas_station_rounded, 'name': 'Gas'},
    {'icon': Icons.local_taxi_rounded, 'name': 'Taxi'},
    {'icon': Icons.directions_bus_rounded, 'name': 'Bus'},
    {'icon': Icons.directions_subway_rounded, 'name': 'Subway'},
    {'icon': Icons.train_rounded, 'name': 'Train'},
    {'icon': Icons.flight_rounded, 'name': 'Travel'},
    {'icon': Icons.airport_shuttle_rounded, 'name': 'Airport'},
    {'icon': Icons.directions_bike_rounded, 'name': 'Bike'},
    {'icon': Icons.directions_walk_rounded, 'name': 'Walk'},
    {'icon': Icons.local_parking_rounded, 'name': 'Parking'},
    
    // Shopping
    {'icon': Icons.shopping_bag_rounded, 'name': 'Shopping'},
    {'icon': Icons.shopping_cart_rounded, 'name': 'Cart'},
    {'icon': Icons.store_rounded, 'name': 'Store'},
    {'icon': Icons.local_mall_rounded, 'name': 'Mall'},
    {'icon': Icons.checkroom_rounded, 'name': 'Clothing'},
    {'icon': Icons.watch_rounded, 'name': 'Accessories'},
    {'icon': Icons.local_offer_rounded, 'name': 'Deals'},
    
    // Entertainment & Hobbies
    {'icon': Icons.movie_rounded, 'name': 'Entertainment'},
    {'icon': Icons.theater_comedy_rounded, 'name': 'Theater'},
    {'icon': Icons.music_note_rounded, 'name': 'Music'},
    {'icon': Icons.sports_esports_rounded, 'name': 'Gaming'},
    {'icon': Icons.sports_soccer_rounded, 'name': 'Sports'},
    {'icon': Icons.casino_rounded, 'name': 'Casino'},
    {'icon': Icons.celebration_rounded, 'name': 'Celebration'},
    {'icon': Icons.park_rounded, 'name': 'Park'},
    {'icon': Icons.beach_access_rounded, 'name': 'Beach'},
    {'icon': Icons.pool_rounded, 'name': 'Pool'},
    {'icon': Icons.spa_rounded, 'name': 'Spa'},
    
    // Bills & Utilities
    {'icon': Icons.receipt_long_rounded, 'name': 'Bills'},
    {'icon': Icons.bolt_rounded, 'name': 'Electricity'},
    {'icon': Icons.water_drop_rounded, 'name': 'Water'},
    {'icon': Icons.wifi_rounded, 'name': 'Internet'},
    {'icon': Icons.phone_rounded, 'name': 'Phone'},
    {'icon': Icons.router_rounded, 'name': 'Router'},
    
    // Health & Wellness
    {'icon': Icons.health_and_safety_rounded, 'name': 'Health'},
    {'icon': Icons.medical_services_rounded, 'name': 'Medical'},
    {'icon': Icons.medication_rounded, 'name': 'Medicine'},
    {'icon': Icons.fitness_center_rounded, 'name': 'Fitness'},
    {'icon': Icons.self_improvement_rounded, 'name': 'Wellness'},
    {'icon': Icons.favorite_rounded, 'name': 'Heart Health'},
    {'icon': Icons.psychology_rounded, 'name': 'Mental Health'},
    
    // Education
    {'icon': Icons.school_rounded, 'name': 'Education'},
    {'icon': Icons.menu_book_rounded, 'name': 'Books'},
    {'icon': Icons.library_books_rounded, 'name': 'Library'},
    {'icon': Icons.science_rounded, 'name': 'Science'},
    {'icon': Icons.computer_rounded, 'name': 'Computer'},
    
    // Home & Family
    {'icon': Icons.home_rounded, 'name': 'Home'},
    {'icon': Icons.weekend_rounded, 'name': 'Furniture'},
    {'icon': Icons.build_rounded, 'name': 'Maintenance'},
    {'icon': Icons.local_laundry_service_rounded, 'name': 'Laundry'},
    {'icon': Icons.cleaning_services_rounded, 'name': 'Cleaning'},
    {'icon': Icons.child_care_rounded, 'name': 'Childcare'},
    {'icon': Icons.family_restroom_rounded, 'name': 'Family'},
    
    // Work & Business
    {'icon': Icons.work_rounded, 'name': 'Work'},
    {'icon': Icons.business_rounded, 'name': 'Business'},
    {'icon': Icons.laptop_rounded, 'name': 'Laptop'},
    {'icon': Icons.print_rounded, 'name': 'Printing'},
    {'icon': Icons.email_rounded, 'name': 'Email'},
    
    // Pets
    {'icon': Icons.pets_rounded, 'name': 'Pets'},
    
    // Electronics & Technology
    {'icon': Icons.phone_android_rounded, 'name': 'Electronics'},
    {'icon': Icons.tablet_android_rounded, 'name': 'Tablet'},
    {'icon': Icons.watch_rounded, 'name': 'Smart Watch'},
    {'icon': Icons.headphones_rounded, 'name': 'Audio'},
    {'icon': Icons.camera_alt_rounded, 'name': 'Camera'},
    {'icon': Icons.videogame_asset_rounded, 'name': 'Console'},
    
    // Finance & Banking
    {'icon': Icons.account_balance_rounded, 'name': 'Bank'},
    {'icon': Icons.savings_rounded, 'name': 'Savings'},
    {'icon': Icons.monetization_on_rounded, 'name': 'Money'},
    {'icon': Icons.credit_card_rounded, 'name': 'Credit Card'},
    {'icon': Icons.payment_rounded, 'name': 'Payment'},
    {'icon': Icons.currency_exchange_rounded, 'name': 'Exchange'},
    {'icon': Icons.attach_money_rounded, 'name': 'Dollar'},
    
    // Gifts & Donations
    {'icon': Icons.card_giftcard_rounded, 'name': 'Gift'},
    {'icon': Icons.volunteer_activism_rounded, 'name': 'Donation'},
    {'icon': Icons.redeem_rounded, 'name': 'Reward'},
    
    // Personal Care
    {'icon': Icons.face_rounded, 'name': 'Personal Care'},
    {'icon': Icons.cut_rounded, 'name': 'Haircut'},
    {'icon': Icons.shower_rounded, 'name': 'Shower'},
    
    // Insurance & Legal
    {'icon': Icons.security_rounded, 'name': 'Insurance'},
    {'icon': Icons.gavel_rounded, 'name': 'Legal'},
    
    // Other
    {'icon': Icons.category_rounded, 'name': 'Other'},
    {'icon': Icons.more_horiz_rounded, 'name': 'More'},
    {'icon': Icons.add_circle_outline_rounded, 'name': 'Add'},
    {'icon': Icons.star_rounded, 'name': 'Favorite'},
    {'icon': Icons.diamond_rounded, 'name': 'Premium'},
    {'icon': Icons.emoji_events_rounded, 'name': 'Award'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeDefaultCategories();
  }

  void _initializeDefaultCategories() {
    final box = Hive.box<Category>('categories');
    if (box.isEmpty) {
      final defaultCategories = [
        Category(id: 'food', name: 'Food & Drink', icon: Icons.restaurant_rounded.codePoint.toString(), color: AppTheme.accentOrange.value),
        Category(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded.codePoint.toString(), color: AppTheme.primaryTeal.value),
        Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded.codePoint.toString(), color: AppTheme.accentOrange.value),
        Category(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded.codePoint.toString(), color: AppTheme.primaryTeal.value),
        Category(id: 'bills', name: 'Bills & Utilities', icon: Icons.receipt_long_rounded.codePoint.toString(), color: AppTheme.accentOrange.value),
        Category(id: 'health', name: 'Health', icon: Icons.health_and_safety_rounded.codePoint.toString(), color: AppTheme.primaryTeal.value),
        Category(id: 'education', name: 'Education', icon: Icons.school_rounded.codePoint.toString(), color: AppTheme.accentOrange.value),
        Category(id: 'other', name: 'Other', icon: Icons.category_rounded.codePoint.toString(), color: AppTheme.primaryTeal.value),
      ];
      for (var cat in defaultCategories) {
        box.put(cat.id, cat);
      }
    }
  }

  void _addCategory() {
    if (_formKey.currentState?.validate() ?? false) {
      final box = Hive.box<Category>('categories');
      final newCategory = Category(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon.codePoint.toString(),
        color: _selectedColor.value,
      );
      box.put(newCategory.id, newCategory);
      _nameController.clear();
      setState(() {
        _selectedIcon = Icons.category_rounded;
        _selectedColor = AppTheme.primaryTeal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text('Category "${newCategory.name}" added successfully! 🎉'),
            ],
          ),
          backgroundColor: AppTheme.getPrimaryTealColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _editCategory(Category category) async {
    _nameController.text = category.name;
    _selectedIcon = IconData(int.parse(category.icon), fontFamily: 'MaterialIcons');
    _selectedColor = Color(category.color);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.darkCard.withOpacity(0.95),
                        AppTheme.darkSurface.withOpacity(0.98),
                        AppTheme.darkBackground.withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.95),
                        Colors.grey.shade50.withOpacity(0.98),
                        Colors.white.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark 
                  ? AppTheme.darkPrimaryTeal.withOpacity(0.2)
                  : AppTheme.primaryTeal.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.4)
                      : AppTheme.primaryTeal.withOpacity(0.08),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header with glassmorphic background
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _selectedColor.withOpacity(0.12),
                              _selectedColor.withOpacity(0.06),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedColor.withOpacity(0.15),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedColor.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_selectedColor, _selectedColor.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _selectedColor.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _selectedIcon,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit Category',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getTextColor(context),
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Customize your expense category',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.getSecondaryTextColor(context),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.getSecondaryTextColor(context).withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _resetForm();
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppTheme.getSecondaryTextColor(context),
                                  size: 22,
                                ),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Category Name Field
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppTheme.darkSurface.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark 
                              ? AppTheme.darkPrimaryTeal.withValues(alpha: 0.2)
                              : AppTheme.primaryTeal.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.label_rounded,
                                  size: 16,
                                  color: _selectedColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CATEGORY NAME',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextColor(context),
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter category name...',
                                hintStyle: GoogleFonts.poppins(
                                  color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Icon Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppTheme.darkSurface.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark 
                              ? AppTheme.darkPrimaryTeal.withValues(alpha: 0.2)
                              : AppTheme.primaryTeal.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedIcon,
                                  size: 16,
                                  color: _selectedColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SELECT ICON',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _iconOptions.map((iconData) {
                                final isSelected = _selectedIcon == iconData['icon'];
                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      _selectedIcon = iconData['icon'];
                                    });
                                  },
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [_selectedColor, _selectedColor.withValues(alpha: 0.8)],
                                            )
                                          : null,
                                      color: !isSelected
                                          ? (isDark ? AppTheme.darkCard.withValues(alpha: 0.5) : Colors.grey.shade100)
                                          : null,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected 
                                          ? _selectedColor.withValues(alpha: 0.3)
                                          : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      iconData['icon'],
                                      color: isSelected 
                                        ? Colors.white 
                                        : AppTheme.getSecondaryTextColor(context),
                                      size: 22,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Color Selection
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppTheme.darkSurface.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark 
                              ? AppTheme.darkPrimaryTeal.withValues(alpha: 0.2)
                              : AppTheme.primaryTeal.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'PICK COLOR',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _colorOptions.map((color) {
                                final isSelected = _selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setDialogState(() {
                                      _selectedColor = color;
                                    });
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected 
                                          ? AppTheme.getTextColor(context) 
                                          : Colors.transparent,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_rounded, 
                                            color: Colors.white, 
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.2),
                                ),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _nameController.clear();
                                  setState(() {
                                    _selectedIcon = Icons.category_rounded;
                                    _selectedColor = AppTheme.primaryTeal;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.getSecondaryTextColor(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'CANCEL',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: AppTheme.getGradientButtonDecoration(),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_nameController.text.isNotEmpty) {
                                    final updatedCategory = category.copyWith(
                                      name: _nameController.text,
                                      icon: _selectedIcon.codePoint.toString(),
                                      color: _selectedColor.value,
                                    );

                                    final categoriesBox = Hive.box<Category>('categories');
                                    await categoriesBox.put(category.key, updatedCategory);

                                    Navigator.of(context).pop();
                                    _nameController.clear();
                                    setState(() {
                                      _selectedIcon = Icons.category_rounded;
                                      _selectedColor = AppTheme.primaryTeal;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Category updated successfully!'),
                                        backgroundColor: AppTheme.getSuccessColor(context),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: AppTheme.getGradientButtonStyle(),
                                child: Text(
                                  'UPDATE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _deleteCategory(String id) {
    final box = Hive.box<Category>('categories');
    final category = box.get(id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Category',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category?.name}"? This will remove it from all budgets.',
          style: GoogleFonts.poppins(
            color: AppTheme.getTextColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppTheme.getSecondaryTextColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              box.delete(id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Category deleted successfully'),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Text(
              'DELETE',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeaderSection(),
            Expanded(
              child: ValueListenableBuilder<Box<Category>>(
                valueListenable: Hive.box<Category>('categories').listenable(),
                builder: (context, box, _) {
                  final categories = box.values.toList();
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildAddCategorySection(),
                      const SizedBox(height: 24),
                      _buildCategoriesList(categories),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
                      'Manage Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Organize your expenses with custom categories',
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
          const SizedBox(height: 20),
          
          // Category Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Categories', Icons.category_rounded),
              _buildStatItem(context, 'Custom', Icons.edit_rounded),
              _buildStatItem(context, 'Active', Icons.check_circle_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getHeaderIconBackground(context),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon, 
            size: 20, 
            color: AppTheme.getHeaderTextColor(context)
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCategorySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _selectedColor.withOpacity(0.8),
                        _selectedColor.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create New Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Category Name',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppTheme.getTextColor(context),
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Food, Transport, Shopping',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.darkCard : Colors.grey[300]!,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.darkCard : Colors.grey[300]!,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _selectedColor, width: 2),
                ),
                filled: true,
                fillColor: isDark ? AppTheme.darkSurface : Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon: Icon(
                  Icons.edit_rounded,
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Text(
              'Select Icon',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.darkCard : Colors.grey[300]!,
                ),
              ),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _iconOptions.map((iconData) {
                  final isSelected = _selectedIcon == iconData['icon'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconData['icon'];
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  _selectedColor.withOpacity(0.8),
                                  _selectedColor.withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : (isDark ? AppTheme.darkCard : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconData['icon'],
                        color: isSelected ? Colors.white : AppTheme.getSecondaryTextColor(context),
                        size: 24,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Pick a Color',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.darkCard : Colors.grey[300]!,
                ),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colorOptions.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.getTextColor(context) : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24),
            Container(
              height: 56,
              decoration: AppTheme.getGradientButtonDecoration(),
              child: ElevatedButton.icon(
                onPressed: _addCategory,
                icon: Icon(Icons.add_rounded, size: 20, color: Colors.white),
                label: Text(
                  'CREATE CATEGORY',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                style: AppTheme.getGradientButtonStyle(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesList(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'YOUR CATEGORIES',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.getSecondaryTextColor(context),
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${categories.length}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (categories.isEmpty)
          _buildEmptyState()
        else
          ...categories.map((category) => Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.getTextColor(context).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon with gradient background (like expense items)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(category.color).withOpacity(0.8),
                          Color(category.color).withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(category.color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Expense Category',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Color(category.color),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit button
                  GestureDetector(
                    onTap: () => _editCategory(category),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Delete button
                  GestureDetector(
                    onTap: () => _deleteCategory(category.id),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ModernCard(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category_outlined,
              size: 40,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Categories Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first category to start\norganizing your expenses effectively!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for enhanced edit dialog
  void _resetForm() {
    _nameController.clear();
    setState(() {
      _selectedIcon = Icons.category_rounded;
      _selectedColor = AppTheme.primaryTeal;
    });
  }

  Widget _buildGlassmorphicField({
    required BuildContext context,
    required bool isDark,
    required StateSetter setDialogState,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark 
          ? AppTheme.darkSurface.withOpacity(0.25)
          : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark 
            ? Colors.white.withOpacity(0.08)
            : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: _selectedColor,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getSecondaryTextColor(context),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildIconGrid(StateSetter setDialogState, bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _iconOptions.map((iconData) {
        final isSelected = _selectedIcon == iconData['icon'];
        return GestureDetector(
          onTap: () {
            setDialogState(() {
              _selectedIcon = iconData['icon'];
            });
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [_selectedColor, _selectedColor.withOpacity(0.8)],
                    )
                  : null,
              color: !isSelected
                  ? (isDark ? AppTheme.darkCard.withOpacity(0.3) : Colors.grey.shade50)
                  : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected 
                  ? _selectedColor.withOpacity(0.4)
                  : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _selectedColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              iconData['icon'],
              color: isSelected 
                ? Colors.white 
                : AppTheme.getSecondaryTextColor(context),
              size: 24,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorGrid(StateSetter setDialogState) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: _colorOptions.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setDialogState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                  ? AppTheme.getTextColor(context) 
                  : Colors.transparent,
                width: 3.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.35),
                  blurRadius: isSelected ? 15 : 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded, 
                    color: Colors.white, 
                    size: 24,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _updateCategory(Category category, StateSetter setDialogState) async {
    if (_nameController.text.isNotEmpty) {
      final categoryColor = _selectedColor.value;
      final updatedCategory = category.copyWith(
        name: _nameController.text,
        icon: _selectedIcon.codePoint.toString(),
        color: categoryColor,
      );

      final categoriesBox = Hive.box<Category>('categories');
      await categoriesBox.put(category.key, updatedCategory);

      Navigator.of(context).pop();
      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Category "${_nameController.text}" updated successfully!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.getSuccessColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}