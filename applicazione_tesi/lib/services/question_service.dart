import 'dart:convert';
import 'package:http/http.dart' as http;

class QuestionService {
  final String baseUrl = 'http://localhost:3000/api/questions';

  Future<void> insertQuestion(int sessionId, int userId, String question) async {
    print('QuestionService: Inserting question - SessionID: $sessionId, UserID: $userId, Question: $question');
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'sessionId': sessionId,
        'userId': userId,
        'question': question,
      }),
    );

    print('QuestionService: Response status code: ${response.statusCode}');
    print('QuestionService: Response body: ${response.body}');

    if (response.statusCode != 201) {
      print('Failed to insert question. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to insert question');
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsForSession(int sessionId) async {
    final response = await http.get(Uri.parse('$baseUrl/session/$sessionId'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to retrieve questions');
    }
  }
}

class Question {
  final int? id;
  final int? sessionId;
  final int? userId;
  final String question;
  final String timeStamp;
  final String? userName;
  final String? userSurname;

  Question({
    this.id,
    this.sessionId,
    this.userId,
    required this.question,
    required this.timeStamp,
    this.userName,
    this.userSurname,
  });

  factory Question.fromjson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      question: json['question'],
      timeStamp: json['timestamp'],
      userName: json['user_name'],
      userSurname: json['user_surname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'question': question,
      'timestamp': timeStamp,
      'user_name': userName,
      'user_surname': userSurname,
    };
  }
}