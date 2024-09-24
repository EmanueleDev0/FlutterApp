import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/post_service.dart';
import '../services/event_session_service.dart';
import '../providers/event_session_provider.dart';

class EventDetailsPage extends StatelessWidget {
  final Post post;
  final VoidCallback? onEdit;

  const EventDetailsPage({super.key, required this.post, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final eventSessionProvider = Provider.of<EventSessionProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromRGBO(12, 134, 77, 1),
        toolbarHeight: 80,
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.decodedImage != null)
                Image.memory(
                  post.decodedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              const SizedBox(height: 16),
              Text(post.description, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Text('Data inizio: ${post.startDate}'),
              Text('Data fine: ${post.endDate}'),
              Text('Luogo: ${post.location}'),
              Text('Autore: ${post.authorName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Ente di afferenza: ${post.authorOrganization}', style: const TextStyle(fontStyle: FontStyle.italic)),
              const SizedBox(height: 24),
              const Text('Sessioni dell\'evento:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<List<EventSession>>(
                future: eventSessionProvider.getEventSessionsForPost(post.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Errore: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Nessuna sessione trovata per questo evento.');
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final session = snapshot.data![index];
                        return Card(
                          color: const Color.fromARGB(255, 2, 66, 5),
                          child: ListTile(
                            title: Text(session.title, 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data: ${session.sessionDate}',
                                  style: const TextStyle(color: Colors.white)),
                                Text('Orario: ${session.startTime} - ${session.endTime}',
                                  style: const TextStyle(color: Colors.white)),
                                Text('Luogo: ${session.location}',
                                  style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}