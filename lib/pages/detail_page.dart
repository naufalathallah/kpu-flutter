import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DetailPage extends StatefulWidget {
  final String nik;
  DetailPage({required this.nik});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Database database;
  Map<String, dynamic> dataPemilih = {};

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = p.join(dir.path, 'pemilih.db');

    database = await openDatabase(path, version: 1);
    loadData();
  }

  Future<void> loadData() async {
    var list = await database
        .rawQuery('SELECT * FROM pemilih WHERE nik = ?', [widget.nik]);

    if (list.isNotEmpty) {
      setState(() {
        dataPemilih = Map<String, dynamic>.from(list.first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pemilih'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0), // Padding around the whole container
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (dataPemilih.isNotEmpty)
                ? Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        detailRow('NIK', dataPemilih['nik']),
                        detailRow('Nama', dataPemilih['nama']),
                        detailRow('HP', dataPemilih['hp']),
                        detailRow(
                            'Jenis Kelamin', dataPemilih['jenis_kelamin']),
                        detailRow('Tanggal Pendataan',
                            dataPemilih['tanggal_pendataan']),
                        detailRow('Alamat', dataPemilih['alamat']),
                        detailRow('Gambar', null),
                        if (dataPemilih['gambar_path'] != null)
                          Image.file(
                            File(dataPemilih['gambar_path']),
                            width: 100,
                            height: 100,
                          ),
                      ],
                    ),
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Vertical padding for each row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text('$label:'),
          ),
          Expanded(
            flex: 3,
            child: Text(value != null ? value.toString() : ''),
          ),
        ],
      ),
    );
  }
}
