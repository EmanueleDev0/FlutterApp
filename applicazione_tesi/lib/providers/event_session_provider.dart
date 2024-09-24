import 'package:flutter/foundation.dart';
import '../services/event_session_service.dart';

class EventSessionProvider extends ChangeNotifier {
  final EventSessionService _sessionService;

  EventSessionProvider(this._sessionService);

  Future<int> createEventSession(EventSession session) async {
    try {
      print('DEBUG PostsProvider: Iniziando la creazione della sessione evento');
      print('DEBUG PostsProvider: Dati della sessione: ${session.toJson()}');
      final sessionId = await _sessionService.createEventSession(
        session.postId,
        session.title,
        session.description,
        session.sessionDate,
        session.startTime,
        session.endTime,
        session.location,
      );
      print('DEBUG PostsProvider: Sessione creata con ID: $sessionId');
      notifyListeners();
      return sessionId;
    } catch (e) {
      print('DEBUG PostsProvider: Errore durante la creazione della sessione evento: $e');
      if (e is Exception) {
        print('DEBUG PostsProvider: Stack trace: ${e.toString()}');
      }
      rethrow;
    }
  }

  Future<List<EventSession>> getEventSessionsForPost(int postId) async {
    try {
      final sessions = await _sessionService.getEventSessions(postId);
      return sessions.map((sessionJson) => EventSession.fromJson(sessionJson)).toList();
    } catch (e) {
      print('Error retrieving event sessions: $e');
      return [];
    }
  }

  Future<List<EventSession>> getUserConferences(String userId) async {
    try {
      final conferences = await _sessionService.getUserConferences(userId);
      return conferences;
    } catch (e) {
      print('Error fetching user conferences: $e');
      return [];
    }
  }

  Future<void> updateEventSession(EventSession session) async {
    try {
      await _sessionService.updateEventSession(
        session.id!,
        session.title,
        session.description,
        session.sessionDate,
        session.startTime,
        session.endTime,
        session.location,
      );
      notifyListeners();
    } catch (e) {
      print('Error updating event session: $e');
      rethrow;
    }
  }
}