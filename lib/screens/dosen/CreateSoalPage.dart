import 'dart:math';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
//import "package:collection/collection.dart";

class CreateSoalPage extends StatefulWidget {
  const CreateSoalPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _CreateSoalPageState createState() => _CreateSoalPageState();
}

class _CreateSoalPageState extends State<CreateSoalPage> {
  // Penjelasan state
  // soal : berisi data soal yang akan ditampilkan
  // Penjelesan functions
  // cekJikaSudahMenjawab() : mengambil data jawaban_ujian dari firebase dan memasukkannya ke state soal
  // submitSoal() : mengirim jawaban_ujian ke firebase
  // initState() : dijalankan ketika class ini diinisialisasi
  // getSoal() : mengambil data soal dari firebase
  final _soalController = TextEditingController();
  final _jawabanController = TextEditingController();
  final _bobotController = TextEditingController();
  List<dynamic> soal = [];
  Map<String, dynamic> soalData = {
    'name': '',
  };
  @override
  void initState() {
    super.initState();
  }

  void submitAssignment() async {
    // snackbar memproses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment sedang diproses'),
      ),
    );
    if (soalData["name"] == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama assignmentnya'),
        ),
      );
      return;
    }
    if (soal.length < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment kosong!!'),
        ),
      );
      return;
    }
    final class_id = await SessionManager().get('id_kelas');
    // generate a random number in range 1000 to 9999
    final random = Random();
    final index = random.nextInt(9999 - 1000) + 1000;
    // loop over createAssignment and push to firebase realtime db on soal_kunci_jawaban

    soal.forEach((item) async {
      await FirebaseDatabase.instance.ref("soal_kunci_jawaban").push().set({
        'index_soal': index,
        'nama': soalData['name'],
        'kelas': class_id,
        'soal': item[0],
        'kunci_jawaban': item[1],
        'skor': int.parse(item[2])
      });
    });

    Navigator.pop(context);

    // snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment berhasil dibuat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Soal'),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  submitAssignment();
                },
              ),
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
                          // Loop through soal
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    TextField(
                                      // bind the textfield to soal['$key']['jawaban']
                                      onChanged: (value) {
                                        setState(() {
                                          soalData["name"] = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'Nama assignment',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                                children: soal
                                    .map((e) => Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    e[0],
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  TextButton(
                                                    child: Text('Delete'),
                                                    onPressed: () {
                                                      setState(() {
                                                        soal.remove(e);
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList())
                          ]),
                    )),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Show a modal to input class code here
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Buat Tugas'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      keyboardType: TextInputType.name,
                      controller: _soalController,
                      decoration: InputDecoration(
                        labelText: 'Soal',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: _jawabanController,
                      decoration: InputDecoration(
                        labelText: 'Jawaban',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _bobotController,
                      decoration: InputDecoration(
                        labelText: 'Bobot',
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
                      setState(() {
                        soal.add([
                          _soalController.text,
                          _jawabanController.text,
                          _bobotController.text
                        ]);
                        _soalController.clear();
                        _jawabanController.clear();
                        _bobotController.clear();
                        Navigator.pop(context);
                      });
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
