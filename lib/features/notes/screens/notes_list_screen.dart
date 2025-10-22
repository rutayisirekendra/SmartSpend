// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
// import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
// import 'package:smart_expense_tracker/features/notes/screens/note_editor_screen.dart';
// import 'package:smart_expense_tracker/models/note_model.dart';
//
// class NotesListScreen extends StatefulWidget {
//   const NotesListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<NotesListScreen> createState() => _NotesListScreenState();
// }
//
// class _NotesListScreenState extends State<NotesListScreen> {
//   NoteFilter _selectedFilter = NoteFilter.all;
//   NoteSort _currentSort = NoteSort.newest;
//   List<String> _deletedNoteIds = []; // Track deleted notes to prevent Dismissible errors
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.offWhite,
//       body: Column(
//         children: [
//           // Enhanced Header Section
//           _buildHeaderSection(),
//           Expanded(
//             child: ValueListenableBuilder<Box<Note>>(
//               valueListenable: Hive.box<Note>('notes').listenable(),
//               builder: (context, box, _) {
//                 final notes = box.values.toList().cast<Note>();
//
//                 // Filter notes based on selection and remove deleted ones
//                 final filteredNotes = _filterNotes(notes).where((note) => !_deletedNoteIds.contains(note.id)).toList();
//
//                 // Sort the filtered notes
//                 final sortedNotes = _sortNotes(filteredNotes);
//
//                 return sortedNotes.isEmpty
//                     ? _buildEmptyState(context)
//                     : _buildNotesList(context, sortedNotes, box);
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const NoteEditorScreen())
//         ),
//         backgroundColor: AppTheme.accentOrange,
//         foregroundColor: Colors.white,
//         elevation: 4,
//         icon: const Icon(Icons.note_add_rounded),
//         label: Text(
//           'Create Note',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//             fontSize: 14,
//           ),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
//
//   Widget _buildHeaderSection() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 16,
//         bottom: 24,
//         left: 20,
//         right: 20,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppTheme.primaryTeal,
//             AppTheme.primaryTeal.withOpacity(0.9),
//           ],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Back Button and Title Row
//           Row(
//             children: [
//               IconButton(
//                 onPressed: () {
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const MainScreen()),
//                         (route) => false,
//                   );
//                 },
//                 icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
//                 style: IconButton.styleFrom(
//                   backgroundColor: Colors.white.withOpacity(0.2),
//                   padding: const EdgeInsets.all(8),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Financial Notes',
//                       style: GoogleFonts.poppins(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         height: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Capture your financial thoughts and goals',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.white.withOpacity(0.8),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // Enhanced Notes Filter Toggle
//           Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildFilterToggle('All', NoteFilter.all),
//                 const SizedBox(width: 4),
//                 _buildFilterToggle('Important', NoteFilter.important),
//                 const SizedBox(width: 4),
//                 _buildFilterToggle('Completed', NoteFilter.completed),
//                 const SizedBox(width: 4),
//                 _buildFilterToggle('Active', NoteFilter.active),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterToggle(String text, NoteFilter filter) {
//     final isSelected = _selectedFilter == filter;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedFilter = filter;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             text,
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.8),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Note> _filterNotes(List<Note> notes) {
//     switch (_selectedFilter) {
//       case NoteFilter.important:
//       // FIXED: Allow completed notes to also be important
//         return notes.where((note) => note.isImportant).toList();
//       case NoteFilter.completed:
//         return notes.where((note) => note.isCompleted).toList();
//       case NoteFilter.active:
//         return notes.where((note) => !note.isCompleted).toList();
//       case NoteFilter.recent:
//         final weekAgo = DateTime.now().subtract(const Duration(days: 7));
//         return notes.where((note) => note.updatedAt.isAfter(weekAgo)).toList();
//       case NoteFilter.all:
//       default:
//         return notes;
//     }
//   }
//
//   List<Note> _sortNotes(List<Note> notes) {
//     // Create a copy to avoid modifying the original list
//     final sortedNotes = List<Note>.from(notes);
//
//     switch (_currentSort) {
//       case NoteSort.newest:
//         sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//         break;
//       case NoteSort.oldest:
//         sortedNotes.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
//         break;
//       case NoteSort.important:
//       // Fixed: Proper boolean sorting - important notes first
//         sortedNotes.sort((a, b) {
//           if (a.isImportant && !b.isImportant) return -1;
//           if (!a.isImportant && b.isImportant) return 1;
//           return b.updatedAt.compareTo(a.updatedAt); // Then sort by newest
//         });
//         break;
//     }
//     return sortedNotes;
//   }
//
//   Widget _buildEmptyState(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(32.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.note_alt_rounded,
//               size: 60,
//               color: Colors.grey[400],
//             ),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'No Notes Yet',
//             style: GoogleFonts.poppins(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: Colors.grey[600],
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Capture your financial thoughts, goals,\nand spending insights in one place.',
//             textAlign: TextAlign.center,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.grey[500],
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotesList(BuildContext context, List<Note> notes, Box<Note> box) {
//     return ListView(
//       padding: const EdgeInsets.all(20),
//       children: [
//         // Enhanced Notes Summary Card
//         ModernCard(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'NOTES SUMMARY',
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[600],
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: AppTheme.accentOrange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.description_rounded,
//                           size: 14,
//                           color: AppTheme.accentOrange,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           '${notes.length} NOTES',
//                           style: GoogleFonts.poppins(
//                             fontSize: 10,
//                             fontWeight: FontWeight.w600,
//                             color: AppTheme.accentOrange,
//                             letterSpacing: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   _buildSummaryItem(notes.length.toString(), 'Total'),
//                   _buildSummaryItem(
//                     notes.where((note) => note.isImportant).length.toString(),
//                     'Important',
//                   ),
//                   _buildSummaryItem(
//                     notes.where((note) => note.isCompleted).length.toString(),
//                     'Completed',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),
//
//         // Notes List Header with Sort Options
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "YOUR NOTES",
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[600],
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryTeal.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     '${notes.length}',
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: AppTheme.primaryTeal,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             // Sort Button with current sort indicator
//             PopupMenuButton<NoteSort>(
//               icon: Icon(Icons.sort_rounded, color: AppTheme.primaryTeal),
//               onSelected: (sort) {
//                 setState(() {
//                   _currentSort = sort;
//                 });
//               },
//               itemBuilder: (context) => [
//                 PopupMenuItem(
//                   value: NoteSort.newest,
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.new_releases_rounded,
//                         color: _currentSort == NoteSort.newest ? AppTheme.primaryTeal : Colors.grey,
//                       ),
//                       const SizedBox(width: 8),
//                       Text('Newest First', style: GoogleFonts.poppins()),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: NoteSort.oldest,
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.history_rounded,
//                         color: _currentSort == NoteSort.oldest ? AppTheme.primaryTeal : Colors.grey,
//                       ),
//                       const SizedBox(width: 8),
//                       Text('Oldest First', style: GoogleFonts.poppins()),
//                     ],
//                   ),
//                 ),
//                 PopupMenuItem(
//                   value: NoteSort.important,
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.star_rounded,
//                         color: _currentSort == NoteSort.important ? AppTheme.primaryTeal : Colors.grey,
//                       ),
//                       const SizedBox(width: 8),
//                       Text('Important First', style: GoogleFonts.poppins()),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // Enhanced Notes List with Swipe Actions
//         ...notes.map((note) {
//           // FIXED: Only render Dismissible if note hasn't been deleted
//           if (_deletedNoteIds.contains(note.id)) {
//             return const SizedBox.shrink(); // Don't render deleted notes
//           }
//
//           return Padding(
//             padding: const EdgeInsets.only(bottom: 12.0),
//             child: Dismissible(
//               key: Key(note.id), // Unique key for each note
//               direction: DismissDirection.endToStart,
//               background: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Align(
//                   alignment: Alignment.centerRight,
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 20.0),
//                     child: Icon(
//                       Icons.delete_rounded,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ),
//               ),
//               confirmDismiss: (direction) async {
//                 return await _showDeleteConfirmation(note);
//               },
//               onDismissed: (direction) {
//                 // FIXED: Immediately remove from tree and delete
//                 setState(() {
//                   _deletedNoteIds.add(note.id); // Mark as deleted
//                 });
//                 _deleteNote(note, box);
//               },
//               child: GestureDetector(
//                 onTap: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => NoteEditorScreen(note: note),
//                     ),
//                   );
//                 },
//                 child: _buildEnhancedNoteItem(note, box),
//               ),
//             ),
//           );
//         }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildEnhancedNoteItem(Note note, Box<Note> box) {
//     return ModernCard(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header with title and actions
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   note.title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: note.isCompleted ? Colors.grey : AppTheme.darkGrey,
//                     decoration: note.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//               // Quick Actions
//               Row(
//                 children: [
//                   // Complete/Incomplete Toggle
//                   IconButton(
//                     icon: Icon(
//                       note.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
//                       color: note.isCompleted ? Colors.green : Colors.grey,
//                       size: 20,
//                     ),
//                     onPressed: () => _toggleNoteCompletion(note, box),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                   const SizedBox(width: 8),
//                   // Important Toggle
//                   IconButton(
//                     icon: Icon(
//                       note.isImportant ? Icons.star_rounded : Icons.star_border_rounded,
//                       color: note.isImportant ? AppTheme.accentOrange : Colors.grey,
//                       size: 20,
//                     ),
//                     onPressed: () => _toggleNoteImportance(note, box),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                   const SizedBox(width: 8),
//                   // Edit Button
//                   IconButton(
//                     icon: Icon(Icons.edit_rounded, color: AppTheme.primaryTeal, size: 20),
//                     onPressed: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => NoteEditorScreen(note: note),
//                         ),
//                       );
//                     },
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//
//           // Note Content Preview
//           Text(
//             note.content,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: note.isCompleted ? Colors.grey : Colors.grey[700],
//               decoration: note.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 12),
//
//           // Footer with metadata
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Tags/Categories
//               if (note.tags.isNotEmpty) ...[
//                 Wrap(
//                   spacing: 6,
//                   children: note.tags.take(2).map((tag) => Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: AppTheme.primaryTeal.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       tag,
//                       style: GoogleFonts.poppins(
//                         fontSize: 10,
//                         color: AppTheme.primaryTeal,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   )).toList(),
//                 ),
//               ],
//
//               // Date and status
//               Text(
//                 _formatDate(note.updatedAt),
//                 style: GoogleFonts.poppins(
//                   fontSize: 10,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryItem(String value, String label) {
//     return Expanded(
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: AppTheme.primaryTeal,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper Methods
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays == 0) {
//       return 'Today';
//     } else if (difference.inDays == 1) {
//       return 'Yesterday';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
//
//   void _toggleNoteCompletion(Note note, Box<Note> box) {
//     final updatedNote = note.copyWith(
//       isCompleted: !note.isCompleted,
//       updatedAt: DateTime.now(),
//     );
//     box.put(updatedNote.id, updatedNote);
//   }
//
//   void _toggleNoteImportance(Note note, Box<Note> box) {
//     final updatedNote = note.copyWith(
//       isImportant: !note.isImportant,
//       updatedAt: DateTime.now(),
//     );
//     box.put(updatedNote.id, updatedNote);
//   }
//
//   Future<bool> _showDeleteConfirmation(Note note) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Delete Note', style: GoogleFonts.poppins()),
//         content: Text('Are you sure you want to delete "${note.title}"?', style: GoogleFonts.poppins()),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text('Cancel', style: GoogleFonts.poppins()),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }
//
//   void _deleteNote(Note note, Box<Note> box) {
//     box.delete(note.id);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Note deleted', style: GoogleFonts.poppins()),
//         backgroundColor: AppTheme.accentOrange,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }
// }
//
// enum NoteFilter { all, important, completed, active, recent }
// enum NoteSort { newest, oldest, important }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/modern_card.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/features/notes/screens/note_editor_screen.dart';
import 'package:smart_expense_tracker/models/note_model.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  NoteFilter _selectedFilter = NoteFilter.all;
  NoteSort _currentSort = NoteSort.newest;
  List<String> _deletedNoteIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          _buildHeaderSection(),
          Expanded(
            child: ValueListenableBuilder<Box<Note>>(
              valueListenable: Hive.box<Note>('notes').listenable(),
              builder: (context, box, _) {
                final notes = box.values.toList().cast<Note>();
                final filteredNotes = _filterNotes(notes).where((note) => !_deletedNoteIds.contains(note.id)).toList();
                final sortedNotes = _sortNotes(filteredNotes);

                return sortedNotes.isEmpty
                    ? _buildEmptyState(context)
                    : _buildNotesList(context, sortedNotes, box);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen())
        ),
        backgroundColor: AppTheme.accentOrange,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.all(8),
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
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Capture your financial thoughts and goals',
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
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
              color: isSelected ? AppTheme.primaryTeal : Colors.white.withOpacity(0.8),
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
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_alt_rounded,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notes Yet',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Capture your financial thoughts, goals,\nand spending insights in one place.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[500],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes, Box<Note> box) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ModernCard(
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
                      color: Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_rounded,
                          size: 14,
                          color: AppTheme.accentOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${notes.length} NOTES',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentOrange,
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
                    notes.where((note) => note.isCompleted).length.toString(),
                    'Completed',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "YOUR NOTES",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${notes.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ),
              ],
            ),
            PopupMenuButton<NoteSort>(
              icon: Icon(Icons.sort_rounded, color: AppTheme.primaryTeal),
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
                        color: _currentSort == NoteSort.newest ? AppTheme.primaryTeal : Colors.grey,
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
                        color: _currentSort == NoteSort.oldest ? AppTheme.primaryTeal : Colors.grey,
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
                        color: _currentSort == NoteSort.important ? AppTheme.primaryTeal : Colors.grey,
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
        ...notes.map((note) {
          if (_deletedNoteIds.contains(note.id)) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Dismissible(
              key: Key(note.id),
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
                  _deletedNoteIds.add(note.id);
                });
                _deleteNote(note, box);
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => NoteEditorScreen(note: note),
                    ),
                  );
                },
                child: _buildEnhancedNoteItem(note, box),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEnhancedNoteItem(Note note, Box<Note> box) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: note.isCompleted ? Colors.grey : AppTheme.darkGrey,
                    decoration: note.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      note.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: note.isCompleted ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _toggleNoteCompletion(note, box),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      note.isImportant ? Icons.star_rounded : Icons.star_border_rounded,
                      color: note.isImportant ? AppTheme.accentOrange : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _toggleNoteImportance(note, box),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.edit_rounded, color: AppTheme.primaryTeal, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.content,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: note.isCompleted ? Colors.grey : Colors.grey[700],
              decoration: note.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (note.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  children: note.tags.take(2).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )).toList(),
                ),
              ],
              Text(
                _formatDate(note.updatedAt),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
              color: AppTheme.primaryTeal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
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
    box.delete(note.id);
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