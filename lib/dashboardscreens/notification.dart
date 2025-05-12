import 'package:csc/model/notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//void main() => runApp(MaterialApp(home: NotificationScreen()));

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
List<NotificationItem> notifications = [
NotificationItem(
      type: 'new_arrival',
      title: 'New Diamond Collection!',
      description: '24K Gold with VS1 Diamonds now available',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      // imagePath: 'assets/images/gold1.jpg',
    ),
    NotificationItem(
      type: 'price_alert',
      title: 'Gold Rate Increased',
      description: '22K gold price increased by 1.5% today',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: true,
    ),
    NotificationItem(
      type: 'order_update',
      title: 'Order Shipped',
      description: 'Your custom necklace has been dispatched',
      time: DateTime.now().subtract(const Duration(days: 1)),
      status: 'In Transit',
    ),
    NotificationItem(
      type: 'offer',
      title: 'Festival Special!',
      description: 'Get 20% off on antique jewellery designs',
      time: DateTime.now().subtract(const Duration(days: 2)),
      expiry: DateTime.now().add(const Duration(days: 3)),
    ),
    NotificationItem(
      type: 'appointment',
      title: 'Design Consultation',
      description: 'Your appointment confirmed for tomorrow 3 PM',
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    NotificationItem(
      type: 'wishlist',
      title: 'Back in Stock',
      description: '22K Mangalsutra design #452 is now available',
      time: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NotificationItem(
      type: 'event',
      title: 'Jewellery Exhibition',
      description: 'Annual gold exhibition starts this weekend',
      time: DateTime.now().subtract(const Duration(days: 4)),
    ),
    NotificationItem(
      type: 'security',
      title: 'Security Alert',
      description: 'New device logged into your account',
      time: DateTime.now().subtract(const Duration(days: 5)),
    ),
    NotificationItem(
      type: 'membership',
      title: 'Elite Member Benefits',
      description: 'Exclusive preview of new collections',
      time: DateTime.now().subtract(const Duration(days: 6)),
    ),
    NotificationItem(
    type: 'anniversary',
    title: 'Celebrate with Gold!',
    description: 'Special discounts for account anniversary',
    time: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Notifications (${notifications.where((n) => !n.isRead).length})',style: const TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromRGBO(2, 5, 67, 1),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Dismissible(
            key: Key(notification.hashCode.toString()),
            background: Container(color: Colors.red),
            onDismissed: (direction) => setState(() => notifications.removeAt(index)),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: notification.isRead ? Colors.white : Colors.amber[50],
      child: ListTile(
        leading: _buildLeadingIcon(notification),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.title, 
                 style: TextStyle(
                   fontWeight: FontWeight.bold,
                   color: Colors.amber[900],
                 )),
            if (notification.status != null)
              Chip(
                label: Text(notification.status!,
                    style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.amber[100],
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(notification.description),


            const SizedBox(height: 4),



            Row(
              children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),


                const SizedBox(width: 4),


                Text(_formatTime(notification.time),
                    style: const TextStyle(fontSize: 12)),
                if (notification.expiry != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, size: 14, color: Colors.red),
                        Text(
                          'Expires in ${notification.expiry!.difference(DateTime.now()).inDays}d',
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
          trailing: notification.imagePath != null 
          ? Image.network(notification.imagePath!, width: 60)
          : null,
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildLeadingIcon(NotificationItem notification) {
    final iconMap = {

      'new_arrival': Icons.new_releases,
      'price_alert': Icons.attach_money,
      'order_update': Icons.local_shipping,
      'offer': Icons.discount,
      'appointment': Icons.calendar_today,
      'wishlist': Icons.favorite,
      'event': Icons.event,
      'security': Icons.security,
      'membership': Icons.stars,
      'anniversary': Icons.cake,
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
      color: Colors.amber[100],
      shape: BoxShape.circle,
      ),
      child: Icon(
      iconMap[notification.type],
      color: const Color.fromRGBO(2, 5, 67, 1),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return DateFormat('MMM dd').format(time);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inMinutes}m ago';
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() => notification.isRead = true);
    
    switch (notification.type) {

      case 'order_update':
       
        break;
      case 'new_arrival':
        // Navigate to product page
        break;
      // Handle other types
    }
  }
}

