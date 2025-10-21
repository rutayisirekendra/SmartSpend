import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/models/note_model.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  const NoteEditorScreen({Key? key, this.note}) : super(key: key);

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

    final now = DateTime.now();
    final notesBox = Hive.box<Note>('notes');

    try {
      if (widget.note == null) {
        // Creating new note
        final newNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user_id',
          title: title,
          content: content,
          createdAt: now,
          updatedAt: now,
          isImportant: _isImportant,
          tags: [],
        );

        await notesBox.add(newNote);
        print('Note created: ${newNote.title}');

      } else {
        // Updating existing note
        final updatedNote = Note(
          id: widget.note!.id,
          userId: widget.note!.userId,
          title: title,
          content: content,
          createdAt: widget.note!.createdAt,
          updatedAt: now,
          isImportant: _isImportant,
          tags: widget.note!.tags,
        );

        // Find the index of the existing note and update it
        final noteIndex = notesBox.values.toList().indexWhere((note) => note.id == widget.note!.id);
        if (noteIndex != -1) {
          await notesBox.putAt(noteIndex, updatedNote);
          print('Note updated: ${updatedNote.title}');
        }
      }

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.note == null ? 'Note created!' : 'Note updated!'),
          backgroundColor: AppTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      Navigator.of(context).pop();

    } catch (e) {
      print('Error saving note: $e');
      _showSaveError('Failed to save note. Please try again.');
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
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Enhanced Header Section
          _buildHeaderSection(),
          Expanded(
            child: _buildEditorContent(),
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
        bottom: 20,
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
                  Navigator.of(context).pop();
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
                      widget.note == null ? 'New Note' : 'Edit Note',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.note == null ? 'Capture your financial thoughts' : 'Update your note',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Removed the top save button as requested
            ],
          ),
          SizedBox(height: 16),

          // Important Toggle
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isImportant = !_isImportant;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isImportant ? Colors.amber.withOpacity(0.2) : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: _isImportant ? Border.all(color: Colors.amber) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isImportant ? Icons.star_rounded : Icons.star_border_rounded,
                        color: _isImportant ? Colors.amber : Colors.white70,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Important',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildEditorContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Card
          ModernCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.title_rounded,
                        size: 16,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'TITLE',
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
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter note title...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 18,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkGrey,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Content Card
          Expanded(
            child: ModernCard(
              padding: EdgeInsets.all(20),
              child: Column(
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
                          Icons.edit_note_rounded,
                          size: 16,
                          color: AppTheme.accentOrange,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'CONTENT',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Start writing your thoughts...\n\n💡 Tip: Use this space for financial goals, spending insights, or money-saving ideas!',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.grey[800],
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

          // Character Count & Save Button
          SizedBox(height: 16),
          ModernCard(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_contentController.text.length} characters',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.note != null)
                  Text(
                    'Last edited: ${DateTime.now().toString().split(' ')[0]}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: Icon(Icons.save_rounded, size: 16),
                  label: Text(
                    'SAVE NOTE',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}