import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentService {
  final String baseUrl = 'http://localhost:3000/api/comments'; // Usa 10.0.2.2 per l'emulatore Android

  Future<Comment> createComment(Comment comment) async {
    try {
      print('Sending POST request to $baseUrl');
      print('Comment data: ${comment.toJson()}');  // Add this line to log the comment data
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(comment.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return Comment.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create comment: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('Error in createComment: $e');
      rethrow;
    }
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/post/$postId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments: ${response.statusCode}, ${response.body}');
    }
  }
}

class Comment {
  final int? id;
  final int postId;
  final int userId;
  final String userName;
  final String content;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.content,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'user_name': userName,
      'content': content,
    };
  }
}