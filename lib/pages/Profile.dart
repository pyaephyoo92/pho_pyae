import 'package:flutter/material.dart';
import 'package:pho_pyae/pages/Auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successful Sign out !')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected Error: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final email = user?.userMetadata?['email'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Auth()),
                (Route<dynamic> route) => false,
              );
              //Navigator.pushReplacementNamed(context, '/');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileImageUrl != null)
              ClipOval(
                child: Image.network(
                  profileImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            if (profileImageUrl == null)
              ClipOval(
                child: Image.asset(
                  'assets/images/img.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              email ?? 'blahblah@gmail.com',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
