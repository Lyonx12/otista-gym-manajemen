import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  // Status filter awal: menampilkan semua data
  String _filterWaktu = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF39FF14),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Riwayat & Laporan Maintenance',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // PANEL KONTROL OWNER: DROPDOWN FILTER OTOMATIS
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arsip Laporan WA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pilih periode riwayat kerusakan:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                // Dropdown Filter
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF39FF14),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _filterWaktu,
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(
                      color: Color(0xFF39FF14),
                      fontWeight: FontWeight.bold,
                    ),
                    underline:
                        const SizedBox(), // Menghilangkan garis bawah bawaan
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua',
                        child: Text('Semua Riwayat'),
                      ),
                      DropdownMenuItem(
                        value: '1 Bulan',
                        child: Text('1 Bulan Terakhir'),
                      ),
                      DropdownMenuItem(
                        value: '1 Tahun',
                        child: Text('1 Tahun Terakhir'),
                      ),
                    ],
                    onChanged: (String? nilaiBaru) {
                      if (nilaiBaru != null) {
                        setState(() {
                          _filterWaktu =
                              nilaiBaru; // Otomatis trigger refresh layar
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // DAFTAR LAPORAN YANG SUDAH TERFILTER AUTOMATIS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pengaduan')
                  .orderBy('tanggal', descending: true)
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
                      'Belum ada riwayat maintenance masuk.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // --- PROSES PENYARINGAN (FILTERING) OTOMATIS ---
                DateTime sekarang = DateTime.now();
                List<QueryDocumentSnapshot>
                daftarTerfilter = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  if (data['tanggal'] == null) return _filterWaktu == 'Semua';

                  DateTime tanggalLaporan = (data['tanggal'] as Timestamp)
                      .toDate();

                  if (_filterWaktu == '1 Bulan') {
                    // Hanya ambil data yang selisihnya kurang dari atau sama dengan 30 hari
                    return sekarang.difference(tanggalLaporan).inDays <= 30;
                  } else if (_filterWaktu == '1 Tahun') {
                    // Hanya ambil data yang selisihnya kurang dari atau sama dengan 365 hari
                    return sekarang.difference(tanggalLaporan).inDays <= 365;
                  }
                  return true; // Jika 'Semua', loloskan semua data
                }).toList();

                if (daftarTerfilter.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada riwayat laporan dalam $_filterWaktu terakhir.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daftarTerfilter.length,
                  itemBuilder: (context, index) {
                    var doc = daftarTerfilter[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String pelapor = data['pelapor'] ?? 'Staf (WA)';
                    String deskripsi =
                        data['deskripsi'] ?? 'Tidak ada deskripsi';
                    String kategori = data['kategori'] ?? 'Alat Gym';
                    String status = data['status'] ?? 'Menunggu';
                    bool adaFoto =
                        data.containsKey('foto_url') && data['foto_url'] != '';

                    String tanggalStr = '-';
                    if (data['tanggal'] != null) {
                      DateTime dt = (data['tanggal'] as Timestamp).toDate();
                      tanggalStr = '${dt.day}/${dt.month}/${dt.year}';
                    }

                    Color warnaStatus = status == 'Selesai'
                        ? const Color(0xFF39FF14)
                        : (status == 'Diproses'
                              ? Colors.blueAccent
                              : Colors.redAccent);

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade800, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      kategori.toLowerCase().contains(
                                            'fasilitas',
                                          )
                                          ? Icons.domain
                                          : Icons.fitness_center,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      kategori,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: warnaStatus.withValues(alpha: 0.1),
                                    border: Border.all(color: warnaStatus),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: warnaStatus,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  child: adaFoto
                                      ? const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                          size: 40,
                                        )
                                      : const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.no_photography,
                                              color: Colors.grey,
                                              size: 24,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'No Image',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        deskripsi,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Sumber: $pelapor',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Tanggal: $tanggalStr',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (status != 'Selesai')
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status == 'Menunggu')
                                    OutlinedButton(
                                      onPressed: () => FirebaseFirestore
                                          .instance
                                          .collection('pengaduan')
                                          .doc(doc.id)
                                          .update({'status': 'Diproses'}),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blueAccent,
                                        side: const BorderSide(
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      child: const Text('Proses'),
                                    ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () => FirebaseFirestore.instance
                                        .collection('pengaduan')
                                        .doc(doc.id)
                                        .update({'status': 'Selesai'}),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF39FF14),
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text('Selesai'),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
