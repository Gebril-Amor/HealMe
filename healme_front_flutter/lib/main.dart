// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healme_front_flutter/firebase_options.dart';
import 'package:healme_front_flutter/pages/journal_tracker_page.dart';
import 'package:healme_front_flutter/pages/mood_tracker_page.dart';
import 'package:healme_front_flutter/pages/sleep_tracker_page.dart';
import 'package:healme_front_flutter/pages/therapist_list_page.dart';
import 'package:healme_front_flutter/splash_screen.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();  

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }      
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'HealMe - Mental Health App',
        debugShowCheckedModeBanner: false,

       
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => LoginPage(),
          '/home': (_) => HomePage(),
          '/mood': (_) => MoodTrackerPage(),
          '/sleep': (_) => SleepTrackerPage(),
          '/therapists': (_) => TherapistListPage(),
          '/journal': (_) => JournalTrackerPage(),
        },

        theme: ThemeData(
          fontFamily: "Montserrat",
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A12),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF64FF),
            secondary: Color(0xFF64C8FF),
            tertiary: Color(0xFFB450DC),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            selectedItemColor: Color(0xFFFF64FF),
            unselectedItemColor: Colors.grey,
          ),
        ),
      ),
    );
  }
}
