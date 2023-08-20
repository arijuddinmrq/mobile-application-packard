import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:my_app/screens/dosen/ControlKelas.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  // Penjelasan state
  // username: nama pengguna
  // _classCodeController: controller untuk input kode kelas
  // classes: list kelas yang diikuti oleh pengguna
  // Penjelasan function
  // buatKelas: membuat kelas baru
  // getAllClass: mendapatkan semua kelas yang diikuti oleh pengguna

  String username = "test";

  final _createClassController = TextEditingController();
  final _createDescController = TextEditingController();
  List<Map<String, String>> classes = [];

  buatKelas() async {
    final db = FirebaseDatabase.instance.ref("kelas");
    final id = db.push().key;
    // generate a random four number unique code for joining class
    final uniqueCode = Random().nextInt(9000) + 1000;

    final data = {
      'id_kelas': id,
      'nama': _createClassController.text,
      'deskripsi': _createDescController.text,
      'id_dosen': FirebaseAuth.instance.currentUser!.uid,
      'kode': uniqueCode,
    };
    await db.child(id!).set(data);
    // snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kelas berhasil dibuat'),
      ),
    );
    Navigator.pop(context);
    getAllClass();
  }

  getAllClass() async {
    setState(() {
      classes = [];
    });
    // Get all class that have been joined by the user
    final db = await FirebaseDatabase.instance.ref("kelas").get();
    final guru = await FirebaseDatabase.instance.ref("users").get();
    if (db.exists && guru.exists) {
      final data = db.value as Map;
      final dosen = guru.value as Map;
      print(data);
      data.forEach((i, value) {
        print(i);
        if (value['id_dosen'] == FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            classes.add({
              'id_kelas': i,
              'name': value['nama'],
              'dosen': dosen[value['id_dosen']]['nama'],
              'jumlah': value['list_mahasiswa'] ==
                      null // Jika tidak ada mahasiswa maka jumlah 0
                  ? '0'
                  : value['list_mahasiswa'].length.toString(),
              'desc': value['deskripsi'],
              'kk': value['kode'].toString(),
              'kode': i,
            });
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Get all class that have been joined by the user
    getAllClass();
    // Check if the user has signed in or not using flutter_session_manager
    SessionManager().get('nama').then((value) {
      setState(() {
        username = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard DOSEN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // A banner for notification or updates
            const SizedBox(height: 16.0),
            // A welcome text with the user name
            Text(
              'Selamat Datang! $username!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // A card that lists the class the user joins
            Container(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kelas yang anda pegang',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      // If the user has joined some classes, show them in a grid view
                      if (classes.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: classes.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () async {
                                await SessionManager().set(
                                    'id_kelas', classes[index]['id_kelas']);
                                await SessionManager()
                                    .set('nama', classes[index]['name']);
                                await SessionManager()
                                    .set('dosen', classes[index]['dosen']);
                                await SessionManager()
                                    .set('desc', classes[index]['desc']);
                                await SessionManager()
                                    .set('jumlah', classes[index]['jumlah']);
                                await SessionManager()
                                    .set('kode', classes[index]['kk']);
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ControlKelas(title: 'Kelas');
                                }));
                                // Navigate to class detail page here
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(classes[index]['name']!,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text(classes[index]['dosen']!,
                                          style: const TextStyle(fontSize: 18)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      // If the user has not joined any classes, show a message
                      else
                        Text('Kosong', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // A floating action button to add new class
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Show a modal to input class code here
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Buat Kelas'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.name,
                      controller: _createClassController,
                      decoration: InputDecoration(
                        labelText: 'Nama Kelas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _createDescController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Desc Kelas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text('Buat'),
                    onPressed: () {
                      buatKelas();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
