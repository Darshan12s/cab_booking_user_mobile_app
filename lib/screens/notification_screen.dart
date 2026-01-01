// screens/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/app_drawer.dart';
import 'app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _starredMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final starredResponse = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_starred', true)
          .order('created_at', ascending: false);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(response);
        _starredMessages = List<Map<String, dynamic>>.from(starredResponse);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching notifications: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStar(String notificationId, bool currentStatus) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_starred': !currentStatus})
          .eq('id', notificationId)
          .eq('user_id', userId);

      await _fetchNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating notification: $e')),
        );
      }
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);

      await _fetchNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting notification: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', userId);

      await _fetchNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking notification: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppTheme.isDarkMode(context)
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: AppTheme.getBackgroundColor(context),
        systemNavigationBarIconBrightness: AppTheme.isDarkMode(context)
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          foregroundColor: AppTheme.getTextColor(context),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(color: AppTheme.getTextColor(context)),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF34A853),
            labelColor: const Color(0xFF34A853),
            unselectedLabelColor: AppTheme.getTextColor(
              context,
            ).withOpacity(0.6),
            tabs: const [
              Tab(text: 'Messages'),
              Tab(text: 'Starred'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [_buildMessagesTab(), _buildStarredMessagesTab()],
              ),
      ), // End of Scaffold
    ); // End of AnnotatedRegion
  }

  Widget _buildMessagesTab() {
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: _messages.isEmpty
          ? Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _NotificationItem(
                  id: message['id'],
                  icon: _getIconData(message['icon']),
                  heading: message['heading'],
                  content: message['content'],
                  time: _formatTime(message['created_at']),
                  isStarred: message['is_starred'] ?? false,
                  isRead: message['is_read'] ?? false,
                  onStarPressed: () => _toggleStar(
                    message['id'],
                    message['is_starred'] ?? false,
                  ),
                  onDeletePressed: () => _deleteNotification(message['id']),
                  onTap: () => _markAsRead(message['id']),
                );
              },
            ),
    );
  }

  Widget _buildStarredMessagesTab() {
    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: _starredMessages.isEmpty
          ? Center(
              child: Text(
                'No starred notifications',
                style: TextStyle(
                  color: AppTheme.getSecondaryTextColor(context),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _starredMessages.length,
              itemBuilder: (context, index) {
                final message = _starredMessages[index];
                return _NotificationItem(
                  id: message['id'],
                  icon: _getIconData(message['icon']),
                  heading: message['heading'],
                  content: message['content'],
                  time: _formatTime(message['created_at']),
                  isStarred: true,
                  isRead: message['is_read'] ?? false,
                  onStarPressed: () => _toggleStar(
                    message['id'],
                    message['is_starred'] ?? false,
                  ),
                  onDeletePressed: () => _deleteNotification(message['id']),
                  onTap: () => _markAsRead(message['id']),
                );
              },
            ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'email':
        return Icons.email;
      case 'calendar':
        return Icons.calendar_today;
      case 'update':
        return Icons.system_update;
      case 'announcement':
        return Icons.announcement;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _NotificationItem extends StatelessWidget {
  final String id;
  final IconData icon;
  final String heading;
  final String content;
  final String time;
  final bool isStarred;
  final bool isRead;
  final VoidCallback onStarPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.id,
    required this.icon,
    required this.heading,
    required this.content,
    required this.time,
    required this.isStarred,
    required this.isRead,
    required this.onStarPressed,
    required this.onDeletePressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isRead
          ? AppTheme.getCardColor(context)
          : (AppTheme.isDarkMode(context)
                ? const Color(0xFF1E3A8A).withOpacity(0.2)
                : Colors.blue[50]),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF34A853),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.getSecondaryTextColor(
                          context,
                        ).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isStarred ? Icons.star : Icons.star_outline,
                      color: isStarred
                          ? Colors.amber
                          : AppTheme.getSecondaryTextColor(context),
                      size: 20,
                    ),
                    onPressed: onStarPressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppTheme.getSecondaryTextColor(context),
                    onPressed: () => _showDeleteDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardColor(context),
        title: Text(
          'Delete Notification',
          style: TextStyle(color: AppTheme.getTextColor(context)),
        ),
        content: Text(
          'Are you sure you want to delete this notification?',
          style: TextStyle(color: AppTheme.getTextColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.getSecondaryTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDeletePressed();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
