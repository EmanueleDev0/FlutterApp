import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/users_provider.dart';
import '../providers/posts_provider.dart';
import '../providers/event_session_provider.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../services/event_session_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:bcrypt/bcrypt.dart';
import 'dart:typed_data';
import 'dart:convert';

class CreatepostPage extends StatefulWidget {
  const CreatepostPage({super.key});

  @override
  _CreatepostPageState createState() => _CreatepostPageState();
}

class _CreatepostPageState extends State<CreatepostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startDateController = TextEditingController(); 
  final _endDateController = TextEditingController();      
  final _locationController = TextEditingController();
  final _speakersController = TextEditingController();
  String? _imageBase64;
  String? _imageName;
  String _selectedEventType = 'singolo giorno'; // Opzione predefinita
  Map<String, List<Map<String, dynamic>>> _multiDaySessions = {}; // Per i dettagli delle sessioni di più giorni
  final List<Map<String, dynamic>> _singleDaySessions = [];
  final List<Map<String, String>> _csvUsers = [];

  final ImagePicker _picker = ImagePicker();
  bool _commentsEnabled = true;
  bool _moderationEnabled = true; 

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoggedIn) {
      return const Center(
        child: Text('Effettua il login per creare un evento', style: TextStyle(fontSize: 20, color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(12, 134, 77, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormFields(),
                            const SizedBox(height: 10),
                            CheckboxListTile(
                              title: const Text('Abilita commenti'),
                              value: _commentsEnabled,
                              onChanged: (bool? value) {
                                setState(() {
                                  _commentsEnabled = value ?? true;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            CheckboxListTile(
                              title: const Text('Abilita moderazione partecipanti'),
                              value: _moderationEnabled,
                              onChanged: (bool? value) {
                                setState(() {
                                  _moderationEnabled = value ?? true;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => uploadCSVAndRegisterUsers(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 2, 66, 5),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    ),
                                    child: const Text('Carica CSV e registra utenti', style: TextStyle(fontSize: 18)),
                                  ),
                                  const SizedBox(height: 5),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      "Se desideri far partecipare automaticamente alcuni utenti che non hanno ancora creato un account, "
                                      "puoi inserire un file CSV con il seguente formato: nome,cognome,email,password,ente(se presente)",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => _savePost(userProvider.user!),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 2, 66, 5),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                ),
                                child: const Text('Salva evento', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(labelText: 'Titolo/tipologia evento *'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci un titolo';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: const Text('Seleziona un\'immagine'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 2, 66, 5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        if (_imageName != null) Text('Immagine selezionata: $_imageName', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 10),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(labelText: 'Descrizione*'),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci una descrizione';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        const Text('Tipo di evento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          value: _selectedEventType,
          onChanged: (String? newValue) {
            setState(() {
              _selectedEventType = newValue!;
              if (_selectedEventType == 'singolo giorno') {
                _multiDaySessions.clear();
              }
            });
          },
          items: <String>['singolo giorno', 'più giorni']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        if (_selectedEventType == 'singolo giorno') ...[
          _buildSingleDayFields(),
        ] else if (_selectedEventType == 'più giorni') ...[
          _buildMultiDayFields(),
        ],
        const SizedBox(height: 10),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Luogo evento *'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Inserisci il luogo evento';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _speakersController,
          decoration: const InputDecoration(
            labelText: 'Email dei relatori (separati da virgola)',
            hintText: 'esempio1@email.com, esempio2@email.com',
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '* Campi obbligatori',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Color.fromARGB(255, 2, 66, 5),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleDayFields() {
    return Column(
      children: [
        TextFormField(
          controller: _startDateController,
          decoration: const InputDecoration(labelText: 'Data *', hintText: 'dd/mm/yyyy'),
          onTap: _selectStartDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Per favore, inserisci la data';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildSingleDaySessions(),
      ],
    );
  }

  Widget _buildSingleDaySessions() {
    return Column(
      children: [
        ..._singleDaySessions.asMap().entries.map((sessionEntry) {
          int index = sessionEntry.key;
          Map<String, dynamic> session = sessionEntry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sessione ${index + 1}:"),
              TextFormField(
                controller: session['titleController'],
                decoration: const InputDecoration(labelText: 'Titolo della sessione *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un titolo per la sessione';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: session['descriptionController'],
                decoration: const InputDecoration(labelText: 'Descrizione della sessione *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci una descrizione per la sessione';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: session['startTimeController'],
                decoration: const InputDecoration(labelText: 'Orario di inizio *', hintText: 'hh:mm'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un orario di inizio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: session['endTimeController'],
                decoration: const InputDecoration(labelText: 'Orario di fine *', hintText: 'hh:mm'),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: session['locationController'],
                decoration: const InputDecoration(labelText: 'Luogo *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un luogo per la sessione';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
        Center(
          child: ElevatedButton(
            onPressed: _addSingleDaySession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 2, 66, 5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Aggiungi sessione per il giorno'),
          ),
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildMultiDayFields() {
    return Column(
      children: [
        TextFormField(
          controller: _startDateController,
          decoration: const InputDecoration(labelText: 'Data di inizio *', hintText: 'dd/mm/yyyy'),
          onTap: _selectStartDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Per favore, inserisci la data di inizio';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _endDateController,
          decoration: const InputDecoration(labelText: 'Data di fine *', hintText: 'dd/mm/yyyy'),
          onTap: _selectEndDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Per favore, inserisci la data di fine';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        _buildMultiDaySessions(),
      ],
    );
  }

  Widget _buildMultiDaySessions() {
    return Column(
      children: _multiDaySessions.entries.map((entry) {
        String date = entry.key;
        List<Map<String, dynamic>> sessions = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sessioni per il giorno $date:", style: const TextStyle(fontWeight: FontWeight.bold)),
            ...sessions.asMap().entries.map((sessionEntry) {
              int index = sessionEntry.key;
              Map<String, dynamic> session = sessionEntry.value;
              return Column(
                children: [
                  Text("Sessione ${index + 1}:"),
                  TextFormField(
                    controller: session['titleController'],
                    decoration: const InputDecoration(labelText: 'Titolo della sessione *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un titolo per la sessione';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: session['descriptionController'],
                    decoration: const InputDecoration(labelText: 'Descrizione della sessione *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci una descrizione per la sessione';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: session['startTimeController'],
                    decoration: const InputDecoration(labelText: 'Orario di inizio *', hintText: 'hh:mm'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un orario di inizio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: session['endTimeController'],
                    decoration: const InputDecoration(labelText: 'Orario di fine *', hintText: 'hh:mm'),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: session['locationController'],
                    decoration: const InputDecoration(labelText: 'Luogo *'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci un luogo per la sessione';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            Center ( 
              child: ElevatedButton(
                onPressed: () => _addSessionForDate(date),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 2, 66, 5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Aggiungi sessione per $date'),
              ),
            ),
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _selectStartDate() async {
    DateTime? picked = await _selectDate();
    if (picked != null) {
      setState(() {
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _updateMultiDaySessions();
      });
    }
  }

  void _addSessionForDate(String date) {
    setState(() {
      _multiDaySessions[date]!.add(_createNewSession());
    });
  }

  void _addSingleDaySession() {
    setState(() {
      _singleDaySessions.add(_createNewSession());
    });
  }

  bool _hasSingleDaySessions() {
    return _singleDaySessions.isNotEmpty;
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await _selectDate();
    if (picked != null) {
      setState(() {
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _updateMultiDaySessions();
      });
    }
  }

  Future<DateTime?> _selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
  }

  void _updateMultiDaySessions() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) return;

    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime start = format.parse(_startDateController.text);
    DateTime end = format.parse(_endDateController.text);

    Map<String, List<Map<String, dynamic>>> newSessions = {};

    for (int i = 0; !start.add(Duration(days: i)).isAfter(end); i++) {
      String date = DateFormat('dd/MM/yyyy').format(start.add(Duration(days: i)));
      newSessions[date] = _multiDaySessions[date] ?? [_createNewSession()];
    }

    setState(() {
      _multiDaySessions = newSessions;
    });
  }

  Map<String, dynamic> _createNewSession() {
    return {
      'titleController': TextEditingController(),
      'descriptionController': TextEditingController(),
      'startTimeController': TextEditingController(),
      'endTimeController': TextEditingController(),
      'locationController': TextEditingController(),
    };
  }

  Future<void> _pickImage() async {
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

  Future<void> uploadCSVAndRegisterUsers(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null) {
      Uint8List fileBytes = result.files.first.bytes!;
      String contents = utf8.decode(fileBytes);
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(contents);

      _csvUsers.clear();

      for (var row in rowsAsListOfValues) {
        if (row.length >= 4) {
          // Hash della password
          String hashedPassword = BCrypt.hashpw(row[3].toString(), BCrypt.gensalt());
          
          _csvUsers.add({
            'name': row[0].toString(),
            'surname': row[1].toString(),
            'email': row[2].toString(),
            'password': hashedPassword, // Usa la password hashata
            'organization': row.length > 4 ? row[4].toString() : '',
          });
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_csvUsers.length} utenti caricati dal CSV con password hashate. Premi "Salva evento" per completare la registrazione.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun file selezionato')),
      );
    }
  }

  Future<void> _savePost(User user) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedEventType == 'singolo giorno' && !_hasSingleDaySessions()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Devi aggiungere almeno una sessione per un evento di un singolo giorno')),
        );
        return;
      }

      Post post = Post(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDateController.text,
        endDate: _selectedEventType == 'singolo giorno'
            ? _startDateController.text
            : _endDateController.text.isNotEmpty
                ? _endDateController.text
                : _startDateController.text,
        image: _imageBase64,
        location: _locationController.text,
        authorId: user.id!,
        authorName: '${user.name} ${user.surname}',
        authorOrganization: user.organization!,
        commentsEnabled: _commentsEnabled,
        moderationEnabled: _moderationEnabled,
      );

      try {
        final postsProvider = Provider.of<PostsProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final eventSessionProvider = Provider.of<EventSessionProvider>(context, listen: false);
        
        // Create the post and get the postId
        int? postId = await postsProvider.addPost(post);
        if (postId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Errore: Impossibile creare il post')),
          );
          return;
        }

        // Register CSV users and add them as participants
        for (var csvUser in _csvUsers) {
          User newUser = User(
            name: csvUser['name']!,
            surname: csvUser['surname']!,
            email: csvUser['email']!,
            password: csvUser['password']!,
            organization: csvUser['organization']!,
          );

          // Usa createUserWithoutLogin invece di createUser
          int userId = await userProvider.createUserWithoutLogin(newUser);
          await postsProvider.addParticipation(userId, postId);
          await postsProvider.updateParticipationStatus(postId, userId, 'accepted');
        }

        // Add speaker participations
        List<String> speakerEmails = _speakersController.text.split(',').map((e) => e.trim()).toList();
        for (String email in speakerEmails) {
          await postsProvider.addSpeakerParticipation(email, postId);
        }

        // Create event sessions
        print('DEBUG: Iniziando la creazione delle sessioni');
        List<Future<void>> sessionCreationFutures = [];

        if (_selectedEventType == 'più giorni') {
          for (var entry in _multiDaySessions.entries) {
            String date = entry.key;
            List<Map<String, dynamic>> sessions = entry.value;
            for (var session in sessions) {
              final eventSession = EventSession(
                postId: postId,
                title: session['titleController'].text,
                description: session['descriptionController'].text,
                sessionDate: date,
                startTime: session['startTimeController'].text,
                endTime: session['endTimeController'].text,
                location: session['locationController'].text,
              );
              print('DEBUG: Creazione sessione - Data: $date, Titolo: ${eventSession.title}');
              sessionCreationFutures.add(eventSessionProvider.createEventSession(eventSession));
            }
          }
        } else {
          for (var session in _singleDaySessions) {
            final eventSession = EventSession(
              postId: postId,
              title: session['titleController'].text,
              description: session['descriptionController'].text,
              sessionDate: _startDateController.text,
              startTime: session['startTimeController'].text,
              endTime: session['endTimeController'].text,
              location: session['locationController'].text,
            );
            print('DEBUG: Creazione sessione - Data: ${_startDateController.text}, Titolo: ${eventSession.title}');
            sessionCreationFutures.add(eventSessionProvider.createEventSession(eventSession));
          }
        }

        // Wait for all session creations to complete
        print('DEBUG: Attendendo la creazione di tutte le sessioni');
        await Future.wait(sessionCreationFutures);
        print('DEBUG: Tutte le sessioni create con successo');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post salvato con successo. ${_csvUsers.length} utenti registrati e aggiunti come partecipanti.')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _imageName = null;
          _titleController.clear;
          _descriptionController.clear();
          _locationController.clear();
          _endDateController.clear();
          _imageBase64 = null;
          _speakersController.clear();
          _startDateController.clear();
          _multiDaySessions.clear();
          _csvUsers.clear();  
        });
      } catch (e, stackTrace) {
        print('Errore dettagliato: $e');
        print('Stack trace: $stackTrace');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio del post: $e')),
        );
      }
    }
  }
}
