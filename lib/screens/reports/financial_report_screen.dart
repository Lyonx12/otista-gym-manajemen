import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialReportScreen extends StatelessWidget {
  const FinancialReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFF39FF14)),
        title: const Text(
          'Laporan Pendapatan',
          style: TextStyle(color: Color(0xFF39FF14)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Mengambil SEMUA transaksi dari collectionGroup (fitur canggih Firebase)
        stream: FirebaseFirestore.instance
            .collectionGroup('riwayat_transaksi')
            .orderBy('tanggal_booking', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39FF14)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data transaksi.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Menghitung total pendapatan (Hanya yang statusnya 'LUNAS' atau 'AKTIF')
          int totalPendapatan = 0;
          List<QueryDocumentSnapshot> transaksiLunas = [];

          for (var doc in snapshot.data!.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            String status = (data['status'] ?? '').toString().toLowerCase();

            // Asumsi: jika status mengandung kata lunas/selesai/aktif, berarti uang sudah masuk
            if (status.contains('lunas') ||
                status.contains('selesai') ||
                status.contains('aktif')) {
              transaksiLunas.add(doc);

              // Konversi aman agar tidak crash jika data harganya berbentuk String atau double
              var hargaRaw = data['harga'] ?? 0;
              int hargaFix = (hargaRaw is num)
                  ? hargaRaw.toInt()
                  : int.tryParse(hargaRaw.toString()) ?? 0;

              totalPendapatan += hargaFix;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Kartu Total Pendapatan
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF39FF14).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF39FF14), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PENDAPATAN',
                      style: TextStyle(color: Colors.grey, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${formatRupiah(totalPendapatan)}', // Menggunakan format rupiah
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF39FF14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${transaksiLunas.length} Transaksi Selesai',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Riwayat Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Menampilkan daftar transaksi yang sukses
              ...transaksiLunas.map((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String namaPaket = data['nama_paket'] ?? 'Paket Unknown';

                String tanggal = '-';
                if (data['tanggal_booking'] != null) {
                  DateTime dt = (data['tanggal_booking'] as Timestamp).toDate();
                  tanggal = '${dt.day}/${dt.month}/${dt.year}';
                }

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF39FF14),
                      child: Icon(Icons.check, color: Colors.black),
                    ),
                    title: Text(
                      namaPaket,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      tanggal,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Text(
                      'LUNAS',
                      style: TextStyle(
                        color: Color(0xFF39FF14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // Fungsi utilitas untuk memformat angka menjadi format ribuan
  String formatRupiah(int angka) {
    String angkaStr = angka.toString();
    String hasil = '';
    int hitung = 0;
    for (int i = angkaStr.length - 1; i >= 0; i--) {
      hasil = angkaStr[i] + hasil;
      hitung++;
      if (hitung % 3 == 0 && i != 0) {
        hasil = '.$hasil';
      }
    }
    return hasil;
  }
}
