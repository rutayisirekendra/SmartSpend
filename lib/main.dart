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
//   // Open boxes safely without deleting data
//   await _openBoxesSafely();
//
//   runApp(const MyApp());
// }
//
// Future<void> _openBoxesSafely() async {
//   // Open all boxes normally - only delete if there's a schema error
//   try {
//     await Hive.openBox<Expense>('expenses');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('expenses');
//     await Hive.openBox<Expense>('expenses');
//   }
//
//   try {
//     await Hive.openBox<Goal>('goals');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('goals');
//     await Hive.openBox<Goal>('goals');
//   }
//
//   try {
//     await Hive.openBox<Note>('notes');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('notes');
//     await Hive.openBox<Note>('notes');
//   }
//
//   try {
//     await Hive.openBox<UserModel>('user');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('user');
//     await Hive.openBox<UserModel>('user');
//   }
//
//   try {
//     await Hive.openBox<Category>('categories');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('categories');
//     await Hive.openBox<Category>('categories');
//   }
//
//   try {
//     await Hive.openBox<Budget>('budgets');
//   } catch (e) {
//     await Hive.deleteBoxFromDisk('budgets');
//     await Hive.openBox<Budget>('budgets');
//   }
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:firebase_core/firebase_core.dart';
// REMOVED: Firebase App Check causes DNS issues in Android emulator
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/app/theme/theme_provider.dart';
import 'package:smart_expense_tracker/features/auth/screens/auth_checker.dart';
import 'package:smart_expense_tracker/features/onboarding/screens/onboarding_screen.dart';
import 'package:smart_expense_tracker/features/splash/splash_screen.dart';
import 'package:smart_expense_tracker/features/main/screens/main_screen.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';
import 'package:smart_expense_tracker/models/note_model.dart';
import 'package:smart_expense_tracker/models/user_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/notification_model.dart';
import 'package:smart_expense_tracker/services/firebase_auth_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kDebugMode) {
      print('🚀 Initializing Smart Expense Tracker...');
      print('📱 Platform: ${Platform.operatingSystem}');
    }
    
    // Initialize Firebase with proper error handling
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      print('✅ Firebase initialized successfully');
      print('🔧 Running in DEBUG mode - App Check is DISABLED');
      print('📝 This prevents DNS errors in Android emulator');
      print('✅ Firebase Authentication is ready');
    }

    // NOTE: Firebase App Check is completely disabled to fix emulator DNS issues
    // The error "Unable to resolve host firebaseappcheck.googleapis.com" 
    // occurs because Android emulators have limited network access
    // 
    // For production deployment, you can:
    // 1. Uncomment the firebase_app_check import
    // 2. Add App Check activation in release mode only
    // 3. Ensure proper DNS configuration on real devices
    
  } catch (e) {
    if (kDebugMode) {
      print('❌ CRITICAL: Firebase initialization failed: $e');
      print('⚠️ Please check:');
      print('   1. google-services.json exists in android/app/');
      print('   2. firebase_options.dart is properly generated');
      print('   3. Internet connection is available');
    }
    // Don't rethrow - let the app start anyway with limited functionality
  }

  // Initialize Hive
  if (kDebugMode) {
    print('📦 Initializing Hive database...');
  }
  await Hive.initFlutter();

  // Register All Hive Adapters
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(BudgetTypeAdapter());
  Hive.registerAdapter(NotificationModelAdapter());
  Hive.registerAdapter(NotificationTypeAdapter());

  // Open boxes safely without deleting data
  await _openBoxesSafely();

  runApp(const MyApp());
}

Future<void> _openBoxesSafely() async {
  if (kDebugMode) {
    print('🔄 Opening Hive boxes safely...');
  }
  
  // Open all boxes normally - only delete if there's a schema error
  try {
    if (kDebugMode) print('📦 Opening expenses box...');
    await Hive.openBox<Expense>('expenses');
    if (kDebugMode) print('✅ Expenses box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening expenses box: $e');
      print('🔄 Deleting and recreating expenses box...');
    }
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.openBox<Expense>('expenses');
    if (kDebugMode) print('✅ Expenses box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening goals box...');
    await Hive.openBox<Goal>('goals');
    if (kDebugMode) print('✅ Goals box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening goals box: $e');
      print('🔄 Deleting and recreating goals box...');
    }
    await Hive.deleteBoxFromDisk('goals');
    await Hive.openBox<Goal>('goals');
    if (kDebugMode) print('✅ Goals box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening notes box...');
    await Hive.openBox<Note>('notes');
    if (kDebugMode) print('✅ Notes box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening notes box: $e');
      print('🔄 Deleting and recreating notes box...');
    }
    await Hive.deleteBoxFromDisk('notes');
    await Hive.openBox<Note>('notes');
    if (kDebugMode) print('✅ Notes box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening user box...');
    await Hive.openBox<UserModel>('user');
    if (kDebugMode) print('✅ User box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening user box: $e');
      print('🔄 Deleting and recreating user box...');
    }
    await Hive.deleteBoxFromDisk('user');
    await Hive.openBox<UserModel>('user');
    if (kDebugMode) print('✅ User box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening categories box...');
    await Hive.openBox<Category>('categories');
    if (kDebugMode) print('✅ Categories box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening categories box: $e');
      print('🔄 Deleting and recreating categories box...');
    }
    await Hive.deleteBoxFromDisk('categories');
    await Hive.openBox<Category>('categories');
    if (kDebugMode) print('✅ Categories box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening budgets box...');
    await Hive.openBox<Budget>('budgets');
    if (kDebugMode) print('✅ Budgets box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening budgets box: $e');
      print('🔄 Deleting and recreating budgets box...');
    }
    await Hive.deleteBoxFromDisk('budgets');
    await Hive.openBox<Budget>('budgets');
    if (kDebugMode) print('✅ Budgets box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening notifications box...');
    await Hive.openBox<NotificationModel>('notifications');
    if (kDebugMode) print('✅ Notifications box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening notifications box: $e');
      print('🔄 Deleting and recreating notifications box...');
    }
    await Hive.deleteBoxFromDisk('notifications');
    await Hive.openBox<NotificationModel>('notifications');
    if (kDebugMode) print('✅ Notifications box recreated successfully');
  }

  try {
    if (kDebugMode) print('📦 Opening appData box...');
    await Hive.openBox('appData'); // For streak data and other app settings
    if (kDebugMode) print('✅ AppData box opened successfully');
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Error opening appData box: $e');
      print('🔄 Deleting and recreating appData box...');
    }
    await Hive.deleteBoxFromDisk('appData');
    await Hive.openBox('appData');
    if (kDebugMode) print('✅ AppData box recreated successfully');
  }
  
  if (kDebugMode) {
    print('🎉 All Hive boxes opened successfully!');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Expense Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            // Add named routes for better navigation management
            routes: {
              '/': (context) => const SplashScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/auth': (context) => const AuthChecker(),
              '/main': (context) => const MainScreen(),
            },
          );
        },
      ),
    );
  }
}