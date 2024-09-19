import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final activeSession = Supabase.instance.client.auth.currentSession;

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          Navigator.pushReplacementNamed(context, '/chat');
        });
      });
    } else {
      //
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            Navigator.pushReplacementNamed(context, '/chat');
          });
        });
      } else {
        //
      }
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successful Login !')),
        );
        Navigator.pushReplacementNamed(context, '/chat');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.user!.id)),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected Error: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Successful - Please Check Your Email !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.user!.id)),
        );
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected Error: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (value) {},
                validator: (value) {
                  if (value!.isEmpty ||
                      !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                    return 'Enter a valid Email !';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                keyboardType: TextInputType.text,
                onFieldSubmitted: (value) {},
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter a valid Password !';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        fixedSize: const Size.fromWidth(100),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (!isValid) {
                          return;
                        }
                        _formKey.currentState!.save();
                        _login();
                      },
                      child: const Text("Login"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        fixedSize: const Size.fromWidth(100),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () {
                        final isValid = _formKey.currentState!.validate();
                        if (!isValid) {
                          return;
                        }
                        _formKey.currentState!.save();
                        _signUp();
                      },
                      child: const Text("Sign up"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
