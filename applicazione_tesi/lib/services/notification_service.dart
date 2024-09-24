import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = 'http://localhost:3000/api/notifications';

  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch notifications');
    }
  }

  Future<void> createNotification(Notifications notification) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(notification.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create notification');
    }
  }

  Future<void> deleteNotification(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}

class Notifications {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String date;
  final String type;
  final int? postId;
  final int? requesterId;
  final String? status;

  Notifications({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.postId,
    this.requesterId,
    this.status,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      message: json['message'],
      date: json['date'],
      type: json['type'],
      postId: json['postId'],
      requesterId: json['requesterId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'date': date,
      'type': type,
      'postId': postId,
      'requesterId': requesterId,
      'status': status,
    };
  }
}