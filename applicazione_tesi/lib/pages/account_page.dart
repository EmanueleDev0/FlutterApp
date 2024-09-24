import 'package:applicazione_tesi/providers/event_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event_details.dart';
import '../providers/users_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/comments_provider.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';
import '../services/event_session_service.dart';
import '../services/notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:bcrypt/bcrypt.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hasNotifications = false;

  @override
  void initState() {
    super.initState();
    _checkForNotifications();
  }

  Future<void> _checkForNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn && userProvider.user != null && userProvider.user!.id != null) {
      final notifications = await userProvider.getNotificationsForCurrentUser();
      setState(() {
        _hasNotifications = notifications.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final postsProvider = Provider.of<PostsProvider>(context);
    final commentsProvider = Provider.of<CommentsProvider>(context);
    final eventsProvider = Provider.of<EventSessionProvider>(context);

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
            child: Padding(
              padding: const EdgeInsets.only(top: 100), // Add top padding for the title
              child: userProvider.isLoggedIn
                  ? _buildLoggedInView(userProvider.user!, postsProvider, commentsProvider, eventsProvider)
                  : _buildLoginView(userProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginView(UserProvider userProvider) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Effettua il login per accedere alla tua pagina personale",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per favore inserisci la tua email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per favore inserisci la tua password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _login(userProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 2, 66, 5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationPage()),
                        );
                      },
                      child: const Text('Crea un nuovo account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login(UserProvider userProvider) async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final user = await userProvider.login(email, password);
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login effettuato con successo')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email o password non validi')),
          );
        }
      } catch (e) {
        print('Errore durante il login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Si è verificato un errore durante il login')),
        );
      }
    }
  }

  Widget _buildLoggedInView(User user, PostsProvider postsProvider, CommentsProvider commentsProvider, EventSessionProvider eventsProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ciao, ${user.name}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Stack(
                children: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout();
                      } else if (value == 'delete') {
                        _showDeleteAccountDialog();
                      } else if (value == 'notifications') {
                        _showNotificationsDialog();
                      } else if (value == 'change_password') {
                        _showChangePasswordDialog();
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'notifications',
                        child: Row(
                          children: [
                            const Text('Notifiche'),
                            if (_hasNotifications)
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'change_password',
                        child: Text('Cambia password'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Elimina account'),
                      ),
                    ],
                  ),
                  if (_hasNotifications)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: postsProvider.getPostsByUser(user.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nessun post pubblicato', style: TextStyle(color: Colors.white)));
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 110),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final post = snapshot.data![index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EventDetailsPage(
                              post: post,
                              onEdit: () => _showEditDeleteDialog(post, postsProvider, eventsProvider),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                  Text(
                                    post.description,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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
                                    _buildCommentsList(post),
                                    _CommentInput(
                                      commentsProvider: commentsProvider,
                                      postId: post.id!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDeleteDialog(post, postsProvider, eventsProvider),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList(Post post) {
    final commentsProvider = Provider.of<CommentsProvider>(context, listen: false);
    return FutureBuilder<List<Comment>>(
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
    );
  }

  void _showEditDeleteDialog(Post post, PostsProvider postsProvider, EventSessionProvider eventsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica o elimina post'),
          content: const Text('Cosa vuoi fare con questo post?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Modifica post'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditPostDialog(post, postsProvider);
              },
            ),
            TextButton(
              child: const Text('Modifica sessioni'),
              onPressed: () {
                Navigator.of(context).pop();
                _showEditSessionsDialog(post, eventsProvider);
              },
            ),
            TextButton(
              child: const Text('Elimina'),
              onPressed: () {
                Navigator.of(context).pop();
                _showDeletePostDialog(post, postsProvider);
              },
            ),
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

void _showEditPostDialog(Post post, PostsProvider postsProvider) {
  final titleController = TextEditingController(text: post.title);
  final descriptionController = TextEditingController(text: post.description);
  final startDateController = TextEditingController(text: post.startDate);
  final endDateController = TextEditingController(text: post.endDate ?? '');
  final locationController = TextEditingController(text: post.location);
  String? _imageBase64 = post.image;
  String? _imageName;

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      String fileName = result.files.first.name;
      
      setState(() {
        _imageBase64 = base64Encode(fileBytes);
        _imageName = fileName;
      });
    }
  }

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      controller.text = formattedDate;
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Modifica post'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titolo/tipologia evento'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrizione'),
              ),
              TextField(
                controller: startDateController,
                decoration: const InputDecoration(labelText: 'Data inizio (dd/mm/yyyy)'),
                readOnly: true,
                onTap: () => selectDate(startDateController),
              ),
              TextField(
                controller: endDateController,
                decoration: const InputDecoration(labelText: 'Data fine (dd/mm/yyyy)'),
                readOnly: true,
                onTap: () => selectDate(endDateController),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Luogo'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Scegli immagine'),
              ),
              if (_imageName != null) Text('Immagine selezionata: $_imageName', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Annulla'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Salva'),
            onPressed: () async {
              final updatedPost = post.copyWith(
                title: titleController.text,
                image: _imageBase64,
                description: descriptionController.text,
                startDate: startDateController.text,
                endDate: endDateController.text.isNotEmpty ? endDateController.text : null,
                location: locationController.text,
              );
              print('Debug: Dati del post aggiornato:');
              print('Title: ${updatedPost.title}');
              print('Start Date: ${updatedPost.startDate}');
              print('End Date: ${updatedPost.endDate}');
              print('Location: ${updatedPost.location}');
              await postsProvider.updatePost(updatedPost);
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ],
      );
    },
  );
}

  void _showEditSessionsDialog(Post post, EventSessionProvider eventsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica sessioni'),
          content: FutureBuilder<List<EventSession>>(
            future: eventsProvider.getEventSessionsForPost(post.id!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Errore: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nessuna sessione per questo post');
              } else {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final session = snapshot.data![index];
                      return ListTile(
                        title: Text(session.title ?? 'Sessione ${index + 1}'),
                        subtitle: Text('${session.sessionDate} - ${session.startTime} - ${session.endTime}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditSessionDialog(session, eventsProvider),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aggiungi sessione'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAddSessionDialog(post, eventsProvider);
              },
            ),
            TextButton(
              child: const Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeletePostDialog(Post post, PostsProvider postsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina post'),
          content: const Text('Sei sicuro di voler eliminare questo post? Questa azione non può essere annullata.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Elimina'),
              onPressed: () async {
                await postsProvider.deletePost(post.id!);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditSessionDialog(EventSession session, EventSessionProvider eventsProvider) {
    final titleController = TextEditingController(text: session.title);
    final startTimeController = TextEditingController(text: session.startTime);
    final endTimeController = TextEditingController(text: session.endTime);
    final descriptionController = TextEditingController(text: session.description);
    final locationController = TextEditingController(text: session.location);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Modifica sessione'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titolo'),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Ora inizio'),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'Ora fine'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Luogo'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salva'),
              onPressed: () async {
                final updatedSession = EventSession(
                  id: session.id,
                  postId: session.postId,
                  title: titleController.text,
                  sessionDate: session.sessionDate,
                  startTime: startTimeController.text,
                  endTime: endTimeController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                );
                await eventsProvider.updateEventSession(updatedSession);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddSessionDialog(Post post, EventSessionProvider eventsProvider) {
    final titleController = TextEditingController();
    final sessionDateController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aggiungi sessione'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titolo'),
                ),
                TextField(
                  controller: sessionDateController,
                  decoration: const InputDecoration(labelText: 'Data'),
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Ora inizio'),
                ),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'Ora fine'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrizione'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Luogo'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aggiungi'),
              onPressed: () async {
                final newSession = EventSession(
                  postId: post.id!,
                  title: titleController.text,
                  sessionDate: sessionDateController.text,
                  startTime: startTimeController.text,
                  endTime: endTimeController.text,
                  description: descriptionController.text,
                  location: locationController.text,
                );
                await eventsProvider.createEventSession(newSession);
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina account'),
          content: const Text('Sei sicuro di voler eliminare il tuo account? Questa azione non può essere annullata.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Elimina'),
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                try {
                  await userProvider.deleteAccount();
                  Navigator.of(context).pop(); // Chiudi il dialog
                  // Invece di reindirizzare alla pagina di login, facciamo un logout
                  userProvider.logout();
                  // Ricarica la pagina corrente per mostrare la vista di login
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account eliminato con successo')),
                  );
                } catch (e) {
                  Navigator.of(context).pop(); // Chiudi il dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore durante l\'eliminazione dell\'account: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showNotificationsDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notifiche'),
          content: FutureBuilder<List<Notifications>>(
            future: _getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Errore: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Nessuna notifica');
              } else {
                return SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final notification = snapshot.data![index];

                      return Dismissible(
                        key: Key(notification.id.toString()), // Chiave univoca per ciascuna notifica
                        direction: DismissDirection.endToStart, // Swipe verso destra per eliminare
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          // Rimuovi la notifica dal database e aggiorna la lista
                          await userProvider.deleteNotification(notification.id!);
                          setState(() {
                            snapshot.data!.removeAt(index); // Rimuovi dalla lista visiva
                          });

                          // Mostra un messaggio di conferma
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notifica eliminata')),
                          );
                        },
                        child: ListTile(
                          title: Text(notification.title ?? 'Notifica'),
                          subtitle: Text(notification.message ?? ''),
                          trailing: notification.type == 'participation_request'
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: () => _handleParticipationRequest(context, notification, true),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _handleParticipationRequest(context, notification, false),
                                    ),
                                  ],
                                )
                              : Text(notification.date ?? ''),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Chiudi'),
              onPressed: () {
                Navigator.of(context).pop();
                _checkForNotifications(); // Aggiorna lo stato delle notifiche dopo la chiusura
              },
            ),
          ],
        );
      },
    );
  }


  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmNewPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambia password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password attuale'),
                ),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nuova password'),
                ),
                TextField(
                  controller: confirmNewPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Conferma nuova password'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cambia'),
              onPressed: () async {
                if (newPasswordController.text != confirmNewPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nuove password non corrispondono')),
                  );
                  return;
                }

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                if (userProvider.isLoggedIn && userProvider.user != null) {
                  try {
                    final success = await userProvider.changePasswordForUser(
                      userProvider.user!.id!,
                      currentPasswordController.text,
                      newPasswordController.text,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password cambiata con successo')),
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password attuale non corretta')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Errore durante il cambio password')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Notifications>> _getNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isLoggedIn && userProvider.user != null && userProvider.user!.id != null) {
      try {
        return await userProvider.getNotificationsForCurrentUser();
      } catch (e) {
        print('Errore nel recupero delle notifiche: $e');
        return [];
      }
    }
    return [];
  }

  void _handleParticipationRequest(BuildContext context, Notifications notification, bool accept) async {
    final postsProvider = Provider.of<PostsProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (notification.requesterId == null || notification.postId == null) {
      print('Dati della notifica non validi: requesterId=${notification.requesterId}, postId=${notification.postId}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dati della notifica non validi. Impossibile elaborare la richiesta.')),
      );
      return;
    }

    final status = accept ? 'accepted' : 'rejected';
    try {
      print('Aggiornamento dello stato di partecipazione: postId=${notification.postId}, requesterId=${notification.requesterId}, status=$status');
      await postsProvider.updateParticipationStatus(
        notification.postId!,
        notification.requesterId!,
        status,
      );

      final newNotification = Notifications(
        userId: notification.requesterId!,
        title: 'Aggiornamento richiesta di partecipazione',
        message: 'La tua richiesta di partecipazione è stata ${accept ? 'accettata' : 'rifiutata'}.',
        date: DateTime.now().toString(),
        type: 'participation_response',
        postId: notification.postId,
      );
      await userProvider.createNotification(newNotification);

      if (notification.id != null) {
        await userProvider.deleteNotification(notification.id!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Richiesta di partecipazione ${accept ? 'accettata' : 'rifiutata'}')),
      );

      Navigator.of(context).pop(); // Chiude il dialog delle notifiche
    } catch (e) {
      print('Errore nella gestione della richiesta di partecipazione: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Si è verificato un errore. Riprova più tardi.')),
      );
    }
  }
}

