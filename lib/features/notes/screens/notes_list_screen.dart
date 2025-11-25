import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/note_editor_screen.dart';
import 'package:smart_expense_tracker/models/note_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  NoteFilter _selectedFilter = NoteFilter.all;
  NoteSort _currentSort = NoteSort.newest;
  List<int> _deletedNoteKeys = []; // Track deleted note keys instead of IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: Column(
          children: [
            _buildHeaderSection(),
            Expanded(
              child: ValueListenableBuilder<Box<Note>>(
                valueListenable: Hive.box<Note>('notes').listenable(),
                builder: (context, box, _) {
                  // Get current user ID
                  final currentUserId = context.read<AuthService>().currentUser?.uid;
                  
                  // Filter notes by current user first
                  final userNotes = box.values
                      .where((note) => note.userId == currentUserId)
                      .toList()
                      .cast<Note>();
                  
                  // Apply additional filters
                  final filteredNotes = _filterNotes(userNotes)
                      .where((note) => !_deletedNoteKeys.contains(note.key))
                      .toList();
                  final sortedNotes = _sortNotes(filteredNotes);

                  return sortedNotes.isEmpty
                      ? _buildEmptyState(context)
                      : _buildNotesList(context, sortedNotes, box);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen())
        ),
        backgroundColor: AppTheme.getAccentColor(context),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.note_add_rounded),
        label: Text(
          'Create Note',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getHeaderIconBackground(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainScreen()),
                          (route) => false,
                    );
                  },
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
                      'Financial Notes',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capture your financial thoughts and goals',
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.getHeaderIconBackground(context),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterToggle('All', NoteFilter.all),
                const SizedBox(width: 4),
                _buildFilterToggle('Important', NoteFilter.important),
                const SizedBox(width: 4),
                _buildFilterToggle('Completed', NoteFilter.completed),
                const SizedBox(width: 4),
                _buildFilterToggle('Active', NoteFilter.active),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle(String text, NoteFilter filter) {
    final isSelected = _selectedFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.getPrimaryColor(context) : Colors.white.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  List<Note> _filterNotes(List<Note> notes) {
    switch (_selectedFilter) {
      case NoteFilter.important:
        return notes.where((note) => note.isImportant).toList();
      case NoteFilter.completed:
        return notes.where((note) => note.isCompleted).toList();
      case NoteFilter.active:
        return notes.where((note) => !note.isCompleted).toList();
      case NoteFilter.recent:
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return notes.where((note) => note.updatedAt.isAfter(weekAgo)).toList();
      case NoteFilter.all:
      default:
        return notes;
    }
  }

  List<Note> _sortNotes(List<Note> notes) {
    final sortedNotes = List<Note>.from(notes);
    switch (_currentSort) {
      case NoteSort.newest:
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteSort.oldest:
        sortedNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
        break;
      case NoteSort.important:
        sortedNotes.sort((a, b) {
          if (a.isImportant && !b.isImportant) return -1;
          if (!a.isImportant && b.isImportant) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
        break;
    }
    return sortedNotes;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_alt_rounded,
              size: 60,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notes Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Capture your financial thoughts, goals,\nand spending insights in one place.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.getSecondaryTextColor(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes, Box<Note> box) {
    // Separate notes into active and completed
    final activeNotes = notes.where((note) => !note.isCompleted).toList();
    final completedNotes = notes.where((note) => note.isCompleted).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ModernCard(
          color: AppTheme.getCardColor(context),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NOTES SUMMARY',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getSecondaryTextColor(context),
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.getPrimaryColor(context).withOpacity(0.2), AppTheme.getPrimaryColor(context).withOpacity(0.1)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_rounded,
                          size: 14,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notes.length} NOTES',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getPrimaryColor(context),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildSummaryItem(notes.length.toString(), 'Total'),
                  _buildSummaryItem(
                    notes.where((note) => note.isImportant).length.toString(),
                    'Important',
                  ),
                  _buildSummaryItem(
                    completedNotes.length.toString(),
                    'Completed',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Active Notes Section
        if (activeNotes.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "ACTIVE NOTES",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getSecondaryTextColor(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${activeNotes.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getPrimaryColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              PopupMenuButton<NoteSort>(
                icon: Icon(Icons.sort_rounded, color: AppTheme.getPrimaryColor(context)),
                onSelected: (sort) {
                  setState(() {
                    _currentSort = sort;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: NoteSort.newest,
                    child: Row(
                      children: [
                        Icon(
                          Icons.new_releases_rounded,
                          color: _currentSort == NoteSort.newest ? AppTheme.getPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text('Newest First', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: NoteSort.oldest,
                    child: Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: _currentSort == NoteSort.oldest ? AppTheme.getPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text('Oldest First', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: NoteSort.important,
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: _currentSort == NoteSort.important ? AppTheme.getPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                        ),
                        const SizedBox(width: 8),
                        Text('Important First', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...activeNotes.map((note) {
            if (_deletedNoteKeys.contains(note.key)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildNoteCard(note, box, false),
            );
          }).toList(),
        ],
        
        // Completed Notes Section
        if (completedNotes.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Text(
                "COMPLETED",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getSecondaryTextColor(context),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${completedNotes.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...completedNotes.map((note) {
            if (_deletedNoteKeys.contains(note.key)) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildNoteCard(note, box, true),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildNoteCard(Note note, Box<Note> box, bool isCompleted) {
    return Dismissible(
      key: Key('note_${note.key}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
          ),
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(note);
      },
      onDismissed: (direction) {
        setState(() {
          _deletedNoteKeys.add(note.key);
        });
        _deleteNote(note, box);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(note: note, noteKey: note.key),
            ),
          );
        },
        child: _buildEnhancedNoteItem(note, box),
      ),
    );
  }

  Widget _buildEnhancedNoteItem(Note note, Box<Note> box) {
    final isCompleted = note.isCompleted;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get category from first tag or use 'General'
    final category = note.tags.isNotEmpty ? note.tags.first : 'General';
    final categoryColor = _getCategoryColor(category);
    
    return ModernCard(
      color: AppTheme.getCardColor(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [                    Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isCompleted 
                            ? AppTheme.getSecondaryTextColor(context)
                            : AppTheme.getTextColor(context),
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),                        const SizedBox(width: 8),
                        if (note.isImportant)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 6, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  'Today',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],                ),
              ),
              // Pin icon - changes color when important/pinned
              IconButton(
                icon: Icon(
                  note.isImportant ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.isImportant 
                      ? AppTheme.getAccentColor(context) 
                      : AppTheme.getSecondaryTextColor(context).withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () => _toggleNoteImportance(note, box),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: note.isImportant ? 'Unpin note' : 'Pin note',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content/Description in a box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Text(
              note.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isCompleted 
                    ? AppTheme.getSecondaryTextColor(context).withOpacity(0.7)
                    : AppTheme.getSecondaryTextColor(context),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NoteEditorScreen(note: note, noteKey: note.key),
                      ),
                    );
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark 
                      ? Colors.red.withOpacity(0.15)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  onPressed: () async {
                    final confirmed = await _showDeleteConfirmation(note);
                    if (confirmed) {
                      setState(() {
                        _deletedNoteKeys.add(note.key);
                      });
                      _deleteNote(note, box);
                    }
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'personal':
        return Icons.person_rounded;
      case 'finance':
      case 'financial':
        return Icons.attach_money_rounded;
      case 'health':
        return Icons.favorite_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'travel':
        return Icons.flight_rounded;
      default:
        return Icons.note_alt_rounded;
    }
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'education':
        return const Color(0xFF4CAF50); // Green
      case 'work':
        return const Color(0xFF2196F3); // Blue
      case 'personal':
        return const Color(0xFF9C27B0); // Purple
      case 'finance':
      case 'financial':
        return const Color(0xFFFF9800); // Orange
      case 'health':
        return const Color(0xFFE91E63); // Pink
      case 'shopping':
        return const Color(0xFFFF5722); // Deep Orange
      case 'travel':
        return const Color(0xFF00BCD4); // Cyan
      default:
        return AppTheme.getPrimaryColor(context);
    }
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.getPrimaryColor(context), // Use theme-aware teal color
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _toggleNoteCompletion(Note note, Box<Note> box) {
    final updatedNote = note.copyWith(
      isCompleted: !note.isCompleted,
      updatedAt: DateTime.now(),
    );
    // FIXED: Use Hive key instead of ID to prevent duplicates
    box.put(note.key, updatedNote);
  }

  void _toggleNoteImportance(Note note, Box<Note> box) {
    final updatedNote = note.copyWith(
      isImportant: !note.isImportant,
      updatedAt: DateTime.now(),
    );
    // FIXED: Use Hive key instead of ID to prevent duplicates
    box.put(note.key, updatedNote);
  }

  Future<bool> _showDeleteConfirmation(Note note) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete "${note.title}"?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _deleteNote(Note note, Box<Note> box) {
    // FIXED: Delete by Hive key instead of ID
    box.delete(note.key);
    print('🗑️ Note deleted with key: ${note.key}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note deleted', style: GoogleFonts.poppins()),
        backgroundColor: AppTheme.accentOrange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

enum NoteFilter { all, important, completed, active, recent }
enum NoteSort { newest, oldest, important }