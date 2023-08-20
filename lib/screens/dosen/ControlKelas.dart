import 'dart:io';
import 'dart:math';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import "package:collection/collection.dart";
import 'package:my_app/screens/dosen/CreateSoalPage.dart';

class ControlKelas extends StatefulWidget {
  const ControlKelas({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _ControlKelasState createState() => _ControlKelasState();
}

class _ControlKelasState extends State<ControlKelas> {

  final _createAssignmentController = TextEditingController();
  String buttonTest = "Pilih Soal";
  List createAssignment = [];
  Map<String, dynamic> classData = {
    'name': 'Matematika',
    'dosen': 'Budi',
    'description': 'Kelas matematika untuk mahasiswa baru',
    'jumlah': '0',
    'kode': '1234',
    'assignments': [
      {'title': 'Assignment 1', 'dueDate': '2021-12-31'},
      {'title': 'Assignment 2', 'dueDate': '2022-01-15'},
      {'title': 'Assignment 3', 'dueDate': '2022-01-31'},
    ],
  };

  void getAssignments() async {
    print("hullo");
    setState(() {
      classData['assignments'] = [];
    });
    final class_id = await SessionManager().get('id_kelas');
    final list_soal =
        await FirebaseDatabase.instance.ref("soal_kunci_jawaban").get();
    final data = list_soal.value as Map;

    // filter data so that it only includes items which contains id_kelas == class_id
    final filtered_data =
        data.values.where((item) => item['kelas'] == class_id).toList();

    // group items in filtered_data by index
    final grouped_data = groupBy(filtered_data, (item) => item['index_soal']);
    print(filtered_data);
    // loop and assign items of grouped_data to classData.assignments
    grouped_data.forEach((key, value) {
      final item = value[0];
      setState(() {
        classData['assignments'].add({
          'index_soal': item['index_soal'],
          'title': item['nama'],
          'dueDate': '',
        });
      });
    });
  }

  void submitAssignment() async {
    // snackbar memproses
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment sedang diproses'),
      ),
    );
    final class_id = await SessionManager().get('id_kelas');
    // generate a random number in range 1000 to 9999
    final random = Random();
    final index = random.nextInt(9999 - 1000) + 1000;
    print(createAssignment);
    // loop over createAssignment and push to firebase realtime db on soal_kunci_jawaban

    createAssignment.forEach((item) async {
      await FirebaseDatabase.instance.ref("soal_kunci_jawaban").push().set({
        'index_soal': index,
        'nama': _createAssignmentController.text,
        'kelas': class_id,
        'soal': item[0],
        'kunci_jawaban': item[1],
        'skor': item[2]
      });
    });

    // clear assignments
    getAssignments();
    Navigator.pop(context);

    // snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assignment berhasil dibuat'),
      ),
    );
  }

  void initializeClass() async {
    final nama = await SessionManager().get('nama');
    final dosen = await SessionManager().get('dosen');
    final desc = await SessionManager().get('desc');
    final jumlah = await SessionManager().get('jumlah');
    final kode = await SessionManager().get('kode');
    setState(() {
      classData['name'] = nama;
      classData['dosen'] = dosen;
      classData['description'] = desc;
      classData['jumlah'] = jumlah;
      classData['kode'] = kode;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeClass();
    getAssignments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // A card that shows the class information
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
                      // The class name
                      Text(
                        classData['name'],
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      // The dosen name
                      Text(
                        'Dosen: ${classData['dosen']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8.0),
                      // The total amount of Mahasiswa in the class
                      Text(
                        'Mahasiswa: ${classData['jumlah']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8.0),

                      Text(
                        'Kode Kelas: ${classData['kode']}',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 8.0),
                      // The class description
                      Text(
                        classData['description'],
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // A card that shows the list of assignments
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
                    // The title of the card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Assignments',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () async {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const CreateSoalPage(title: 'Soal');
                            }));
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // The assignment title
                                  Text("+", style: TextStyle(fontSize: 18)),
                                  // The assignment due date
                                  Text("", style: TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 8.0),
                    // If there are some assignments, show them in a list view
                    if (classData['assignments'].isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: classData['assignments'].length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {

                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // The assignment title
                                    Text(
                                        classData['assignments'][index]
                                            ['title']!,
                                        style: TextStyle(fontSize: 18)),
                                    // The assignment due date
                                    Text(
                                        classData['assignments'][index]
                                            ['dueDate']!,
                                        style: TextStyle(fontSize: 18)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      )
                    // If there are no assignments, show a message
                    else
                      Text('No assignments', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                      controller: _createAssignmentController,
                      decoration: InputDecoration(
                        labelText: 'Nama Tugas',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    // csv file input
                    SizedBox(height: 8.0),
                    // button to pick soal
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['csv'],
                        );
                        if (result != null) {
                          final file = File(result.files.single.path!);
                          final csv = await file.readAsString();
                          final data = const CsvToListConverter().convert(csv);

                          // remove first index of data
                          data.removeAt(0);

                          setState(() {
                            createAssignment = data;
                          });

                          // check if file is empty
                          if (createAssignment.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('File soal kosong'),
                              ),
                            );
                            return;
                          }
                          // check if file has 3 columns (soal, jawaban, kunci)
                          if (createAssignment[0].length != 3) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'File soal harus memiliki 3 kolom (soal, jawaban, kunci)'),
                              ),
                            );
                            return;
                          }

                          // Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Soal berhasil dipilih'),
                            ),
                          );

                          // change button text
                          setState(() {
                            buttonTest = "Ganti Soal";
                          });
                        }
                      },
                      child: Text(buttonTest),
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
                      submitAssignment();
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
