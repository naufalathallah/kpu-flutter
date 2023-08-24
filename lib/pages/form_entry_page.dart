import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'detail_page.dart';
import 'view_info_page.dart';

class FormEntryPage extends StatefulWidget {
  @override
  _FormEntryPageState createState() => _FormEntryPageState();
}

class _FormEntryPageState extends State<FormEntryPage> {
  TextEditingController nikController = TextEditingController();
  TextEditingController namaController = TextEditingController();
  TextEditingController hpController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  String jenisKelamin = 'Laki-Laki';
  DateTime selectedDate = DateTime.now();
  String alamat = '';
  Position? currentPosition;
  File? imageFile;

  // Inisialisasi database
  late Database database;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = p.join(dir.path, 'pemilih.db');
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pemilih (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nik TEXT,
            nama TEXT,
            hp TEXT,
            jenis_kelamin TEXT,
            tanggal_pendataan TEXT,
            alamat TEXT,
            latitude TEXT,
            longitude TEXT,
            gambar_path TEXT
          )
        ''');
      },
    );
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  void _showChoiceDialog() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text('Pick from gallery'),
                      onTap: () {
                        _getFileFromDevice();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text('Take a photo'),
                    onTap: () {
                      _getImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> saveData() async {
    // Cek apakah NIK sudah ada di database
    List<Map> list = await database
        .rawQuery('SELECT * FROM pemilih WHERE nik = ?', [nikController.text]);

    if (list.length > 0) {
      // NIK sudah ada, pindah ke halaman detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(nik: nikController.text),
        ),
      );
    } else {
      if (nikController.text.isNotEmpty &&
          namaController.text.isNotEmpty &&
          hpController.text.isNotEmpty &&
          alamat.isNotEmpty) {
        await database.transaction((txn) async {
          await txn.rawInsert('''
          INSERT INTO pemilih(
            nik, nama, hp, jenis_kelamin, tanggal_pendataan,
            alamat, latitude, longitude, gambar_path)
          VALUES(
            ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', [
            nikController.text,
            namaController.text,
            hpController.text,
            jenisKelamin,
            selectedDate.toLocal().toString(),
            alamat,
            currentPosition?.latitude.toString(),
            currentPosition?.longitude.toString(),
            imageFile?.path,
          ]);

          // Menampilkan snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil menyimpan data'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewInfoPage(),
            ),
          );
        });
      } else {
        // Tampilkan pesan bahwa semua field wajib diisi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Semua field wajib diisi!'),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = position;
      alamat =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      alamatController.text = alamat; // Mengisi field Alamat dengan data lokasi
    });
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      // Meminta izin
      status = await Permission.location.request();
    }

    if (status.isDenied) {
      // Tampilkan dialog atau snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aplikasi ini membutuhkan izin lokasi'),
        ),
      );
    }

    if (status.isGranted) {
      // Izin diberikan, lanjutkan mendapatkan lokasi
      _getCurrentLocation();
    }
  }

  Future<void> _getFileFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) // Cek null
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Entri Data Calon Pemilih'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildRow("NIK", nikController, inputFormatters: [
              LengthLimitingTextInputFormatter(16),
              FilteringTextInputFormatter.digitsOnly
            ]),
            buildRow("Nama Lengkap", namaController),
            buildRow("Nomor Handphone", hpController, inputFormatters: [
              LengthLimitingTextInputFormatter(13),
              FilteringTextInputFormatter.digitsOnly
            ]),
            Row(
              children: [
                SizedBox(width: 150, child: Text("Jenis Kelamin")),
                DropdownButton<String>(
                  value: jenisKelamin,
                  items: ['Laki-Laki', 'Perempuan'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      jenisKelamin = newValue!;
                    });
                  },
                ),
              ],
            ),
            buildRow(
                "Tanggal Pendataan",
                TextEditingController(
                    text: "${selectedDate.toLocal().toString().split(' ')[0]}"),
                isEditable: false,
                onTap: () => _selectDate(context),
                textStyle: TextStyle(color: Colors.black)),
            Row(
              children: [
                SizedBox(width: 150, child: Text("Alamat")),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // agar tombolnya memanjang
                    children: [
                      TextFormField(
                          controller: alamatController,
                          enabled: false,
                          style: TextStyle(color: Colors.black)),
                      ElevatedButton(
                        onPressed: _getCurrentLocation,
                        child: Text('Cek Lokasi'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Menjaga jarak antara elemen-elemen di Row
              children: [
                SizedBox(width: 150, child: Text("Gambar")),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // agar tombolnya memanjang
                    children: [
                      ElevatedButton(
                        onPressed: _showChoiceDialog,
                        child: Text('Pilih Gambar atau Foto'),
                      ),
                      if (imageFile != null)
                        Image.file(
                          imageFile!,
                          width: 50, // ukuran gambar dikecilkan
                          height: 50,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                saveData();
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Row buildRow(String label, TextEditingController controller,
      {bool isEditable = true,
      VoidCallback? onTap,
      TextStyle? textStyle,
      List<TextInputFormatter>? inputFormatters}) {
    return Row(
      children: [
        SizedBox(width: 150, child: Text("$label")),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              absorbing: !isEditable,
              child: TextFormField(
                controller: controller,
                enabled: isEditable,
                style: textStyle,
                keyboardType:
                    inputFormatters != null ? TextInputType.number : null,
                inputFormatters: inputFormatters,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
