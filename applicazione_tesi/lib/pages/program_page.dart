import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/event_session_provider.dart';
import '../services/event_session_service.dart';
import '../services/question_service.dart';
import '../services/post_service.dart';


class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  _ProgramPageState createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  late Future<List<EventSession>> _userConferencesFuture;
  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = 'mattina'; // Default time slot

  @override
  void initState() {
    super.initState();
    _userConferencesFuture = _fetchUserConferences();
  }

  Future<List<EventSession>> _fetchUserConferences() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.isLoggedIn) {
      return [];
    }
    final userId = userProvider.user!.id!;
    final eventSessionProvider = Provider.of<EventSessionProvider>(context, listen: false);
    
    try {
      return await eventSessionProvider.getUserConferences(userId.toString());
    } catch (e) {
      print('Error fetching user conferences: $e');
      return [];
    }
  }

  List<DateTime> _generateDateRange(DateTime selectedDate) {
    final now = DateTime.now(); // Giorno attuale
    return List<DateTime>.generate(
      7,
      (index) => now.add(Duration(days: index)),
    );
  }

  List<EventSession> _getConferencesForSelectedDateAndTimeSlot(List<EventSession> conferences) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return conferences.where((conference) {
      final conferenceDate = formatter.parse(conference.sessionDate);
      if (conferenceDate.year == _selectedDate.year &&
          conferenceDate.month == _selectedDate.month &&
          conferenceDate.day == _selectedDate.day) {
        final conferenceTime = DateFormat('HH:mm').parse(conference.startTime); // Assuming you have a 'time' field in your session model
        if (_selectedTimeSlot == 'mattina' && conferenceTime.hour >= 6 && conferenceTime.hour < 12) {
          return true;
        } else if (_selectedTimeSlot == 'pomeriggio' && conferenceTime.hour >= 12 && conferenceTime.hour < 18) {
          return true;
        } else if (_selectedTimeSlot == 'sera' && conferenceTime.hour >= 18 && conferenceTime.hour < 24) {
          return true;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(12, 134, 77, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      _buildMonthTitle(),
                      const SizedBox(height: 10),
                      _buildDatePicker(),
                      const SizedBox(height: 10),
                      _buildTimeSlotSelector(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _buildProgramContent(userProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthTitle() {
    final DateFormat formatter = DateFormat('MMMM yyyy', 'it');
    final monthYearFormat = formatter.format(_selectedDate);
    final capitalizedMonthYearFormat = monthYearFormat[0].toUpperCase() + monthYearFormat.substring(1);

    return Center(
      child: Text(
        capitalizedMonthYearFormat,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return FutureBuilder<List<EventSession>>(
      future: _userConferencesFuture,
      builder: (context, snapshot) {
        final dateRange = _generateDateRange(_selectedDate);

        return SizedBox(
          height: 60, // Altezza fissa
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dateRange.length,
            itemBuilder: (context, index) {
              final date = dateRange[index];
              final isSelected = date.isSameDate(_selectedDate);
              final dayOfWeek = DateFormat.E('it').format(date);
              final day = DateFormat.d().format(date);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(12, 134, 77, 1),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected ? Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayOfWeek,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        day,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeSlotButton('mattina', Icons.wb_sunny),
        _buildTimeSlotButton('pomeriggio', Icons.sunny),
        _buildTimeSlotButton('sera', Icons.nights_stay),
      ],
    );
  }

  Widget _buildTimeSlotButton(String slot, IconData icon) {
    final isSelected = _selectedTimeSlot == slot;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeSlot = slot;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color.fromRGBO(12, 134, 77, 1) : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(height: 4),
            Text(
              slot.capitalize(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramContent(UserProvider userProvider) {
    if (!userProvider.isLoggedIn) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Effettua il login per visualizzare il programma',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      );
    }

    return FutureBuilder<List<EventSession>>(
      future: _userConferencesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else {
          final conferencesForSelectedDateAndTimeSlot = snapshot.hasData
              ? _getConferencesForSelectedDateAndTimeSlot(snapshot.data!)
              : [];

          if (conferencesForSelectedDateAndTimeSlot.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna conferenza per la fascia oraria selezionata',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.all(2.0),
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListView.builder(
              itemCount: conferencesForSelectedDateAndTimeSlot.length,
              itemBuilder: (context, index) {
                final conference = conferencesForSelectedDateAndTimeSlot[index];
                final DateTime sessionDate = DateFormat('dd/MM/yyyy').parse(conference.sessionDate);
                final DateTime startTime = DateFormat('HH:mm').parse(conference.startTime);
                final DateTime endTime = DateFormat('HH:mm').parse(conference.endTime);
                final DateTime startDateTime = DateTime(
                  sessionDate.year, sessionDate.month, sessionDate.day, startTime.hour, startTime.minute
                ).toLocal();
                final DateTime endDateTime = DateTime(
                  sessionDate.year, sessionDate.month, sessionDate.day, endTime.hour, endTime.minute
                ).toLocal();
                final bool isSessionActive = DateTime.now().toLocal().isAfter(startDateTime) && DateTime.now().toLocal().isBefore(endDateTime);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: const Color.fromRGBO(12, 134, 77, 1),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conference.title,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        if (isSessionActive)
                          IconButton(
                            icon: const Icon(Icons.question_answer, color: Colors.white),
                            onPressed: () => _showAskQuestionDialog(context, conference),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data: ${conference.sessionDate}', style: const TextStyle(color: Colors.white)),
                        Text('Ora inizio: ${conference.startTime}', style: const TextStyle(color: Colors.white)),
                        Text('Ora fine: ${conference.endTime}', style: const TextStyle(color: Colors.white)),
                        Text('Luogo: ${conference.location}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConferenceDetailsPage(conference: conference),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}

extension StringExtension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}

void _showAskQuestionDialog(BuildContext context, EventSession session) {
  final questionController = TextEditingController();
  final postProvider = Provider.of<PostsProvider>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final userId = userProvider.user!.id!;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Domande per la sessione'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: FutureBuilder<List<Question>>(
                  future: postProvider.getQuestionsForSession(session.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Errore: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Nessuna domanda al momento.');
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final question = snapshot.data![index];
                          return ListTile(
                            title: Text(question.question),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${question.userName} ${question.userSurname}'),
                                  Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(question.timeStamp))),
                                  const Divider(),
                                ],
                              ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionController,
                decoration: const InputDecoration(hintText: 'Scrivi la tua domanda...'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Chiudi'),
          ),
          TextButton(
            onPressed: () async {
              if (questionController.text.isNotEmpty) {
                await postProvider.insertQuestion(session.id!, userId, questionController.text);
                questionController.clear();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Domanda inviata con successo')));
              }
            },
            child: const Text('Invia domanda'),
          ),
        ],
      );
    },
  );
}

class ConferenceDetailsPage extends StatelessWidget {
  final EventSession conference;

  const ConferenceDetailsPage({super.key, required this.conference});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final postProvider = Provider.of<PostsProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(12, 134, 77, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Post?>(
                future: postProvider.getPostById(conference.postId),
                builder: (context, postSnapshot) {
                  if (postSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final post = postSnapshot.data;
                  final isAuthor = post?.authorId == userProvider.user!.id;

                  return FutureBuilder<bool>(
                    future: isAuthor ? Future.value(false) : postProvider.isUserParticipating(userProvider.user!.id!, conference.postId),
                    builder: (context, participationSnapshot) {
                      if (participationSnapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final isParticipating = participationSnapshot.data ?? false;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      conference.title,
                                      style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (!isAuthor && isParticipating)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: IconButton(
                                        onPressed: () async {
                                          await postProvider.removeParticipation(userProvider.user!.id!, conference.postId);
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        tooltip: 'Rimuovi partecipazione',
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(Icons.calendar_today, 'Data: ${conference.sessionDate}'),
                              _buildInfoRow(Icons.access_time, 'Orario: ${conference.startTime} - ${conference.endTime}'),
                              _buildInfoRow(Icons.location_on, 'Luogo: ${conference.location}'),
                              const SizedBox(height: 12),
                              Text(
                                'Descrizione:',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(conference.description),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Torna al programma'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromRGBO(12, 134, 77, 1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}