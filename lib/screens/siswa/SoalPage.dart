import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
//import "package:collection/collection.dart";

class SoalPage extends StatefulWidget {
  const SoalPage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _SoalPageState createState() => _SoalPageState();
}

class _SoalPageState extends State<SoalPage> {

  Map<String, dynamic> soal = {
    'soal1': {'id_soal': '1', 'soal': 'Testual', 'skor': '0', 'bobot': '10'},
    'soal2': {'id_soal': '2', 'soal': 'Testual', 'skor': null, 'bobot': '10'}
  };

  cekJikaSudahMenjawab() async {
    // get jawaban_ujian from firebase
    final list_jawaban =
        await FirebaseDatabase.instance.ref("jawaban_ujian").get();
    final data = list_jawaban.value as Map;

    // firebase auth get current user id
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // filter jawaban ujian dimana memiliki child nim dengan value uid user ini
    final filtered_jawaban =
        data.values.where((item) => item['nim'] == uid).toList().asMap();

    // iterate dan filter jawaban agar hanya overlap dengan soal yang ada
    filtered_jawaban.forEach((key, value) {
      if (soal.containsKey(value['index_soal'])) {
        setState(() {
          soal['${value['index_soal']}']['skor'] = value['skor'];
          soal['${value['index_soal']}']['jawaban'] = value['jawaban'];
        });
      }
    });
  }

  submitSoal() async {
    // firebase auth get current user id
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // push to jawaban_ujian
    soal.forEach((key, value) async {
      final jawaban = value['jawaban'];
      final index_soal = value["id_soal"];
      final data = {
        'index_soal': index_soal,
        'jawaban': jawaban,
        'skor': 0,
        'nim': uid,
      };
      await FirebaseDatabase.instance.ref("jawaban_ujian").push().set(data);
    });
    // snackbar and redirect
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jawaban berhasil dikirim'),
      ),
    );
    Navigator.pop(context);
  }

  getSoal() async {
    // clear soal
    setState(() {
      soal = {};
    });
    // get soal_kunci_jawaban from firebase
    final list_soal =
        await FirebaseDatabase.instance.ref("soal_kunci_jawaban").get();
    final data = list_soal.value as Map;
    final id_soal = await SessionManager().get('index_soal');
    // Itreate data dimana memiliki child index dengan value SessionManager().get('index') namun key tetap sama
    data.forEach((key, value) {
      if (value['index_soal'] == id_soal) {
        setState(() {
          soal['$key'] = {
            'id_soal': key,
            'soal': value['soal'],
            'bobot': value['skor'],
          };
        });
      }
    });

    cekJikaSudahMenjawab();
  }

  @override
  void initState() {
    super.initState();
    getSoal();
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
                          children: soal.entries
                              .map((e) => Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            e.value['soal'],
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 16.0),
                                          Text(
                                            e.value['skor'] != null
                                                ? 'Nilai: ${e.value['skor']}/${e.value['bobot']}'
                                                : 'Nilai: -',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 16.0),
                                          TextField(
                                            // bind the textfield to soal['$key']['jawaban']
                                            onChanged: (value) {
                                              setState(() {
                                                soal['${e.key}']['jawaban'] =
                                                    value;
                                              });
                                            },

                                            // default value is soal['$key']['jawaban'] and uneditable if nilai is not null, else do not add controller
                                            controller: e.value['skor'] != null
                                                ? TextEditingController(
                                                    text: e.value['jawaban'])
                                                : null,
                                            enabled: e.value['skor'] == null,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Jawaban',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList()),
                    )),
              ),

              //a banner if all soal['skor'] is not null (berisikan tulisan: Anda sudah mengerjakan soal ini)
              if (soal.values.every((element) => element['skor'] != null))
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
                          children: [
                            Text(
                              'Anda sudah mengerjakan soal ini',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                ),
              // else all soal['skor'] is null (berisikan button submit)
              if (soal.values.every((element) => element['skor'] == null))
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
                          children: [
                            SizedBox(height: 16.0),
                            ElevatedButton(
                              onPressed: () {
                                // print all soal['jawaban']
                                submitSoal();
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        ),
                      )),
                ),
            ],
          )),
    );
  }
}
