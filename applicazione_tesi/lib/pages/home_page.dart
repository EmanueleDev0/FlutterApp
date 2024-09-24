import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_details.dart';
import '../providers/posts_provider.dart';
import '../providers/comments_provider.dart';
import '../providers/users_provider.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../services/notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _fetchPostsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPostsFuture = _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    await Provider.of<PostsProvider>(context, listen: false).fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PostsProvider, CommentsProvider>(
      builder: (context, postsProvider, commentsProvider, child) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/background.jpeg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SafeArea(
                child: FutureBuilder(
                  future: _fetchPostsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 105),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildSearchBar(),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 100.0,
                              ),
                              child: _buildPostsList(postsProvider, commentsProvider),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Cerca eventi...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildPostsList(PostsProvider postsProvider, CommentsProvider commentsProvider) {
    final filteredPosts = postsProvider.posts.where((post) {
      return post.title.toLowerCase().contains(_searchQuery) ||
             post.description.toLowerCase().contains(_searchQuery) ||
             post.location.toLowerCase().contains(_searchQuery) ||
             post.authorName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filteredPosts.isEmpty) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Nessun evento trovato',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailsPage(post: post),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildParticipateButton(post),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (post.decodedImage != null)
                    Image.memory(
                      post.decodedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                  const SizedBox(height: 8),
                  Text(post.description,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Data inizio: ${post.startDate}'),
                  Text('Data fine: ${post.endDate}'),
                  Text('Luogo: ${post.location}'),
                  Text('Autore: ${post.authorName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Ente di afferenza: ${post.authorOrganization}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  if (post.commentsEnabled) ...[
                    const Text(
                      'Commenti',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildCommentsList(post, commentsProvider),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentsList(Post post, CommentsProvider commentsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<Comment>>(
          future: commentsProvider.getCommentsForPost(post.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Errore nel caricamento dei commenti');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Nessun commento');
            } else {
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: Color.fromARGB(255, 2, 66, 5)),
                itemBuilder: (context, index) {
                  final comment = snapshot.data![index];
                  return ListTile(
                    title: Text(comment.userName),
                    subtitle: Text(comment.content),
                  );
                },
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _CommentInput(
          commentsProvider: commentsProvider,
          postId: post.id!,
          onCommentAdded: () {
            setState(() {});  // Trigger a rebuild of the widget
          },
        ),
      ],
    );
  }

  Widget _buildParticipateButton(Post post) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    if (!userProvider.isLoggedIn) {
      return ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Devi effettuare il login per partecipare')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 2, 66, 5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Partecipa'),
      );
    }

    // Se l'utente è il creatore del post, non mostrare il pulsante
    if (userProvider.user?.id == post.authorId) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<String>(
      future: postsProvider.getParticipationStatus(post.id!, userProvider.user!.id!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final participationStatus = snapshot.data;

        if (participationStatus == null || participationStatus == 'not_participating') {
          return ElevatedButton(
            onPressed: () async {
              try {
                if (post.moderationEnabled) {
                  await postsProvider.requestParticipation(userProvider.user!.id!, post.id!);
                  
                  // Create a notification for the post author
                  await notificationService.createNotification(
                    Notifications(
                      userId: post.authorId,
                      title: 'Nuova richiesta di partecipazione',
                      message: '${userProvider.user!.name} ${userProvider.user!.surname} ha richiesto di partecipare al tuo evento "${post.title}"',
                      date: DateTime.now().toString(),
                      type: 'participation_request',
                      postId: post.id,
                      requesterId: userProvider.user!.id,
                      status: 'pending',
                    )
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Richiesta di partecipazione inviata')),
                  );
                } else {
                  await postsProvider.addParticipation(userProvider.user!.id!, post.id!);
                  await postsProvider.updateParticipationStatus(post.id!, userProvider.user!.id!, 'accepted');
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partecipazione confermata')),
                  );
                }

                // Forza un aggiornamento dell'interfaccia utente
                setState(() {});
              } catch (e) {
                print('Error during participation: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Si è verificato un errore. Riprova più tardi.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 66, 5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Partecipa'),
          );
        } else if (participationStatus == 'pending') {
          return const Text('Richiesta Inviata', style: TextStyle(color: Color.fromARGB(255, 199, 121, 4)));
        } else if (participationStatus == 'accepted') {
          return const Text('Accettato', style: TextStyle(color: Color.fromARGB(255, 11, 95, 14)));
        } else if (participationStatus == 'rejected') {
          return const Text('Rifiutato', style: TextStyle(color: Color.fromARGB(255, 255, 32, 17)));
        } else {
          return const Text('Stato sconosciuto');
        }
      },
    );
  }
}

class _CommentInput extends StatefulWidget {
  final CommentsProvider commentsProvider;
  final int postId;
  final VoidCallback onCommentAdded;

  const _CommentInput({
    Key? key, 
    required this.commentsProvider, 
    required this.postId, 
    required this.onCommentAdded,
  }) : super(key: key);

  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _commentController,
      decoration: InputDecoration(
        hintText: 'Aggiungi un commento...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: _addComment,
        ),
      ),
    );
  }

  void _addComment() async {
    if (_commentController.text.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn) {
        try {
          print('Attempting to add comment for post ${widget.postId}');  // Add this line
          await widget.commentsProvider.addComment(
            widget.postId,
            userProvider.user!.id!,
            '${userProvider.user!.name} ${userProvider.user!.surname}',
            _commentController.text,
          );
          print('Comment added successfully');
          _commentController.clear();
          widget.onCommentAdded();
          
          if (mounted) {
            setState(() {});
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commento aggiunto con successo')),
          );
        } catch (e) {
          print('Error adding comment: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore nell\'aggiunta del commento: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devi effettuare il login per commentare')),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}