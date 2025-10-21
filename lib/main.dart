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

  // Clear existing budget data to fix migration issues
  try {
    await Hive.deleteBoxFromDisk('budgets');
    print('✅ Cleared old budget data for migration');
  } catch (e) {
    print('ℹ️ No existing budget data to clear: $e');
  }

  // Open Hive boxes
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Goal>('goals');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<UserModel>('user');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Budget>('budgets');

  runApp(const MyApp());
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