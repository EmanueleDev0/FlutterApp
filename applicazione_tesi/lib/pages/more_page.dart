import 'package:flutter/material.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  // Lista contenente tutte le voci della pagina "More"
  final List<Map<String, dynamic>> entries = [
    {
      'title': 'Contacts',
      'icon': Icons.contact_phone_outlined,
      'content': const ContactsPage(),
      'searchableContent': 'Developer Emanuele Russo University of Messina email Contacts Professor Nucita Supervisor',
    },
    {
      'title': 'General Info',
      'icon': Icons.info,
      'content': const GeneralInfoPage(),
      'searchableContent': 'Welcome to our event platform conferences events scientific humanistic disciplines',
    },
    {
      'title': 'FAQ',
      'icon': Icons.help_outline,
      'content': const FaqPage(),
      'searchableContent': 'FAQ participate conference login register modify post search delete account subscribe sessions add',
    },
  ];

  // Variabile per contenere le voci filtrate
  List<Map<String, dynamic>> filteredEntries = [];

  @override
  void initState() {
    super.initState();
    filteredEntries = entries; // Inizializza la lista filtrata con tutte le voci
  }

  // Funzione per filtrare le voci in base alla ricerca
  void _filterEntries(String query) {
    final filtered = entries.where((entry) {
      final titleLower = entry['title'].toString().toLowerCase();
      final contentLower = entry['searchableContent'].toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || contentLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredEntries = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Page Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra di ricerca
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 150),
                child: TextField(
                  onChanged: _filterEntries,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.black54,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              // Lista filtrata
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredEntries.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  filteredEntries[index]['content']),
                        );
                      },
                      child: Container(
                        height: 60,
                        margin: index == 0
                            ? const EdgeInsets.only(top: 16)
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              filteredEntries[index]['icon'],
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              filteredEntries[index]['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GeneralInfoPage extends StatelessWidget {
  const GeneralInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Info')),
      body: Container(
        color: const Color.fromARGB(255, 12, 134, 77), // Colore di sfondo RGB
        width: double.infinity, // Allarga il contenitore a tutta la larghezza della pagina
        height: double.infinity, // Allarga il contenitore a tutta l'altezza della pagina
        padding: const EdgeInsets.all(20.0), // Aggiunge margini interni
        child: const Center( // Centra il contenuto verticalmente e orizzontalmente
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
              crossAxisAlignment: CrossAxisAlignment.center, // Centra orizzontalmente
              children: [
                // Titolo della sezione
                Text(
                  'Happy to have you here!!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Centra il testo
                ),
                SizedBox(height: 8), // Spazio tra il titolo e il contenuto

                // Testo della descrizione
                Text(
                  'Welcome to our event platform, where users can easily create, manage, and participate in various conferences after logging in. Our app offers a wide range of events that span across both scientific and humanistic disciplines. These conferences are designed to educate, inform, and inspire attendees, providing them with the latest updates and knowledge in their fields of interest. Whether you are looking to stay current in your profession or simply expand your horizons, our platform has something for everyone. Join us, connect with like-minded individuals, and take part in the ongoing journey of learning and discovery.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Centra il testo
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      body: Container(
        color: const Color.fromARGB(255, 12, 134, 77), // Colore di sfondo RGB
        width: double.infinity, // Allarga il contenitore a tutta la larghezza della pagina
        height: double.infinity, // Allarga il contenitore a tutta l'altezza della pagina
        padding: const EdgeInsets.all(20.0), // Aggiunge margini interni
        child: const Center( // Centra il contenuto verticalmente e orizzontalmente
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
              crossAxisAlignment: CrossAxisAlignment.center, // Centra orizzontalmente
              children: [
                // Developer Section
                Text(
                  'Developer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Centra il testo
                ),
                SizedBox(height: 8), // Spazio tra il titolo e il contenuto
                Text(
                  'Emanuele Russo\n'
                  'University of Messina\n'
                  'email: rssmnl02s10f158x@studenti.unime.it',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Centra il testo
                ),
                SizedBox(height: 22), // Spazio tra le sezioni

                // Supervisor Section
                Text(
                  'Supervisor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Centra il testo
                ),
                SizedBox(height: 8), // Spazio tra il titolo e il contenuto
                Text(
                  'Prof. Andrea Nucita\n'
                  'Associate Professor\n'
                  'Dipartimento di Scienze Cognitive, Psicologiche, Pedagogiche e degli Studi Culturali\n'
                  'Department of Cognitive Sciences, Psychology,  Education and Cultural Studies (COSPECS)\n'
                  'University of Messina, Italy\n'
                  'email: andrea.nucita@unime.it\n',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Centra il testo
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Container(
        color: const Color.fromARGB(255, 12, 134, 77), // Background color RGB
        width: double.infinity, // Expand container to full width of the page
        height: double.infinity, // Expand container to full height of the page
        padding: const EdgeInsets.all(20.0), // Add padding
        child: const Center( // Center content vertically and horizontally
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                // Question 1
                Text(
                  'How do I participate in a conference?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Space between question and answer
                Text(
                  'Simply log in or register, then on the home page, by pressing on the post you will be automatically signed up for the conference.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 22), // Space between questions

                // Question 2
                Text(
                  'How do I edit a post?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Space between question and answer
                Text(
                  'From your personal account page, you can view the posts you have published and press the three dots at the top left. Once done, you can choose the edits to make.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 22), // Space between questions

                // Question 3
                Text(
                  'How do I search for a specific post?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Space between question and answer
                Text(
                  'From the home page, you can use the search bar to look for keywords that might help you find the event.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 22), // Space between questions

                // Question 4
                Text(
                  'How do I delete my account?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Space between question and answer
                Text(
                  'From your account page, you can press the three dots in the top right corner and choose to delete your account.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 22), // Space between questions

                // Question 5
                Text(
                  'How do I see the conference in which I am subscribed for?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Space between question and answer
                Text(
                  'From your program page, you can see all the conferences you are registered for with time and place with the option to cancelling your registration.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Center the text
                ),

                // Question 6
                Text(
                  'How do I add multiple sessions in a single day?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                SizedBox(height: 8), // Spazio tra la domanda e la risposta
                Text(
                  'From your account page, press the edit icon and then go to modify sessions. From there, you can add more sessions to the selected day.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center, // Centra il testo
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}