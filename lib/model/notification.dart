class NotificationItem {
  final String type;
  final String title;
  final String description;
  final DateTime time;
  bool isRead;
  final String?  imagePath;
  final String? status;
  final DateTime? expiry;

  NotificationItem({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    this. imagePath,
    this.status,
    this.expiry,
  });
}