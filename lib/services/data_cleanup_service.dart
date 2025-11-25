import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_expense_tracker/models/budget_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/note_model.dart';
import 'package:smart_expense_tracker/models/goal_model.dart';

/// Service to manage data cleanup and migration for user data isolation
class DataCleanupService {
  
  /// Cleanup truly orphaned data (data with NO userId, null userId, or empty userId)
  /// This ONLY removes data without a valid userId - it preserves all user data
  /// Use this to clean up test data or data from before userId tracking was added
  static Future<void> cleanupOrphanedData(String currentUserId) async {
    if (kDebugMode) {
      print('🧹 Cleaning up orphaned data (no userId or empty userId only)');
    }
    
    try {
      await _cleanupOrphanedBudgets();
      await _cleanupOrphanedExpenses();
      await _cleanupOrphanedNotes();
      await _cleanupOrphanedGoals();
      
      if (kDebugMode) {
        print('✅ Orphaned data cleanup completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during data cleanup: $e');
      }
    }
  }
  
  /// Migrate old data without userId to current user
  /// Use this ONLY if you want to claim existing data for the current user
  static Future<void> migrateOrphanedDataToCurrentUser(String currentUserId) async {
    if (kDebugMode) {
      print('📦 Migrating orphaned data to user: $currentUserId');
    }
    
    try {
      await _migrateBudgets(currentUserId);
      await _migrateExpenses(currentUserId);
      await _migrateNotes(currentUserId);
      await _migrateGoals(currentUserId);
      
      if (kDebugMode) {
        print('✅ Data migration completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error during data migration: $e');
      }
    }
  }
  
  /// Delete ALL data from Hive boxes
  /// WARNING: This will delete all user data permanently!
  static Future<void> deleteAllData() async {
    if (kDebugMode) {
      print('⚠️ DELETING ALL DATA FROM HIVE');
    }
    
    try {
      await Hive.box<Budget>('budgets').clear();
      await Hive.box<Expense>('expenses').clear();
      await Hive.box<Note>('notes').clear();
      await Hive.box<Goal>('goals').clear();
      
      if (kDebugMode) {
        print('✅ All data deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting data: $e');
      }
    }
  }
  
  // Private helper methods - Clean up ONLY truly orphaned data
  
  static Future<void> _cleanupOrphanedBudgets() async {
    final box = Hive.box<Budget>('budgets');
    final toDelete = <dynamic>[];
    
    for (var key in box.keys) {
      final budget = box.get(key);
      // Only delete if budget is null or has no userId (empty or null)
      if (budget == null || budget.userId.isEmpty) {
        toDelete.add(key);
      }
    }
    
    for (var key in toDelete) {
      await box.delete(key);
    }
    
    if (kDebugMode && toDelete.isNotEmpty) {
      print('   🗑️ Cleaned up ${toDelete.length} orphaned budgets');
    }
  }
  
  static Future<void> _cleanupOrphanedExpenses() async {
    final box = Hive.box<Expense>('expenses');
    final toDelete = <dynamic>[];
    
    for (var key in box.keys) {
      final expense = box.get(key);
      // Only delete if expense is null or has no userId (empty or null)
      if (expense == null || expense.userId.isEmpty) {
        toDelete.add(key);
      }
    }
    
    for (var key in toDelete) {
      await box.delete(key);
    }
    
    if (kDebugMode && toDelete.isNotEmpty) {
      print('   🗑️ Cleaned up ${toDelete.length} orphaned expenses');
    }
  }
  
  static Future<void> _cleanupOrphanedNotes() async {
    final box = Hive.box<Note>('notes');
    final toDelete = <dynamic>[];
    
    for (var key in box.keys) {
      final note = box.get(key);
      // Only delete if note is null or has no userId (empty or null)
      if (note == null || note.userId.isEmpty) {
        toDelete.add(key);
      }
    }
    
    for (var key in toDelete) {
      await box.delete(key);
    }
    
    if (kDebugMode && toDelete.isNotEmpty) {
      print('   🗑️ Cleaned up ${toDelete.length} orphaned notes');
    }
  }
  
  static Future<void> _cleanupOrphanedGoals() async {
    final box = Hive.box<Goal>('goals');
    final toDelete = <dynamic>[];
    
    for (var key in box.keys) {
      final goal = box.get(key);
      // Only delete if goal is null or has no userId (empty or null)
      if (goal == null || goal.userId.isEmpty) {
        toDelete.add(key);
      }
    }
    
    for (var key in toDelete) {
      await box.delete(key);
    }
    
    if (kDebugMode && toDelete.isNotEmpty) {
      print('   🗑️ Cleaned up ${toDelete.length} goals');
    }
  }
  
  // Migration methods (for claiming orphaned data)
  
