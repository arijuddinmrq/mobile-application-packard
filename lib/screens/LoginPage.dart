import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/SingUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import 'siswa/DashboardPage.dart';
import 'dosen/ControlPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  processLogin() async {
    // Proses Login yang akan dijalankan dari dalam fungsi signIn
    // Proses ini ada untuk mengatur role dan nama user yang login
    if (FirebaseAuth.instance.currentUser != null) {
      // Get uid from user
      final uid = FirebaseAuth.instance.currentUser!.uid;
      print(uid);
      // Get user data from realtime database using uid user/$uid
      final db = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (db.exists) {
        // assign nama and role from db to SessionManager()
        final data = db.value as Map;
        await SessionManager().set('nama', data['nama']);
        await SessionManager().set('role', data['status']);
      }
    } else {
      // signed out
    }
  }

  Future<void> signIn(emailAddress, password) async {
   

    await FirebaseAuth.instance.signOut();

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      await Future.delayed(Duration(milliseconds: 500));
      await processLogin();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // snackbar jika tidak terdaftar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User tidak terdaftar'),
          ),
        );
      } else if (e.code == 'wrong-password') {
        // snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password salah'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 100),
                height: 80,
                width: double.infinity,
                child: Text(
                  'Login',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
                ),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  // validator
                  if (_formKey.currentState!.validate()) {
                    // validasi berhasil
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Processing Data'),
                      ),
                    );
                  }

                  await signIn(_emailController.text, _passwordController.text);

                  // firebase auth check if user is signed in
                  if (FirebaseAuth.instance.currentUser != null) {
                    if (await SessionManager().get('role') as int == 0) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const DashboardPage(title: 'Dashboard');
                      }));
                    } else if (await SessionManager().get('role') as int == 1) {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ControlPage(title: 'Control');
                      }));
                    } else {
                      // Snackbar belum implement jika role bukan 0
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dosen belum diimplementasi'),
                        ),
                      );
                    }
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SignUpPage(title: 'SignUp');
                      }));
                      // Navigate to sign up screen here
                    },
                    child: Text('Daftar sini'),
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
