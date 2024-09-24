import 'package:applicazione_tesi/services/event_session_service.dart';
import 'package:applicazione_tesi/services/notification_service.dart';
import 'package:applicazione_tesi/services/question_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'pages/home_page.dart';
import 'pages/createpost_page.dart';
import 'pages/program_page.dart';
import 'pages/account_page.dart';
import 'pages/more_page.dart';
import 'providers/comments_provider.dart';
import 'providers/users_provider.dart';
import 'providers/posts_provider.dart';
import 'providers/event_session_provider.dart';
import 'services/user_service.dart';
import 'services/post_service.dart';
import 'services/comment_service.dart';
import 'services/event_participation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it', null); 

  final userService = UserService();
  final postService = PostService();
  final commentService = CommentService();
  final eventParticipationService = EventParticipationService();
  final eventSessionService = EventSessionService();
  final notificationService = NotificationService();
  final questionService = QuestionService();

  runApp(
    MultiProvider(
      providers: [
        Provider<NotificationService>(create: (_) => notificationService),
        ChangeNotifierProvider(create: (context) => UserProvider(userService, notificationService)),
        ChangeNotifierProvider(create: (context) => PostsProvider(postService, eventParticipationService, questionService)),
        ChangeNotifierProvider(create: (context) => CommentsProvider(commentService)),
        ChangeNotifierProvider(create: (context) => EventSessionProvider(eventSessionService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 2, 66, 5)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const ProgramPage(),
      const CreatepostPage(),
      const AccountPage(),
      const MorePage(),
    ];

    final List<String> titles = [
      'Home',
      'Program',
      'Event Creation',
      'Account',
      'More',
    ];

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
          Positioned.fill(
            child: pages[_currentPageIndex],
          ),
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Text(
              titles[_currentPageIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black54,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 0;
                      });
                    },
                    color: _currentPageIndex == 0 ? const Color.fromARGB(255, 0, 119, 4) : const Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 1;
                      });
                    },
                    color: _currentPageIndex == 1 ? const Color.fromARGB(255, 0, 119, 4) : const Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 2;
                      });
                    },
                    color: _currentPageIndex == 2 ? const Color.fromARGB(255, 0, 119, 4) : const Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline_sharp),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 3;
                      });
                    },
                    color: _currentPageIndex == 3 ? const Color.fromARGB(255, 0, 119, 4) : const Color.fromARGB(255, 0, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      setState(() {
                        _currentPageIndex = 4;
                      });
                    },
                    color: _currentPageIndex == 4 ? const Color.fromARGB(255, 0, 119, 4) : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
