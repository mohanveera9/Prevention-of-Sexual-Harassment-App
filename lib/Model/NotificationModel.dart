class NotificationModel {
  final String id;
  final String title;
  final String description;
  final List<String> links;
  final Sender sender;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.links,
    required this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      links: List<String>.from(json['links']),
      sender: Sender.fromJson(json['sender']),
    );
  }
}

class Sender {
  final String id;
  final String username;
  final String role;

  Sender({
    required this.id,
    required this.username,
    required this.role,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['_id'],
      username: json['username'],
      role: json['role'],
    );
  }
}
