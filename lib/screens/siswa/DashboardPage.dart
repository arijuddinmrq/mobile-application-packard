import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:my_app/screens/siswa/DetailKelas.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  String username = "test";

  final _classCodeController = TextEditingController();
  List<Map<String, String>> classes = [
    {'name': 'Matematika', 'dosen': 'Budi'},
    {'name': 'Bahasa Inggris', 'dosen': 'Susi'},
    {'name': 'Fisika', 'dosen': 'Andi'},
  ];

  // Join kelas
  joinClass() async {
    final all_classes = await FirebaseDatabase.instance.ref("kelas").get();
    String key = "";
    if (all_classes.exists) {
      final data = all_classes.value as Map;
      // parse _classCodeController to int
      final code = int.parse(_classCodeController.text);
      // loop over data and get classes with code == _classCodeController.text
      data.forEach((i, value) {
        if (value["kode"] == code) {
          // if class exists get its key
          key = i;
        }
      });
    }

    final db = await FirebaseDatabase.instance.ref("kelas/$key").get();
    if (db.exists) {
      final data = db.value as Map;
      if (data['list_mahasiswa'] == null) {
        data['list_mahasiswa'] = [];
      }
      // check if user already joined
      if (data['list_mahasiswa']
          .contains(FirebaseAuth.instance.currentUser!.uid)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anda sudah bergabung di kelas ini'),
          ),
        );
        return;
      }
      data['id_kelas'] = key;
      List daata = List.of(data['list_mahasiswa']);
      daata.add(FirebaseAuth.instance.currentUser!.uid);
      await FirebaseDatabase.instance
          .ref("kelas/$key/list_mahasiswa")
          .set(daata);
      getAllClass();
    }
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
      // loop over data and check if list_mahasiswa includes user's uid
      data.forEach((i, value) {
        if (value['list_mahasiswa'] != null) {
          if (value['list_mahasiswa']
              .contains(FirebaseAuth.instance.currentUser!.uid)) {
            setState(() {
              classes.add({
                'id_kelas': i,
                'name': value['nama'],
                'dosen': dosen[value['id_dosen']]['nama'],
                'jumlah': value['list_mahasiswa'].length.toString(),
                'desc': value['deskripsi'],
                'kode': i,
              });
            });
          }
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
        title: const Text('Dashboard Mahasiswa'),
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
            Card(
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
                      'Classes',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              await SessionManager()
                                  .set('id_kelas', classes[index]['id_kelas']);
                              await SessionManager()
                                  .set('nama', classes[index]['name']);
                              await SessionManager()
                                  .set('dosen', classes[index]['dosen']);
                              await SessionManager()
                                  .set('desc', classes[index]['desc']);
                              await SessionManager()
                                  .set('jumlah', classes[index]['jumlah']);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const DetailKelas(title: 'Kelas');
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      Text('Belum masuk kelas', style: TextStyle(fontSize: 18)),
                  ],
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
                title: Text('Masuk Kelas'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  controller: _classCodeController,
                  decoration: InputDecoration(
                    labelText: 'Kode Kelas',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: Text('Masuk'),
                    onPressed: () {
                      // Perform add class logic here
                      joinClass();
                      Navigator.pop(context);
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
