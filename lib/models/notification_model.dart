import 'dart:ui';
import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 7) // CHANGED from 6 to 7
class NotificationModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String message;

  @HiveField(3)
  final NotificationType type;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.metadata,
  });

  // Convert to map for easier serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  // Create from map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: NotificationType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => NotificationType.system,
      ),
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
      metadata: map['metadata'],
    );
  }
}

@HiveType(typeId: 8) // CHANGED from 7 to 8
enum NotificationType {
  @HiveField(0)
  budget,

  @HiveField(1)
  reminder,

  @HiveField(2)
  insight,

  @HiveField(3)
  achievement,

  @HiveField(4)
  system
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.budget:
        return 'Budget';
      case NotificationType.reminder:
        return 'Reminders';
      case NotificationType.insight:
        return 'Insights';
      case NotificationType.achievement:
        return 'Achievements';
      case NotificationType.system:
        return 'System';
    }
  }

  String get iconAsset {
    switch (this) {
      case NotificationType.budget:
        return '💰';
      case NotificationType.reminder:
        return '⏰';
      case NotificationType.insight:
        return '📊';
      case NotificationType.achievement:
        return '🏆';
      case NotificationType.system:
        return '🔔';
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.budget:
        return const Color(0xFF4ECDC4); // Teal
      case NotificationType.reminder:
        return const Color(0xFFFFD166); // Yellow
      case NotificationType.insight:
        return const Color(0xFF9D4EDD); // Purple
      case NotificationType.achievement:
        return const Color(0xFF06D6A0); // Green
      case NotificationType.system:
        return const Color(0xFF118AB2); // Blue
    }
  }
}