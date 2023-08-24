import 'package:flutter/material.dart';

class InfoPemiluPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informasi Pemilihan Umum 2024'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pemilihan Umum 2024',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Pemilihan Umum (Pemilu) 2024 adalah pemilu yang akan diselenggarakan di Indonesia. Pada Pemilu ini, masyarakat akan memilih Presiden dan Wakil Presiden, serta anggota legislatif.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Tanggal Pelaksanaan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '5 April 2024',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Syarat Mengikuti Pemilu:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. NIK\n2. Nama lengkap\n3. Nomor Handphone\n4. Jenis kelamin\n5. Tanggal pendataan\n6. Lokasi / alamat rumah\n7. Gambar proses pendataan',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
