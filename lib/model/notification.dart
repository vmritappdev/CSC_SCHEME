class NotificationItem {
  final String title;
  final String description;
  final String date;
  final String time;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      title: json['head'] ?? 'No Title',
      description: json['matter'] ?? '',
      date: json['date'] ?? 'N/A',
      time: json['time'] ?? 'N/A',
    );
  }
}
