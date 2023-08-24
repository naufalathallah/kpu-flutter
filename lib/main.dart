import 'package:flutter/material.dart';
import 'dart:io';

import 'pages/info_pemilu_page.dart';
import 'pages/form_entry_page.dart';
import 'pages/view_info_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Pendataan KPU'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Informasi Pemilihan Umum'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InfoPemiluPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Form Entri Data Calon Pemilih'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormEntryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.view_list),
            title: Text('Melihat Informasi yang Sudah Dimasukkan'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewInfoPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Keluar'),
            onTap: () {
              exit(0);
            },
          ),
        ],
      ),
    );
  }
}
