// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// //
// // class NotificationsScreen extends StatelessWidget {
// //   const NotificationsScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppTheme.offWhite,
// //       appBar: AppBar(
// //         title: const Text('Notifications'),
// //       ),
// //       body: Center(
// //         child: Text(
// //           'No new notifications.',
// //           style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:smart_expense_tracker/app/theme/app_theme.dart';
// import 'package:intl/intl.dart';
//
// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});
//
//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }
//
// class _NotificationsScreenState extends State<NotificationsScreen> {
//   final List<AppNotification> _notifications = [
//     AppNotification(
//       id: '1',
//       title: 'Budget Alert',
//       message: 'You\'ve spent 80% of your monthly budget',
//       type: NotificationType.budget,
//       timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
//       isRead: false,
//     ),
//     AppNotification(
//       id: '2',
//       title: 'Bill Reminder',
//       message: 'Electricity bill due in 3 days',
//       type: NotificationType.reminder,
//       timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//       isRead: false,
//     ),
//     AppNotification(
//       id: '3',
//       title: 'Spending Trend',
//       message: 'Your food expenses are 25% higher than last month',
//       type: NotificationType.insight,
//       timestamp: DateTime.now().subtract(const Duration(hours: 5)),
//       isRead: true,
//     ),
//     AppNotification(
//       id: '4',
//       title: 'Savings Goal',
//       message: 'You\'re 75% towards your vacation savings goal!',
//       type: NotificationType.achievement,
//       timestamp: DateTime.now().subtract(const Duration(days: 1)),
//       isRead: true,
//     ),
//     AppNotification(
//       id: '5',
//       title: 'Subscription Renewal',
//       message: 'Netflix subscription will renew tomorrow',
//       type: NotificationType.reminder,
//       timestamp: DateTime.now().subtract(const Duration(days: 2)),
//       isRead: true,
//     ),
//     AppNotification(
//       id: '6',
//       title: 'Budget Exceeded',
//       message: 'You\'ve exceeded your shopping budget this month',
//       type: NotificationType.budget,
//       timestamp: DateTime.now().subtract(const Duration(days: 3)),
//       isRead: true,
//     ),
//   ];
//
//   NotificationFilter _currentFilter = NotificationFilter.all;
//   bool _showUnreadOnly = false;
//
//   List<AppNotification> get _filteredNotifications {
//     List<AppNotification> filtered = _notifications;
//
//     if (_showUnreadOnly) {
//       filtered = filtered.where((notification) => !notification.isRead).toList();
//     }
//
//     if (_currentFilter != NotificationFilter.all) {
//       filtered = filtered.where((notification) => notification.type == _currentFilter.toType()).toList();
//     }
//
//     return filtered;
//   }
//
//   int get _unreadCount {
//     return _notifications.where((notification) => !notification.isRead).length;
//   }
//
//   void _markAllAsRead() {
//     setState(() {
//       for (var notification in _notifications) {
//         notification.isRead = true;
//       }
//     });
//   }
//
//   void _toggleReadStatus(String id) {
//     setState(() {
//       final notification = _notifications.firstWhere((n) => n.id == id);
//       notification.isRead = !notification.isRead;
//     });
//   }
//
//   void _deleteNotification(String id) {
//     setState(() {
//       _notifications.removeWhere((n) => n.id == id);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.offWhite,
//       appBar: AppBar(
//         title: const Text('Notifications'),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkGrey),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (_unreadCount > 0)
//             IconButton(
//               icon: Badge(
//                 label: Text(_unreadCount.toString()),
//                 child: const Icon(Icons.mark_email_read, color: AppTheme.darkGrey),
//               ),
//               onPressed: _markAllAsRead,
//               tooltip: 'Mark all as read',
//             ),
//           const SizedBox(width: 8),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filter Section
//           _buildFilterSection(),
//
//           // Notifications List
//           Expanded(
//             child: _filteredNotifications.isEmpty
//                 ? _buildEmptyState()
//                 : _buildNotificationsList(),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilterSection() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // Toggle Switch for Unread Only
//           Row(
//             children: [
//               Text(
//                 'Unread only',
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: AppTheme.darkGrey,
//                 ),
//               ),
//               const Spacer(),
//               Switch(
//                 value: _showUnreadOnly,
//                 onChanged: (value) {
//                   setState(() {
//                     _showUnreadOnly = value;
//                   });
//                 },
//                 activeColor: AppTheme.primaryTeal,
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//
//           // Filter Chips
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: NotificationFilter.values.map((filter) {
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(
//                       filter.displayName,
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         fontWeight: _currentFilter == filter
//                             ? FontWeight.w600
//                             : FontWeight.w400,
//                       ),
//                     ),
//                     selected: _currentFilter == filter,
//                     onSelected: (selected) {
//                       setState(() {
//                         _currentFilter = selected ? filter : NotificationFilter.all;
//                       });
//                     },
//                     backgroundColor: Colors.grey[100],
//                     selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
//                     checkmarkColor: AppTheme.primaryTeal,
//                     labelStyle: TextStyle(
//                       color: _currentFilter == filter
//                           ? AppTheme.primaryTeal
//                           : AppTheme.darkGrey,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationsList() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _filteredNotifications.length,
//       itemBuilder: (context, index) {
//         final notification = _filteredNotifications[index];
//         return _buildNotificationCard(notification);
//       },
//     );
//   }
//
//   Widget _buildNotificationCard(AppNotification notification) {
//     return Dismissible(
//       key: Key(notification.id),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         color: Colors.red,
//         alignment: Alignment.centerRight,
//         padding: const EdgeInsets.only(right: 20),
//         child: const Icon(Icons.delete, color: Colors.white, size: 24),
//       ),
//       onDismissed: (direction) => _deleteNotification(notification.id),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ListTile(
//           contentPadding: const EdgeInsets.all(16),
//           leading: _buildNotificationIcon(notification.type),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   notification.title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 16,
//                     fontWeight: notification.isRead
//                         ? FontWeight.w500
//                         : FontWeight.w600,
//                     color: AppTheme.darkGrey,
//                   ),
//                 ),
//               ),
//               if (!notification.isRead)
//                 Container(
//                   width: 8,
//                   height: 8,
//                   decoration: const BoxDecoration(
//                     color: AppTheme.accentOrange,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//             ],
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 4),
//               Text(
//                 notification.message,
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: AppTheme.darkGrey.withOpacity(0.7),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _formatTimestamp(notification.timestamp),
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: AppTheme.darkGrey.withOpacity(0.5),
//                 ),
//               ),
//             ],
//           ),
//           onTap: () => _toggleReadStatus(notification.id),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNotificationIcon(NotificationType type) {
//     final iconData = switch (type) {
//       NotificationType.budget => Icons.account_balance_wallet,
//       NotificationType.reminder => Icons.notifications,
//       NotificationType.insight => Icons.insights,
//       NotificationType.achievement => Icons.emoji_events,
//     };
//
//     final color = switch (type) {
//       NotificationType.budget => AppTheme.primaryTeal,
//       NotificationType.reminder => Colors.orange,
//       NotificationType.insight => Colors.purple,
//       NotificationType.achievement => Colors.green,
//     };
//
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(iconData, color: color, size: 20),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_off_outlined,
//             size: 80,
//             color: Colors.grey[300],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No notifications',
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: AppTheme.darkGrey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _showUnreadOnly
//                 ? 'You\'re all caught up!'
//                 : 'Notifications will appear here',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: AppTheme.darkGrey.withOpacity(0.6),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTimestamp(DateTime timestamp) {
//     final now = DateTime.now();
//     final difference = now.difference(timestamp);
//
//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inHours < 1) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inDays < 1) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return DateFormat('MMM d, yyyy').format(timestamp);
//     }
//   }
// }
//
// class AppNotification {
//   final String id;
//   final String title;
//   final String message;
//   final NotificationType type;
//   final DateTime timestamp;
//   bool isRead;
//
//   AppNotification({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.type,
//     required this.timestamp,
//     required this.isRead,
//   });
// }
//
// enum NotificationType {
//   budget,
//   reminder,
//   insight,
//   achievement,
// }
//
// enum NotificationFilter {
//   all('All'),
//   budget('Budget'),
//   reminder('Reminders'),
//   insight('Insights'),
//   achievement('Achievements');
//
//   const NotificationFilter(this.displayName);
//   final String displayName;
//
//   NotificationType? toType() {
//     return switch (this) {
//       NotificationFilter.budget => NotificationType.budget,
//       NotificationFilter.reminder => NotificationType.reminder,
//       NotificationFilter.insight => NotificationType.insight,
//       NotificationFilter.achievement => NotificationType.achievement,
//       NotificationFilter.all => null,
//     };
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:smart_expense_tracker/app/theme/app_theme.dart';
import 'package:smart_expense_tracker/common_widgets/themed_background.dart';
import 'package:smart_expense_tracker/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _currentFilter = NotificationFilter.all;
  bool _showUnreadOnly = false;

  List<NotificationModel> get _notifications {
    if (!Hive.isBoxOpen('notifications')) return [];
    final box = Hive.box<NotificationModel>('notifications');
    return box.values.toList().cast<NotificationModel>();
  }

  List<NotificationModel> get _filteredNotifications {
    List<NotificationModel> filtered = _notifications;

    // Sort by timestamp (newest first)
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (_showUnreadOnly) {
      filtered = filtered.where((notification) => !notification.isRead).toList();
    }

    if (_currentFilter != NotificationFilter.all) {
      filtered = filtered.where((notification) =>
      notification.type == _currentFilter.toType()).toList();
    }

    return filtered;
  }

  int get _unreadCount {
    return _notifications.where((notification) => !notification.isRead).length;
  }

  void _markAllAsRead() {
    final box = Hive.box<NotificationModel>('notifications');
    for (var notification in _notifications) {
      if (!notification.isRead) {
        final updatedNotification = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          type: notification.type,
          timestamp: notification.timestamp,
          isRead: true,
          metadata: notification.metadata,
        );
        box.put(notification.id, updatedNotification);
      }
    }
    setState(() {});
  }

  void _toggleReadStatus(String id) {
    final box = Hive.box<NotificationModel>('notifications');
    final notification = box.get(id);
    if (notification != null) {
      final updatedNotification = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        type: notification.type,
        timestamp: notification.timestamp,
        isRead: !notification.isRead,
        metadata: notification.metadata,
      );
      box.put(id, updatedNotification);
      setState(() {});
    }
  }

  void _deleteNotification(String id) {
    final box = Hive.box<NotificationModel>('notifications');
    box.delete(id);
    setState(() {});
  }

  void _clearAllNotifications() {
    final box = Hive.box<NotificationModel>('notifications');
    box.clear();
    setState(() {});
  }

  // Method to add sample notifications (for testing)
  void _addSampleNotifications() {
    final box = Hive.box<NotificationModel>('notifications');

    final samples = [
      NotificationModel(
        id: '1',
        title: 'Budget Alert 🚨',
        message: 'You\'ve spent 80% of your monthly budget. Consider reviewing your expenses.',
        type: NotificationType.budget,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        metadata: {'budgetCategory': 'Monthly', 'percentage': 80},
      ),
      NotificationModel(
        id: '2',
        title: 'Bill Reminder',
        message: 'Electricity bill of \$125 is due in 3 days.',
        type: NotificationType.reminder,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {'amount': 125.0, 'dueInDays': 3},
      ),
      NotificationModel(
        id: '3',
        title: 'Spending Insight 📈',
        message: 'Your food expenses are 25% higher than last month. Great job on dining out less!',
        type: NotificationType.insight,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        metadata: {'category': 'Food', 'change': 25},
      ),
      NotificationModel(
        id: '4',
        title: 'Savings Goal Achieved! 🎉',
        message: 'Congratulations! You\'ve reached 75% of your vacation savings goal.',
        type: NotificationType.achievement,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        metadata: {'goal': 'Vacation', 'progress': 75},
      ),
    ];

    for (var notification in samples) {
      box.put(notification.id, notification);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ThemedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.getTextColor(context), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        actions: [
          if (_notifications.isNotEmpty) ...[
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.check, color: AppTheme.getTextColor(context)),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: AppTheme.getTextColor(context)),
              onSelected: (value) {
                if (value == 'clear_all') {
                  _clearAllNotifications();
                } else if (value == 'add_samples') {
                  _addSampleNotifications();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Text('Clear All Notifications'),
                ),
                const PopupMenuItem(
                  value: 'add_samples',
                  child: Text('Add Sample Notifications'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Enhanced Filter Section
          _buildEnhancedFilterSection(),

          // Notifications Count
          if (_filteredNotifications.isNotEmpty)
            _buildNotificationsCount(),

          // Notifications List
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEnhancedFilterSection() {
    return Container(
      color: AppTheme.getCardColor(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filters',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
              const Spacer(),
              // Unread Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _showUnreadOnly
                      ? AppTheme.getPrimaryColor(context).withOpacity(0.1)
                      : AppTheme.getSecondaryTextColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: _showUnreadOnly ? AppTheme.getPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Unread Only',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _showUnreadOnly ? AppTheme.getPrimaryColor(context) : AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: _showUnreadOnly,
                      onChanged: (value) {
                        setState(() {
                          _showUnreadOnly = value;
                        });
                      },
                      activeColor: AppTheme.getPrimaryColor(context),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Chips - Improved Design
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: NotificationFilter.values.map((filter) {
              final isSelected = _currentFilter == filter;
              return FilterChip(
                label: Text(
                  filter.displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _currentFilter = selected ? filter : NotificationFilter.all;
                  });
                },
                backgroundColor: AppTheme.getSurfaceColor(context),
                selectedColor: filter.getColor().withOpacity(0.15),
                checkmarkColor: filter.getColor(),
                labelStyle: TextStyle(
                  color: isSelected ? filter.getColor() : AppTheme.getTextColor(context),
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected ? filter.getColor() : AppTheme.getSecondaryTextColor(context),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                avatar: isSelected ? Icon(
                  Icons.check,
                  size: 16,
                  color: filter.getColor(),
                ) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.transparent,
      child: Row(
        children: [
          Text(
            '${_filteredNotifications.length} notification${_filteredNotifications.length == 1 ? '' : 's'}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.getSecondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.getOriginalAccentColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_unreadCount unread',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.getOriginalAccentColor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification = _filteredNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleReadStatus(notification.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: notification.type.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      notification.type.iconAsset,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                    color: AppTheme.getTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.getSecondaryTextColor(context),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notification.type.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: notification.type.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              notification.type.displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: notification.type.color,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatTimestamp(notification.timestamp),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 80,
              color: AppTheme.getSecondaryTextColor(context),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications yet',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showUnreadOnly
                  ? 'You\'re all caught up with unread notifications!'
                  : 'When you get notifications, they\'ll appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppTheme.getSecondaryTextColor(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (_notifications.isEmpty)
              ElevatedButton(
                onPressed: _addSampleNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.getPrimaryColor(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Sample Notifications',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }
}

enum NotificationFilter {
  all('All', Color(0xFF6B7280)),
  budget('Budget', Color(0xFF4ECDC4)),
  reminder('Reminders', Color(0xFFFFD166)),
  insight('Insights', Color(0xFF9D4EDD)),
  achievement('Achievements', Color(0xFF06D6A0));

  const NotificationFilter(this.displayName, this.color);
  final String displayName;
  final Color color;

  Color getColor() => color;

  NotificationType? toType() {
    return switch (this) {
      NotificationFilter.budget => NotificationType.budget,
      NotificationFilter.reminder => NotificationType.reminder,
      NotificationFilter.insight => NotificationType.insight,
      NotificationFilter.achievement => NotificationType.achievement,
      NotificationFilter.all => null,
    };
  }
}