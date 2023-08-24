import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

class ViewInfoPage extends StatefulWidget {
  @override
  _ViewInfoPageState createState() => _ViewInfoPageState();
}

class _ViewInfoPageState extends State<ViewInfoPage> {
  late Database database;
  List<Map<String, dynamic>>? userList;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = join(dir.path, 'pemilih.db');
    database = await openDatabase(path);
    loadData();
  }

  Future<void> loadData() async {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(
        await database.rawQuery('SELECT * FROM pemilih'));

    setState(() {
      userList = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Melihat Informasi yang Sudah Dimasukkan'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: userList != null
              ? DataTable(
                  columns: const [
                    DataColumn(label: Text('No.')),
                    DataColumn(label: Text('NIK')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('HP')),
                    DataColumn(label: Text('Jenis Kelamin')),
                    DataColumn(label: Text('Tanggal Pendataan')),
                    DataColumn(label: Text('Alamat')),
                    DataColumn(label: Text('Gambar')),
                  ],
                  rows: List<DataRow>.generate(
                    userList!.length,
                    (index) => DataRow(cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Text(userList![index]['nik'].toString())),
                      DataCell(Text(userList![index]['nama'].toString())),
                      DataCell(Text(userList![index]['hp'].toString())),
                      DataCell(
                          Text(userList![index]['jenis_kelamin'].toString())),
                      DataCell(Text(
                          userList![index]['tanggal_pendataan'].toString())),
                      DataCell(Text(userList![index]['alamat'].toString())),
                      DataCell(userList![index]['gambar_path'] != null
                          ? Image.file(
                              File(userList![index]['gambar_path'].toString()),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Text('No image')),
                    ]),
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
