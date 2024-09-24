import 'package:flutter/foundation.dart';
import '../services/comment_service.dart';

class CommentsProvider with ChangeNotifier {
  final CommentService _commentService;
  final Map<int, List<Comment>> _comments = {};

  CommentsProvider(this._commentService);

  Map<int, List<Comment>> get comments => _comments;

  Future<List<Comment>> getCommentsForPost(int postId) async {
    if (!_comments.containsKey(postId)) {
      await fetchCommentsForPost(postId);
    }
    return _comments[postId] ?? [];
  }

  Future<void> fetchCommentsForPost(int postId) async {
    try {
      print('Fetching comments for post $postId');
      final comments = await _commentService.getCommentsForPost(postId);
      _comments[postId] = comments;
      print('Fetched ${comments.length} comments');
      notifyListeners();
    } catch (e) {
      print('Error fetching comments: $e');
      rethrow;  // Rethrow the error so it can be handled by the UI
    }
  }

  Future<void> addComment(int postId, int userId, String userName, String content) async {
    final comment = Comment(
      postId: postId,
      userId: userId,
      userName: userName,
      content: content,
    );
    
    try {
      print('Adding comment: $content');
      final createdComment = await _commentService.createComment(comment);
      if (!_comments.containsKey(postId)) {
        _comments[postId] = [];
      }
      _comments[postId]!.add(createdComment);
      print('Comment added successfully');
      notifyListeners();
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;  // Rethrow the error so it can be handled by the UI
    }
  }
}