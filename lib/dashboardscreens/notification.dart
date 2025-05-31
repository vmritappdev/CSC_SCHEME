import 'dart:convert';
import 'package:csc/model/notification.dart';
import 'package:csc/utillity/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;  // డేటా లోడ్ అవుతున్నప్పుడు చూపించడానికి

  @override
  void initState() {
    super.initState();
    fetchAndCallNotifications();
    
  }



  

  Future<void> fetchAndCallNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? mobileNumber = prefs.getString('phoneNumber');

    if (mobileNumber != null && mobileNumber.isNotEmpty) {
      final url = Uri.parse("$baseUrl/notifications.php");

      try {
        final response = await http.post(url, body: {
          'mobile_no': mobileNumber,
          'option': 'yes',
        });

         print("🌐 API Status Code: ${response.statusCode}");
        print("🔄 Raw Response Body: ${response.body}");
        

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print("✅ Decoded JSON Response: $data");

          if (data['response'] == 'success' && data['data'] != null) {
            final List<dynamic> notifJsonList = data['data'];

            setState(() {
              notifications = notifJsonList
                  .map((json) => NotificationItem.fromJson(json))
                  .toList();
              isLoading = false;
            });
          } else {
            // No notifications found or response failed
            setState(() {
              notifications = [];
              isLoading = false;
            });
          }
        } else {
          setState(() {
            notifications = [];
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          notifications = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        notifications = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Notifications (${notifications.where((n) => !n.isRead).length})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromRGBO(2, 5, 67, 1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No new notifications",
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
              : ListView.builder(
                   physics: const BouncingScrollPhysics(), // లేదా ScrollPhysics()
                 shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
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
        title: Text(
          notification.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amber[900],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.description,style: TextStyle(fontSize: 13),),
            const SizedBox(height: 4),
            Text(
              '📅 ${_formatDate(notification.date)} 🕒 ${notification.time}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Widget _buildLeadingIcon(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        shape: BoxShape.circle,
      ),
      child: Icon(
        
        _getIconForNotification(notification),
        color: const Color.fromRGBO(2, 5, 67, 1),
        size: 15,
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    setState(() => notification.isRead = true);
  }

  static String _formatDate(String input) {
    try {
      if (input == '0000-00-00' || input.isEmpty) return 'N/A';
      final parsedDate = DateTime.parse(input);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (e) {
      return input;
    }
  }

  IconData _getIconForNotification(NotificationItem notification) {
  final title = notification.title.toLowerCase();

  if (title.contains('payment') || title.contains('paid')) {
    return Icons.payment;
  } else if (title.contains('offer') || title.contains('discount')) {
    return Icons.local_offer;
  } else if (title.contains('alert') || title.contains('important')) {
    return Icons.warning;
  } else if (title.contains('scheme') || title.contains('plan')) {
    return Icons.star;
  } else if (title.contains('installment')) {
    return Icons.calendar_month;
  } else if (title.contains('profile') || title.contains('account')) {
    return Icons.person;
  } else if (title.contains('reminder')) {
    return Icons.notifications_active;
  } else if (title.contains('birthday')) {
    return Icons.cake;
  } else if (title.contains('festival')) {
    return Icons.celebration;
  } else if (title.contains('feedback') || title.contains('review')) {
    return Icons.feedback;
  } else if (title.contains('thumbs up') || title.contains('like')) {
    return Icons.thumb_up;
  } else if (title.contains('love') || title.contains('heart')) {
    return Icons.favorite;
  } else {
    return Icons.notifications; // fallback
  }
}



  DateTime _combineDateAndTime(String date, String time) {
  try {
    // date string -> DateTime
    DateTime parsedDate = DateTime.parse(date);

    // time string assumed as "HH:mm" లేదా "H:mm" format లో ఉంటుందని assume చేస్తున్నాం
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    // Combine date + time
    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
  } catch (e) {
    return DateTime.now(); // fallback
  }
}


String formatNotificationDateWithIST(DateTime dateTime) {
  final now = DateTime.now();

  // IST offset +5:30
  final istDateTime = dateTime.add(Duration(hours: 5, minutes: 30));

  final difference = now.difference(istDateTime).inDays;

  final timeFormat = DateFormat.jm(); // 12-hour format with AM/PM
  final formattedTime = timeFormat.format(istDateTime);

  if (difference == 0) {
    return "Today at $formattedTime";
  } else if (difference > 0 && difference <= 7) {
    return "$difference days ago at $formattedTime";
  } else {
    final dateFormat = DateFormat('dd MMM yyyy');
    final formattedDate = dateFormat.format(istDateTime);
    return "📅 $formattedDate at $formattedTime";
  }
}


}
