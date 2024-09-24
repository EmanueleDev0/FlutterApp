import 'package:flutter/foundation.dart';
import '../services/post_service.dart';
import '../services/event_participation_service.dart';
import '../services/question_service.dart'; 

class PostsProvider extends ChangeNotifier {
  final PostService _postService;
  final EventParticipationService _participationService;
  final QuestionService _questionService;
  List<Post> _posts = [];

  PostsProvider(this._postService, this._participationService, this._questionService);

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    try {
      _posts = await _postService.getAllPosts();
      notifyListeners();
    } catch (e) {
      print('Error fetching posts: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<int?> addPost(Post post) async {
    try {
      print('PostsProvider: Iniziando la creazione del post');
      print('PostsProvider: Dati del post: ${post.toJson()}');
      final createdPost = await _postService.createPost(post);
      print('PostsProvider: Post creato con successo: ${createdPost.toJson()}');
      await fetchPosts();
      return createdPost.id;
    } catch (e) {
      print('PostsProvider: Errore nell\'aggiunta del post: $e');
      if (e is Exception) {
        print('PostsProvider: Stack trace: ${e.toString()}');
      }
      return null;
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      print('PostsProvider: Aggiornamento del post - ID: ${post.id}');
      print('PostsProvider: Date per l\'aggiornamento - Inizio: ${post.startDate}, Fine: ${post.endDate}');

      await _postService.updatePost(post.id!, post);
      await fetchPosts();
      print('PostsProvider: Post aggiornato con successo');
    } catch (e) {
      print('PostsProvider: Errore durante l\'aggiornamento del post: $e');
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _postService.deletePost(postId);
      await fetchPosts();
    } catch (e) {
      print('Error deleting post: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    try {
      final userPosts = await _postService.getPostsByUser(userId);
      return userPosts;
    } catch (e) {
      print('Error fetching posts by user: $e');
      return [];
    }
  }

  Future<Post?> getPostById(int postId) async {
    try {
      final post = await _postService.getPostById(postId);
      return post;
    } catch (e) {
      print('Error fetching post by ID: $e');
      return null;
    }
  }

  Future<void> deleteOldPosts() async {
    try {
      await _postService.deleteOldPosts();
      await fetchPosts();
    } catch (e) {
      print('Error deleting old posts: $e');
    }
  }

  Future<void> updateParticipationStatus(int postId, int userId, String status) async {
    try {
      print('PostsProvider: Aggiornamento dello stato di partecipazione - PostID: $postId, UserID: $userId, Status: $status');
      await _participationService.updateParticipationStatus(userId, postId, status);
      int index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        _posts[index] = _posts[index].copyWith(isParticipating: status == 'accepted');
        notifyListeners();
      }
      print('PostsProvider: Stato di partecipazione aggiornato con successo');
    } catch (e) {
      print('PostsProvider: Errore nell\'aggiornamento dello stato di partecipazione: $e');
      throw Exception('Impossibile aggiornare lo stato di partecipazione');
    }
  }

  Future<String> getParticipationStatus(int postId, int userId) async {
    try {
      final status = await _participationService.getParticipationStatus(userId, postId);
      return status['status'] as String? ?? 'not_participating';
    } catch (e) {
      print('Error getting participation status: $e');
      return 'not_participating';
    }
  }

  Future<void> requestParticipation(int userId, int postId) async {
    try {
      await _participationService.requestParticipation(userId, postId);
      notifyListeners();
    } catch (e) {
      print('Error requesting participation: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<bool> isUserParticipating(int userId, int postId) async {
    try {
      return await _participationService.isUserParticipating(userId, postId);
    } catch (e) {
      print('Error checking if user is participating: $e');
      return false;
    }
  }

  // Funzioni aggiuntive per la gestione delle partecipazioni
  Future<void> addParticipation(int userId, int postId) async {
    try {
      await _participationService.addParticipation(userId, postId);
      notifyListeners();
    } catch (e) {
      print('Error adding participation: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<void> removeParticipation(int userId, int postId) async {
    try {
      await _participationService.removeParticipation(userId, postId);
      notifyListeners();
    } catch (e) {
      print('Error removing participation: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<void> addSpeakerParticipation(String email, int postId) async {
    try {
      await _participationService.addSpeakerParticipation(email, postId);
      notifyListeners();
    } catch (e) {
      print('Error adding speaker participation: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<void> acceptParticipation(int requesterId, int postId, String status) async {
    try {
      await _participationService.acceptParticipation(requesterId, postId, status);
      notifyListeners();
    } catch (e) {
      print('Error accepting participation: $e');
      // Gestisci l'errore in modo appropriato
    }
  }

  Future<void> insertQuestion(int sessionId, int userId, String question) async {
    try {
      print('Inserting question - SessionID: $sessionId, UserID: $userId, Question: $question');
      await _questionService.insertQuestion(sessionId, userId, question);
      print('Question inserted successfully');
      notifyListeners();
    } catch (e) {
      print('Error inserting question: $e');
      // Handle the error appropriately
    }
  }

  Future<List<Question>> getQuestionsForSession(int sessionId) async {
    try {
      final questionsJson = await _questionService.getQuestionsForSession(sessionId);
      return questionsJson.map((json) => Question.fromjson(json)).toList();
    } catch (e) {
      print('Error retrieving questions for session: $e');
      return [];
    }
  }
}