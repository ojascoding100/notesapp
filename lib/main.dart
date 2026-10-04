import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notes_provider.dart';
import 'screens/home_screen.dart';
import 'theme/neo_brutalist_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => NotesProvider()..loadNotes(),
      child: const NotesApp(),
    ),
  );
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brain Dumps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: NB.canvas,
        fontFamily: NB.fontBody,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: NB.titleMedium(),
          iconTheme: const IconThemeData(color: NB.textPrimary),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: NB.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(NB.badgeRadius),
            side: const BorderSide(color: NB.borderBlack, width: NB.strokeWidth),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
