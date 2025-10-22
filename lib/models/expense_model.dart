import 'package:hive/hive.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final double amount;
  @HiveField(5)
  final DateTime date;
  @HiveField(6)
  final String vendor;

  Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    required this.vendor,
  });

  // Helper method for display
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Helper method for time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}