class _CommentInput extends StatefulWidget {
  final CommentsProvider commentsProvider;
  final int postId;

  const _CommentInput({super.key, required this.commentsProvider, required this.postId});

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

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isLoggedIn) {
        widget.commentsProvider.addComment(
          widget.postId,
          userProvider.user!.id!,
          '${userProvider.user!.name} ${userProvider.user!.surname}',
          _commentController.text,
        );
        _commentController.clear();
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

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrazione')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci il tuo nome';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _surnameController,
              decoration: const InputDecoration(labelText: 'Cognome *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci il tuo cognome';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email *'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci la tua email';
                }
                if (!isValidEmail(value)) {
                  return 'Per favore inserisci una email valida';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password *'),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci una password';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _organizationController,
              decoration: const InputDecoration(labelText: 'Ente di afferenza'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 66, 5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Registrati'),
            ),
            const SizedBox(height: 16),
            // Aggiunta della legenda per i campi obbligatori
            const Text(
              '* Campi obbligatori',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color.fromARGB(255, 2, 66, 5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    // Simple email validation
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegExp.hasMatch(email);
  }

  void _register() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      // Hashare la password
      String hashedPassword = BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());

      final newUser = User(
        name: _nameController.text,
        surname: _surnameController.text,
        email: _emailController.text,
        password: hashedPassword, // Usiamo la password hashata
        organization: _organizationController.text,
      );

      try {
        print('Attempting to create user: ${newUser.toJson()}');
        final userId = await userProvider.createUser(newUser);
        print('User created with ID: $userId');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrazione effettuata con successo')),
        );
        Navigator.pop(context);
      } catch (e) {
        print('Error during user creation: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante la registrazione: $e')),
        );
      }
    }
  }
}