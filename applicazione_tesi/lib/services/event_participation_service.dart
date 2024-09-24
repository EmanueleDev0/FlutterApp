import 'dart:convert';
import 'package:http/http.dart' as http;

class EventParticipationService {
  final String baseUrl = 'http://localhost:3000/api/event-participations';

  Future<bool> isUserParticipating(int userId, int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/$postId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['participating'];
    } else {
      throw Exception('Failed to check participation');
    }
  }

  Future<void> addParticipation(int userId, int postId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'postId': postId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add participation');
    }
  }

  Future<void> removeParticipation(int userId, int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/user/$userId/post/$postId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove participation');
    }
  }

  Future<void> requestParticipation(int userId, int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/request'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId, 'postId': postId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to request participation');
    }
  }

  Future<void> updateParticipationStatus(int userId, int postId, String status) async {
    print('EventParticipationService: Invio richiesta di aggiornamento - UserID: $userId, PostID: $postId, Status: $status');
    final response = await http.put(
      Uri.parse('$baseUrl/$userId/$postId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    print('EventParticipationService: Risposta ricevuta - Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('EventParticipationService: Stato di partecipazione aggiornato con successo');
    } else {
      print('EventParticipationService: Errore nell\'aggiornamento dello stato - Body: ${response.body}');
      throw Exception('Failed to update participation status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getParticipationStatus(int userId, int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/$userId/$postId/status'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get participation status');
    }
  }

  Future<void> addSpeakerParticipation(String email, int postId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/speaker'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'postId': postId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to handle speaker participation');
    }
  }

  Future<void> acceptParticipation(int requesterId, int postId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/accept/$requesterId/post/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept participation');
    }
  }
}
