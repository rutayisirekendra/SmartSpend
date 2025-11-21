import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/glassmorphic_card.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/note_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final int? noteKey; // Add this to track the Hive key
  const NoteEditorScreen({Key? key, this.note, this.noteKey}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _isImportant = widget.note?.isImportant ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showSaveError('Please add a title');
      return;
    }

    // Get current user ID
    final currentUserId = context.read<AuthService>().currentUser?.uid;
    if (currentUserId == null) {
      _showSaveError('User not authenticated');
      return;
    }

    final now = DateTime.now();
    final notesBox = Hive.box<Note>('notes');

    try {
      if (widget.note == null) {
        // Creating new note
        final newNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: currentUserId, // Use actual user ID
          title: title,
          content: content,
          createdAt: now,
          updatedAt: now,
          isImportant: _isImportant,
          tags: [],
          isCompleted: false,
        );

        await notesBox.add(newNote);
        print('✅ New note created with key: ${newNote.key} for user: $currentUserId');

      } else {
        // FIXED: Create updated note and save using the original key
        final updatedNote = widget.note!.copyWith(
          title: title,
          content: content,
          updatedAt: now,
          isImportant: _isImportant,
        );

        // FIXED: Use the original Hive key to ensure we update the same record
        if (widget.noteKey != null) {
          await notesBox.put(widget.noteKey, updatedNote);
          print('✅ Note updated with key: ${widget.noteKey}');
        } else {
          // Fallback: use the note's key property
          await notesBox.put(widget.note!.key, updatedNote);
          print('✅ Note updated with key: ${widget.note!.key}');
        }
      }

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.note == null ? 'Note created!' : 'Note updated!'),
          backgroundColor: AppTheme.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      print('❌ Error saving note: $e');
      _showSaveError('Failed to save note. Please try again.');
    }
  }

  void _deleteNote() async {
    if (widget.note == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Note',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
            style: GoogleFonts.poppins(
              color: AppTheme.getSecondaryTextColor(context),
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _performDelete();
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
        );
      },
    );
  }

  Future<void> _performDelete() async {
    try {
      final notesBox = Hive.box<Note>('notes');

      // FIXED: Multiple ways to ensure proper deletion
      if (widget.noteKey != null) {
        // Method 1: Delete by key (most reliable)
        await notesBox.delete(widget.noteKey);
        print('🗑️ Note deleted by key: ${widget.noteKey}');
      } else if (widget.note != null) {
        // Method 2: Delete using HiveObject
        await widget.note!.delete();
        print('🗑️ Note deleted using HiveObject: ${widget.note!.key}');
      }

      // Verify deletion
      final remainingNotes = notesBox.values.toList();
      print('📊 Total notes after deletion: ${remainingNotes.length}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note deleted successfully'),
          backgroundColor: AppTheme.getPrimaryColor(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).pop(); // Go back to notes list

    } catch (e) {
      print('❌ Error deleting note: $e');
      _showSaveError('Failed to delete note. Please try again.');
    }
  }

  void _showSaveError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              child: _buildEditorContent(),
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
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: AppTheme.getGlassmorphicHeaderDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, color: AppTheme.getHeaderTextColor(context)),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.getHeaderIconBackground(context),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note == null ? 'New Note' : 'Edit Note',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getHeaderTextColor(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.note == null ? 'Capture your financial thoughts' : 'Update your note',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.getHeaderTextColor(context).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.note != null)
                IconButton(
                  onPressed: _deleteNote,
                  icon: Icon(Icons.delete_outline_rounded, color: AppTheme.getHeaderTextColor(context)),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.getHeaderIconBackground(context),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isImportant = !_isImportant;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: _isImportant 
                    ? LinearGradient(
                        colors: [Colors.amber.withOpacity(0.25), Colors.amber.withOpacity(0.15)],
                      )
                    : LinearGradient(
                        colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: _isImportant ? Border.all(color: Colors.amber, width: 1.5) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isImportant ? Icons.star_rounded : Icons.star_border_rounded,
                    color: _isImportant ? Colors.amber : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Important',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _isImportant ? Colors.amber : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Field
          GlassmorphicCard(
            blur: 15,
            opacity: isDark ? 0.08 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.getPrimaryColor(context).withOpacity(0.2),
                              AppTheme.getPrimaryColor(context).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.title_rounded,
                          size: 18,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'TITLE',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getSecondaryTextColor(context),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter note title...',
                      hintStyle: GoogleFonts.poppins(
                        color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: isDark 
                          ? Colors.white.withValues(alpha: 0.05) 
                          : Colors.white.withValues(alpha: 0.7),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark 
                              ? Colors.white.withValues(alpha: 0.1) 
                              : Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.getPrimaryColor(context),
                          width: 1.5,
                        ),
                      ),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Content Field
          Expanded(
            child: GlassmorphicCard(
              blur: 15,
              opacity: isDark ? 0.08 : 0.5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentOrange.withOpacity(0.2),
                                AppTheme.accentOrange.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            size: 18,
                            color: AppTheme.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'CONTENT',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getSecondaryTextColor(context),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          height: 1.5,
                          color: AppTheme.getTextColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing your thoughts...\n\n💡 Tip: Use this space for financial goals, spending insights, or money-saving ideas!',
                          hintStyle: GoogleFonts.poppins(
                            color: AppTheme.getSecondaryTextColor(context).withValues(alpha: 0.6),
                            fontSize: 15,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          filled: true,
                          fillColor: isDark 
                              ? Colors.black.withValues(alpha: 0.2) 
                              : Colors.grey.withValues(alpha: 0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.accentOrange,
                              width: 1.5,
                            ),
                          ),
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Bottom Info and Save Button
          GlassmorphicCard(
            blur: 15,
            opacity: isDark ? 0.08 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Characters',
                            style: GoogleFonts.poppins(
                              color: AppTheme.getSecondaryTextColor(context),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_contentController.text.length}',
                            style: GoogleFonts.poppins(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (widget.note != null) ...[
                        const SizedBox(width: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last edited',
                              style: GoogleFonts.poppins(
                                color: AppTheme.getSecondaryTextColor(context),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(widget.note!.updatedAt),
                              style: GoogleFonts.poppins(
                                color: AppTheme.getTextColor(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  // Save Note Button with Orange Gradient
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accentOrange, Color(0xFFFF8A50)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'SAVE NOTE',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
}