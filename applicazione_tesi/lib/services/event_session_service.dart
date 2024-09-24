import 'dart:convert';
import 'package:http/http.dart' as http;

class EventSessionService {
  final String baseUrl = 'http://localhost:3000/api/event-sessions';

  Future<int> createEventSession(
    int postId, String title, String description, String sessionDate, String startTime, String endTime, String location) async {
    print('DEBUG EventSessionService: Iniziando la creazione della sessione evento');
    print('DEBUG EventSessionService: Dati della richiesta: postId=$postId, title=$title, description=$description, sessionDate=$sessionDate, startTime=$startTime, endTime=$endTime, location=$location');
    
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'postId': postId,
        'title': title,
        'description': description,
        'sessionDate': sessionDate,
        'startTime': startTime,
        'endTime': endTime,
        'location': location
      }),
    );

    print('DEBUG EventSessionService: Risposta ricevuta. Status code: ${response.statusCode}');
    print('DEBUG EventSessionService: Corpo della risposta: ${response.body}');

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      print('DEBUG EventSessionService: Sessione creata con successo. ID: ${jsonResponse['id']}');
      return jsonResponse['id'];
    } else {
      print('DEBUG EventSessionService: Errore nella creazione della sessione');
      throw Exception('Failed to create event session');
    }
  }

  Future<List<Map<String, dynamic>>> getEventSessions(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/post/$postId'));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to retrieve event sessions');
    }
  }

  Future<void> updateEventSession(int id, String title, String description, String sessionDate, String startTime, String endTime, String location) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'title': title,
        'description': description,
        'sessionDate': sessionDate,
        'startTime': startTime,
        'endTime': endTime,
        'location': location
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update event session');
    }
  }

  Future<List<EventSession>> getUserConferences(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => EventSession.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load user conferences');
    }
  }
}

class EventSession {
  final int? id;
  int postId;
  final String title;
  final String description;
  final String sessionDate;
  final String startTime;
  final String endTime;
  final String location;

  EventSession({
    this.id,
    required this.postId,
    required this.title,
    required this.description,
    required this.sessionDate,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'title': title,
      'description': description,
      'session_date': sessionDate,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
    };
  }

  factory EventSession.fromJson(Map<String, dynamic> json) {
    return EventSession(
      id: json['id'],
      postId: json['post_id'],
      title: json['title'],
      description: json['description'],
      sessionDate: json['session_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
    );
  }
}