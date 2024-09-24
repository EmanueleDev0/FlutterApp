import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class PostService {
  final String baseUrl = 'http://localhost:3000/api/posts';

  Future<Post> createPost(Post post) async {
    try {
      print('PostService: Iniziando la creazione del post');
      final postJson = post.toJson();
      print('PostService: Dati del post dopo toJson: $postJson');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postJson),
      );

      print('PostService: Risposta del server - Status code: ${response.statusCode}');
      print('PostService: Risposta del server - Body: ${response.body}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        print('PostService: Post creato con successo: $jsonResponse');
        
        // Invece di creare un nuovo oggetto Post dalla risposta,
        // aggiorniamo solo l'ID del post originale
        return post.copyWith(id: jsonResponse['id']);
      } else {
        print('PostService: Errore nella creazione del post. Status code: ${response.statusCode}');
        throw Exception('Failed to create post: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('PostService: Eccezione catturata durante la creazione del post: $e');
      rethrow;
    }
  }

  Future<Post> updatePost(int id, Post post) async {
    print('PostService: Aggiornamento del post - ID: $id');
    print('PostService: Date per l\'aggiornamento - Inizio: ${post.startDate}, Fine: ${post.endDate}');

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );

    print('PostService: Risposta del server - Status code: ${response.statusCode}');
    print('PostService: Risposta del server - Body: ${response.body}');

    if (response.statusCode == 200) {
      print('PostService: Post aggiornato con successo');
      return post;
    } else {
      print('PostService: Errore nell\'aggiornamento del post. Status code: ${response.statusCode}');
      throw Exception('Failed to update post: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deletePost(int postId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$postId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }

  Future<List<Post>> getPostsByUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<Post?> getPostById(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/$postId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return Post.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<List<Post>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> deleteOldPosts() async {
    final response = await http.delete(Uri.parse('$baseUrl/old'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete old posts');
    }
  }
}

class Post {
  final int? id;
  final String title;
  final String? image;
  final String description;
  final String startDate;   
  final String? endDate;        
  final String location;
  final int authorId;
  final String authorName;
  final String authorOrganization;
  bool isParticipating;
  final bool commentsEnabled;
  final bool moderationEnabled;

  Post({
    this.id,
    required this.title,
    this.image,
    required this.description,
    required this.startDate,   
    this.endDate,                  
    required this.location,
    required this.authorId,
    required this.authorName,
    required this.authorOrganization,
    this.isParticipating = false,
    required this.commentsEnabled,
    this.moderationEnabled = true,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      image: json['image'],
      description: json['description'],
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'],
      location: json['location'],
      authorId: json['author_id'] ?? 0,
      authorName: json['author_name'] ?? '',
      authorOrganization: json['author_organization'] ?? '',
      commentsEnabled: json['commentsEnabled'] == 1,
      moderationEnabled: json['moderationEnabled'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'description': description,
      'start_date': startDate,  
      'end_date': endDate,      
      'location': location,
      'author_id': authorId,
      'author_name': authorName,
      'author_organization': authorOrganization,
      'commentsEnabled': commentsEnabled ? 1 : 0,
      'moderationEnabled': moderationEnabled ? 1 : 0,
    }..removeWhere((key, value) => value == null);
  }

  Post copyWith({
    int? id,
    String? title,
    String? image,
    String? description,
    String? startDate,
    String? endDate,
    String? location,
    int? authorId,
    String? authorName,
    String? authorOrganization,
    bool? isParticipating,
    bool? commentsEnabled,
    bool? moderationEnabled,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorOrganization: authorOrganization ?? this.authorOrganization,
      isParticipating: isParticipating ?? this.isParticipating,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      moderationEnabled: moderationEnabled ?? this.moderationEnabled,
    );
  }

  Uint8List? get decodedImage {
    if (image != null && image!.isNotEmpty) {
      try {
        return base64Decode(image!);
      } catch (e) {
        print('Errore nella decodifica dell\'immagine: $e');
        return null;
      }
    }
    return null;
  }
}