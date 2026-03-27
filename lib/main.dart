import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation.dart';
import 'services/search_service.dart';
import 'services/torrent_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchService()),
        ChangeNotifierProvider(create: (_) => TorrentService()),
      ],
      child: const TorrDroidApp(),
    ),
  );
}

class TorrDroidApp extends StatelessWidget {
  const TorrDroidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TorrDroid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
          primary: Colors.teal,
          onPrimary: Colors.white,
          secondary: Colors.amber,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainNavigation(),
    );
  }
}
