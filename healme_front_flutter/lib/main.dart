// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: MaterialApp(
        title: 'HealMe - Mental Health App',
        theme: ThemeData(
          fontFamily: "Montserrat",
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0A12),
          colorScheme: ColorScheme.dark(
            primary: Color(0xFFFF64FF),
            secondary: Color(0xFF64C8FF),
            tertiary: Color(0xFFB450DC),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1A1A2E),
            selectedItemColor: Color(0xFFFF64FF),
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: FutureBuilder(
          future: AuthService().getUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.hasData ? HomePage() : LoginPage();
            }
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}