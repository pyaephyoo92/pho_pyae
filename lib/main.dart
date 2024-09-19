import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/Chat.dart';
import 'pages/Profile.dart';
import 'pages/Auth.dart';

final activeSession = Supabase.instance.client.auth.currentSession;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uvhiswovlxbojjncsohr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV2aGlzd292bHhib2pqbmNzb2hyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjU3NzczNjgsImV4cCI6MjA0MTM1MzM2OH0.ogtuukx6CVFnTX7OVU0isxbpQIdek3xby4rZdL5FtrA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const Auth(),
        '/profile': (context) => const Profile(),
        '/chat': (context) => const Chat(),
      },
    );
  }
}
