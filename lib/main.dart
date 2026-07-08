import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dam_provider.dart';
import 'views/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DamProvider())],
      child: MaterialApp(
        title: 'Tamil Nadu Dam Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0288D1),
            brightness: Brightness.light,
            primary: const Color(0xFF0288D1),
            secondary: const Color(0xFF00B0FF),
            surface: const Color(0xFFF1F5F9), // Slate 100 for card surfaces
            background: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black87),
            titleTextStyle: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFFF8FAFC), // Slate 50 for sub-cards
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
