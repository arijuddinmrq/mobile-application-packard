import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import "package:collection/collection.dart";
import 'package:my_app/screens/siswa/SoalPage.dart';

class DetailKelas extends StatefulWidget {
  const DetailKelas({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _DetailKelasState createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  // Penjelasan state
  // classData : berisi data kelas yang akan ditampilkan
  // classData['assignments'] : berisi data assignment yang akan ditampilkan
  // Penjelasan functions
  // getAssignments() : mengambil data assignment dari firebase
  // initializeClass() : mengambil data kelas dari session manager
  // initState() : dijalankan ketika class ini diinisialisasi

  Map<String, dynamic> classData = {
    'name': 'Matematika',
    'dosen': 'Budi',
    'description': 'Kelas matematika untuk mahasiswa baru',
    'jumlah': '0',
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

  void initializeClass() async {
    final nama = await SessionManager().get('nama');
    final dosen = await SessionManager().get('dosen');
    final desc = await SessionManager().get('desc');
    final jumlah = await SessionManager().get('jumlah');
    setState(() {
      classData['name'] = nama;
      classData['dosen'] = dosen;
      classData['description'] = desc;
      classData['jumlah'] = jumlah;
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
                    Text('Assignments',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
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
                              await SessionManager().set(
                                  'index_soal',
                                  classData['assignments'][index]
                                      ['index_soal']);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const SoalPage(title: 'Soal');
                              }));
                              // Navigate to assignment detail page here
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
    );
  }
}
