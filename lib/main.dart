// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:hive_flutter/hive_flutter.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// // // import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
// // // import 'package:smart_expense_tracker/models/expense_model.dart';
// // // import 'package:smart_expense_tracker/models/goal_model.dart';
// // // import 'package:smart_expense_tracker/models/note_model.dart';
// // // import 'package:smart_expense_tracker/models/user_model.dart';
// // // import 'package:smart_expense_tracker/models/category_model.dart';
// // // import 'package:smart_expense_tracker/models/budget_model.dart';
// // // import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
// // // import 'firebase_options.dart';
// // //
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await Firebase.initializeApp(
// // //     options: DefaultFirebaseOptions.currentPlatform,
// // //   );
// // //
// // //   await Hive.initFlutter();
// // //
// // //   // Register All Hive Adapters
// // //   Hive.registerAdapter(ExpenseAdapter());
// // //   Hive.registerAdapter(GoalAdapter());
// // //   Hive.registerAdapter(NoteAdapter());
// // //   Hive.registerAdapter(UserModelAdapter());
// // //   Hive.registerAdapter(CategoryAdapter());
// // //   Hive.registerAdapter(BudgetAdapter());
// // //   Hive.registerAdapter(BudgetTypeAdapter());
// // //
// // //   // Clear existing budget data to fix migration issues
// // //   try {
// // //     await Hive.deleteBoxFromDisk('budgets');
// // //     print('✅ Cleared old budget data for migration');
// // //   } catch (e) {
// // //     print('ℹ️ No existing budget data to clear: $e');
// // //   }
// // //
// // //   // Open Hive boxes
// // //   await Hive.openBox<Expense>('expenses');
// // //   await Hive.openBox<Goal>('goals');
// // //   await Hive.openBox<Note>('notes');
// // //   await Hive.openBox<UserModel>('user');
// // //   await Hive.openBox<Category>('categories');
// // //   await Hive.openBox<Budget>('budgets');
// // //
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Provider<AuthService>(
// // //       create: (_) => AuthService(),
// // //       child: MaterialApp(
// // //         title: 'Smart Expense Tracker',
// // //         theme: AppTheme.lightTheme,
// // //         debugShowCheckedModeBanner: false,
// // //         home: const AuthChecker(),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'package:hive_flutter/hive_flutter.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// // // import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
// // // import 'package:smart_expense_tracker/models/expense_model.dart';
// // // import 'package:smart_expense_tracker/models/goal_model.dart';
// // // import 'package:smart_expense_tracker/models/note_model.dart';
// // // import 'package:smart_expense_tracker/models/user_model.dart';
// // // import 'package:smart_expense_tracker/models/category_model.dart';
// // // import 'package:smart_expense_tracker/models/budget_model.dart';
// // // import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
// // // import 'firebase_options.dart';
// // //
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //   await Firebase.initializeApp(
// // //     options: DefaultFirebaseOptions.currentPlatform,
// // //   );
// // //
// // //   await Hive.initFlutter();
// // //
// // //   // Register All Hive Adapters
// // //   Hive.registerAdapter(ExpenseAdapter());
// // //   Hive.registerAdapter(GoalAdapter());
// // //   Hive.registerAdapter(NoteAdapter());
// // //   Hive.registerAdapter(UserModelAdapter());
// // //   Hive.registerAdapter(CategoryAdapter());
// // //   Hive.registerAdapter(BudgetAdapter());
// // //   Hive.registerAdapter(BudgetTypeAdapter());
// // //
// // //   // REMOVED: Don't delete budgets box every time!
// // //   // This was causing your data loss
// // //
// // //   // Open Hive boxes
// // //   await Hive.openBox<Expense>('expenses');
// // //   await Hive.openBox<Goal>('goals');
// // //   await Hive.openBox<Note>('notes');
// // //   await Hive.openBox<UserModel>('user');
// // //   await Hive.openBox<Category>('categories');
// // //   await Hive.openBox<Budget>('budgets');
// // //
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Provider<AuthService>(
// // //       create: (_) => AuthService(),
// // //       child: MaterialApp(
// // //         title: 'Smart Expense Tracker',
// // //         theme: AppTheme.lightTheme,
// // //         debugShowCheckedModeBanner: false,
// // //         home: const AuthChecker(),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// // // notes issue
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:hive_flutter/hive_flutter.dart';
// // import 'package:provider/provider.dart';
// // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// // import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
// // import 'package:smart_expense_tracker/models/expense_model.dart';
// // import 'package:smart_expense_tracker/models/goal_model.dart';
// // import 'package:smart_expense_tracker/models/note_model.dart';
// // import 'package:smart_expense_tracker/models/user_model.dart';
// // import 'package:smart_expense_tracker/models/category_model.dart';
// // import 'package:smart_expense_tracker/models/budget_model.dart';
// // import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
// // import 'firebase_options.dart';
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //
// //   await Hive.initFlutter();
// //
// //   // Register All Hive Adapters
// //   Hive.registerAdapter(ExpenseAdapter());
// //   Hive.registerAdapter(GoalAdapter());
// //   Hive.registerAdapter(NoteAdapter());
// //   Hive.registerAdapter(UserModelAdapter());
// //   Hive.registerAdapter(CategoryAdapter());
// //   Hive.registerAdapter(BudgetAdapter());
// //   Hive.registerAdapter(BudgetTypeAdapter());
// //
// //   // FIX: Only delete and recreate the notes box to fix the schema issue
// //   try {
// //     await Hive.deleteBoxFromDisk('notes');
// //     print('Deleted old notes box to fix schema migration');
// //   } catch (e) {
// //     print('No existing notes box to delete: $e');
// //   }
// //
// //   // Open Hive boxes
// //   await Hive.openBox<Expense>('expenses');
// //   await Hive.openBox<Goal>('goals');
// //   await Hive.openBox<Note>('notes'); // This will create a fresh box with new schema
// //   await Hive.openBox<UserModel>('user');
// //   await Hive.openBox<Category>('categories');
// //   await Hive.openBox<Budget>('budgets');
// //
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Provider<AuthService>(
// //       create: (_) => AuthService(),
// //       child: MaterialApp(
// //         title: 'Smart Expense Tracker',
// //         theme: AppTheme.lightTheme,
// //         debugShowCheckedModeBanner: false,
// //         home: const AuthChecker(),
// //       ),
// //     );
// //   }
// // }
//
// // notes
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:hive_flutter/hive_flutter.dart';
// // import 'package:provider/provider.dart';
// // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// // import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
// // import 'package:smart_expense_tracker/models/expense_model.dart';
// // import 'package:smart_expense_tracker/models/goal_model.dart';
// // import 'package:smart_expense_tracker/models/note_model.dart';
// // import 'package:smart_expense_tracker/models/user_model.dart';
// // import 'package:smart_expense_tracker/models/category_model.dart';
// // import 'package:smart_expense_tracker/models/budget_model.dart';
// // import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
// // import 'firebase_options.dart';
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );
// //
// //   await Hive.initFlutter();
// //
// //   // Register All Hive Adapters
// //   Hive.registerAdapter(ExpenseAdapter());
// //   Hive.registerAdapter(GoalAdapter());
// //   Hive.registerAdapter(NoteAdapter());
// //   Hive.registerAdapter(UserModelAdapter());
// //   Hive.registerAdapter(CategoryAdapter());
// //   Hive.registerAdapter(BudgetAdapter());
// //   Hive.registerAdapter(BudgetTypeAdapter());
// //
// //   // FIXED: Remove the automatic deletion - only open boxes normally
// //   await _openBoxesSafely();
// //
// //   runApp(const MyApp());
// // }
// //
// // Future<void> _openBoxesSafely() async {
// //   // Open all boxes normally without deleting anything
// //   await Hive.openBox<Expense>('expenses');
// //   await Hive.openBox<Goal>('goals');
// //
// //   // Try to open notes box normally first
// //   try {
// //     await Hive.openBox<Note>('notes');
// //     print('Notes box opened successfully - your notes are safe!');
// //   } catch (e) {
// //     // Only delete if there's actually an error opening the box
// //     print('Error opening notes box: $e. Recreating...');
// //     await Hive.deleteBoxFromDisk('notes');
// //     await Hive.openBox<Note>('notes');
// //   }
// //
// //   await Hive.openBox<UserModel>('user');
// //   await Hive.openBox<Category>('categories');
// //   await Hive.openBox<Budget>('budgets');
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Provider<AuthService>(
// //       create: (_) => AuthService(),
// //       child: MaterialApp(
// //         title: 'Smart Expense Tracker',
// //         theme: AppTheme.lightTheme,
// //         debugShowCheckedModeBanner: false,
// //         home: const AuthChecker(),
// //       ),
// //     );
// //   }
// //}
//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
// import 'package:smart_expense_tracker/models/expense_model.dart';
// import 'package:smart_expense_tracker/models/goal_model.dart';
// import 'package:smart_expense_tracker/models/note_model.dart';
// import 'package:smart_expense_tracker/models/user_model.dart';
// import 'package:smart_expense_tracker/models/category_model.dart';
// import 'package:smart_expense_tracker/models/budget_model.dart';
// import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
// import 'firebase_options.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   await Hive.initFlutter();
//
//   // Register All Hive Adapters
//   Hive.registerAdapter(ExpenseAdapter());
//   Hive.registerAdapter(GoalAdapter());
//   Hive.registerAdapter(NoteAdapter());
//   Hive.registerAdapter(UserModelAdapter());
//   Hive.registerAdapter(CategoryAdapter());
//   Hive.registerAdapter(BudgetAdapter());
//   Hive.registerAdapter(BudgetTypeAdapter());
//
//   // FIXED: Delete goals box to fix schema migration, then open all boxes
//   await _openBoxesWithMigration();
//
//   runApp(const MyApp());
// }
//
// Future<void> _openBoxesWithMigration() async {
//   print('Starting Hive box migration...');
//
//   // Delete goals box to fix schema migration issue
//   try {
//     await Hive.deleteBoxFromDisk('goals');
//     print('✅ Deleted goals box to fix schema migration');
//   } catch (e) {
//     print('ℹ️ No goals box to delete: $e');
//   }
//
//   // Delete notes box if it has schema issues
//   try {
//     await Hive.deleteBoxFromDisk('notes');
//     print('✅ Deleted notes box to fix schema migration');
//   } catch (e) {
//     print('ℹ️ No notes box to delete: $e');
//   }
//
//   // Now open all boxes fresh
//   try {
//     await Hive.openBox<Expense>('expenses');
//     print('✅ Expenses box opened successfully');
//   } catch (e) {
//     print('❌ Error opening expenses box: $e');
//   }
//
//   try {
//     await Hive.openBox<Goal>('goals');
//     print('✅ Goals box opened successfully with new schema');
//   } catch (e) {
//     print('❌ Error opening goals box: $e');
//   }
//
//   try {
//     await Hive.openBox<Note>('notes');
//     print('✅ Notes box opened successfully with new schema');
//   } catch (e) {
//     print('❌ Error opening notes box: $e');
//   }
//
//   try {
//     await Hive.openBox<UserModel>('user');
//     print('✅ User box opened successfully');
//   } catch (e) {
//     print('❌ Error opening user box: $e');
//   }
//
//   try {
//     await Hive.openBox<Category>('categories');
//     print('✅ Categories box opened successfully');
//   } catch (e) {
//     print('❌ Error opening categories box: $e');
//   }
//
//   try {
//     await Hive.openBox<Budget>('budgets');
//     print('✅ Budgets box opened successfully');
//   } catch (e) {
//     print('❌ Error opening budgets box: $e');
//   }
//
//   print('Hive box migration completed!');
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Provider<AuthService>(
//       create: (_) => AuthService(),
//       child: MaterialApp(
//         title: 'Smart Expense Tracker',
//         theme: AppTheme.lightTheme,
//         debugShowCheckedModeBanner: false,
//         home: const AuthChecker(),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';
import 'package:smart_expense_tracker/models/note_model.dart';
import 'package:smart_expense_tracker/models/user_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  // Register All Hive Adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(BudgetTypeAdapter());

  // Open boxes safely without deleting data
  await _openBoxesSafely();

  runApp(const MyApp());
}

Future<void> _openBoxesSafely() async {
  // Open all boxes normally - only delete if there's a schema error
  try {
    await Hive.openBox<Expense>('expenses');
  } catch (e) {
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.openBox<Expense>('expenses');
  }

  try {
    await Hive.openBox<Goal>('goals');
  } catch (e) {
    await Hive.deleteBoxFromDisk('goals');
    await Hive.openBox<Goal>('goals');
  }

  try {
    await Hive.openBox<Note>('notes');
  } catch (e) {
    await Hive.deleteBoxFromDisk('notes');
    await Hive.openBox<Note>('notes');
  }

  try {
    await Hive.openBox<UserModel>('user');
  } catch (e) {
    await Hive.deleteBoxFromDisk('user');
    await Hive.openBox<UserModel>('user');
  }

  try {
    await Hive.openBox<Category>('categories');
  } catch (e) {
    await Hive.deleteBoxFromDisk('categories');
    await Hive.openBox<Category>('categories');
  }

  try {
    await Hive.openBox<Budget>('budgets');
  } catch (e) {
    await Hive.deleteBoxFromDisk('budgets');
    await Hive.openBox<Budget>('budgets');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Smart Expense Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthChecker(),
      ),
    );
  }
}