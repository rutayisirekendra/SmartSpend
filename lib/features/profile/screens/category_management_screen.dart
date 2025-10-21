import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/common_widgets/primary_button.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
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
  final _formKey = GlobalKey<FormState>();

  // Enhanced icons with more options using only your theme colors
  final List<Map<String, dynamic>> _iconOptions = [
    {'icon': Icons.restaurant_rounded, 'name': 'Food', 'color': AppTheme.accentOrange},
    {'icon': Icons.directions_car_rounded, 'name': 'Transport', 'color': AppTheme.primaryTeal},
    {'icon': Icons.shopping_bag_rounded, 'name': 'Shopping', 'color': AppTheme.accentOrange},
    {'icon': Icons.movie_rounded, 'name': 'Entertainment', 'color': AppTheme.primaryTeal},
    {'icon': Icons.receipt_long_rounded, 'name': 'Bills', 'color': AppTheme.accentOrange},
    {'icon': Icons.health_and_safety_rounded, 'name': 'Health', 'color': AppTheme.primaryTeal},
    {'icon': Icons.school_rounded, 'name': 'Education', 'color': AppTheme.accentOrange},
    {'icon': Icons.home_rounded, 'name': 'Home', 'color': AppTheme.primaryTeal},
    {'icon': Icons.work_rounded, 'name': 'Work', 'color': AppTheme.accentOrange},
    {'icon': Icons.flight_rounded, 'name': 'Travel', 'color': AppTheme.primaryTeal},
    {'icon': Icons.fitness_center_rounded, 'name': 'Fitness', 'color': AppTheme.accentOrange},
    {'icon': Icons.celebration_rounded, 'name': 'Celebration', 'color': AppTheme.primaryTeal},
    {'icon': Icons.pets_rounded, 'name': 'Pets', 'color': AppTheme.accentOrange},
    {'icon': Icons.local_gas_station_rounded, 'name': 'Gas', 'color': AppTheme.primaryTeal},
    {'icon': Icons.local_cafe_rounded, 'name': 'Coffee', 'color': AppTheme.accentOrange},
    {'icon': Icons.phone_android_rounded, 'name': 'Electronics', 'color': AppTheme.primaryTeal},
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
        Category(id: 'food', name: 'Food & Drink', icon: Icons.restaurant_rounded.codePoint.toString()),
        Category(id: 'transport', name: 'Transport', icon: Icons.directions_car_rounded.codePoint.toString()),
        Category(id: 'shopping', name: 'Shopping', icon: Icons.shopping_bag_rounded.codePoint.toString()),
        Category(id: 'entertainment', name: 'Entertainment', icon: Icons.movie_rounded.codePoint.toString()),
        Category(id: 'bills', name: 'Bills & Utilities', icon: Icons.receipt_long_rounded.codePoint.toString()),
        Category(id: 'health', name: 'Health', icon: Icons.health_and_safety_rounded.codePoint.toString()),
        Category(id: 'education', name: 'Education', icon: Icons.school_rounded.codePoint.toString()),
        Category(id: 'other', name: 'Other', icon: Icons.more_horiz_rounded.codePoint.toString()),
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
      );
      box.put(newCategory.id, newCategory);
      _nameController.clear();
      setState(() {
        _selectedIcon = Icons.category_rounded;
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
          backgroundColor: AppTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _deleteCategory(String id) {
    final box = Hive.box<Category>('categories');
    final category = box.get(id);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${category?.name}"? This will remove it from all budgets.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
            child: Text('DELETE', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Enhanced Header Section
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal,
            AppTheme.primaryTeal.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button and Title Row
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                        (route) => false,
                  );
                },
                icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: EdgeInsets.all(8),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Organize your expenses with custom categories',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Quick Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Categories', Icons.category_rounded),
              _buildStatItem('Custom', Icons.edit_rounded),
              _buildStatItem('Active', Icons.check_circle_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddCategorySection() {
    return ModernCard(
      padding: EdgeInsets.all(20),
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
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_circle_rounded,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Create New Category',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTeal,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Category Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name ✏️',
                labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryTeal),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: GoogleFonts.poppins(fontSize: 16),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name 📝';
                }
                return null;
              },
            ),
            SizedBox(height: 20),

            // Icon Selection
            _buildIconSelectionSection(),
            SizedBox(height: 20),

            // Add Category Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.accentOrange,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'CREATE CATEGORY 🚀',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelectionSection() {
    final currentIconData = _iconOptions.firstWhere(
          (icon) => icon['icon'] == _selectedIcon,
      orElse: () => {'icon': Icons.category_rounded, 'name': 'Category', 'color': AppTheme.primaryTeal},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.emoji_objects_rounded,
                size: 16,
                color: AppTheme.accentOrange,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'SELECT ICON',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _showIconPicker,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: currentIconData['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: currentIconData['color']),
                  ),
                  child: Icon(_selectedIcon, color: currentIconData['color'], size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Icon',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentIconData['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_drop_down_rounded, color: AppTheme.primaryTeal),
                ),
              ],
            ),
          ),
        ),
      ],
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
                color: Colors.grey[600],
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
          ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ModernCard(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryTeal),
                    ),
                    child: Icon(
                      IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
                      color: AppTheme.primaryTeal,
                      size: 20,
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
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Expense Category',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                    ),
                    onPressed: () => _deleteCategory(category.id),
                  ),
                ],
              ),
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ModernCard(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.category_outlined, size: 40, color: Colors.grey[400]),
          ),
          SizedBox(height: 20),
          Text(
            'No Categories Yet 📭',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create your first category to start\norganizing your expenses effectively! ✨',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Choose an Icon 🎨',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _iconOptions.length,
                  itemBuilder: (context, index) {
                    final iconData = _iconOptions[index];
                    final isSelected = _selectedIcon == iconData['icon'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = iconData['icon'];
                        });
                        Navigator.of(context).pop();
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? iconData['color'].withOpacity(0.1) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? iconData['color'] : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: iconData['color'].withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            )
                          ] : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              iconData['icon'],
                              color: isSelected ? iconData['color'] : Colors.grey[600],
                              size: 24,
                            ),
                            SizedBox(height: 8),
                            Text(
                              iconData['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? iconData['color'] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}