  static Future<void> _migrateBudgets(String currentUserId) async {
    final box = Hive.box<Budget>('budgets');
    int migrated = 0;
    
    for (var key in box.keys) {
      final budget = box.get(key);
      if (budget != null && (budget.userId.isEmpty || budget.userId == 'unknown')) {
        final updated = Budget(
          id: budget.id,
          totalAmount: budget.totalAmount,
          categoryBudgets: budget.categoryBudgets,
          month: budget.month,
          budgetType: budget.budgetType,
          startDate: budget.startDate,
          userId: currentUserId,
        );
        await box.put(key, updated);
        migrated++;
      }
    }
    
    if (kDebugMode && migrated > 0) {
      print('   📦 Migrated $migrated budgets');
    }
  }
  
  static Future<void> _migrateExpenses(String currentUserId) async {
    final box = Hive.box<Expense>('expenses');
    int migrated = 0;
    
    for (var key in box.keys) {
      final expense = box.get(key);
      if (expense != null && (expense.userId.isEmpty || expense.userId == 'unknown')) {
        final updated = Expense(
          id: expense.id,
          userId: currentUserId,
          category: expense.category,
          description: expense.description,
          amount: expense.amount,
          date: expense.date,
          vendor: expense.vendor,
        );
        await box.put(key, updated);
        migrated++;
      }
    }
    
    if (kDebugMode && migrated > 0) {
      print('   📦 Migrated $migrated expenses');
    }
  }
  
  static Future<void> _migrateNotes(String currentUserId) async {
    final box = Hive.box<Note>('notes');
    int migrated = 0;
    
    for (var key in box.keys) {
      final note = box.get(key);
      if (note != null && (note.userId.isEmpty || note.userId == 'unknown')) {
        final updated = note.copyWith(userId: currentUserId);
        await box.put(key, updated);
        migrated++;
      }
    }
    
    if (kDebugMode && migrated > 0) {
      print('   📦 Migrated $migrated notes');
    }
  }
  
  static Future<void> _migrateGoals(String currentUserId) async {
    final box = Hive.box<Goal>('goals');
    int migrated = 0;
    
    for (var key in box.keys) {
      final goal = box.get(key);
      if (goal != null && (goal.userId.isEmpty || goal.userId == 'unknown')) {
        final updated = Goal(
          id: goal.id,
          userId: currentUserId,
          name: goal.name,
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          targetDate: goal.targetDate,
          goalType: goal.goalType,
        );
        await box.put(key, updated);
        migrated++;
      }
    }
    
    if (kDebugMode && migrated > 0) {
      print('   📦 Migrated $migrated goals');
    }
  }
  
  /// Get statistics about data in Hive
  static Future<Map<String, dynamic>> getDataStatistics(String? currentUserId) async {
    final budgetBox = Hive.box<Budget>('budgets');
    final expenseBox = Hive.box<Expense>('expenses');
    final noteBox = Hive.box<Note>('notes');
    final goalBox = Hive.box<Goal>('goals');
    
    int userBudgets = 0;
    int otherBudgets = 0;
    int userExpenses = 0;
    int otherExpenses = 0;
    int userNotes = 0;
    int otherNotes = 0;
    int userGoals = 0;
    int otherGoals = 0;
    
    if (currentUserId != null) {
      for (var budget in budgetBox.values) {
        if (budget.userId == currentUserId) {
          userBudgets++;
        } else {
          otherBudgets++;
        }
      }
      
      for (var expense in expenseBox.values) {
        if (expense.userId == currentUserId) {
          userExpenses++;
        } else {
          otherExpenses++;
        }
      }
      
      for (var note in noteBox.values) {
        if (note.userId == currentUserId) {
          userNotes++;
        } else {
          otherNotes++;
        }
      }
      
      for (var goal in goalBox.values) {
        if (goal.userId == currentUserId) {
          userGoals++;
        } else {
          otherGoals++;
        }
      }
    }
    
    final stats = {
      'currentUserId': currentUserId,
      'userBudgets': userBudgets,
      'otherBudgets': otherBudgets,
      'userExpenses': userExpenses,
      'otherExpenses': otherExpenses,
      'userNotes': userNotes,
      'otherNotes': otherNotes,
      'userGoals': userGoals,
      'otherGoals': otherGoals,
      'totalBudgets': budgetBox.length,
      'totalExpenses': expenseBox.length,
      'totalNotes': noteBox.length,
      'totalGoals': goalBox.length,
    };
    
    if (kDebugMode) {
      print('📊 Data Statistics:');
      print('   Current User: $currentUserId');
      print('   User Budgets: $userBudgets / Other: $otherBudgets');
      print('   User Expenses: $userExpenses / Other: $otherExpenses');
      print('   User Notes: $userNotes / Other: $otherNotes');
      print('   User Goals: $userGoals / Other: $otherGoals');
    }
    
    return stats;
  }
}
