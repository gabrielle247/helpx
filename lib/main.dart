import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'pages/landing_page.dart';

void main() async {
  // Ensure Flutter is initialized for async calls
  WidgetsFlutterBinding.ensureInitialized();
  
  // FIX: Firebase MUST be initialized before use
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase Setup Error: $e");
  }
  
  runApp(const HelpXApp());
}

class HelpXApp extends StatelessWidget {
  const HelpXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help X | Batch Tech',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF137FEC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF137FEC),
          secondary: Color(0xFF137FEC),
          surface: Color(0xFF161616),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}