import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF39FF14),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Inventaris & Stok Barang',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      // Tombol untuk menambah barang baru ke database
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _tampilkanDialogTambahBarang(context);
        },
        backgroundColor: const Color(0xFF39FF14),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Barang Baru',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Membaca koleksi 'inventaris' dari Firestore
        stream: FirebaseFirestore.instance
            .collection('inventaris')
            .orderBy('nama_barang')
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
                'Belum ada data barang. Klik tombol + untuk menambah.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;

              String namaBarang = data['nama_barang'] ?? 'Unknown';
              String kategori = data['kategori'] ?? 'Lain-lain';
              int stok = (data['stok'] as num?)?.toInt() ?? 0;

              // Peringatan jika stok habis atau menipis
              Color warnaStok = stok > 5
                  ? const Color(0xFF39FF14)
                  : (stok > 0 ? Colors.orange : Colors.redAccent);

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: warnaStok.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Ikon berdasarkan kategori
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(
                          kategori == 'Minuman'
                              ? Icons.local_drink
                              : (kategori == 'Suplemen'
                                    ? Icons.medication
                                    : Icons.fitness_center),
                          color: warnaStok,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info Barang
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              namaBarang,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kategori,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Pengatur Stok (+ / -)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _ubahStok(doc.id, stok, -1),
                            ),
                            Text(
                              stok.toString(),
                              style: TextStyle(
                                color: warnaStok,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () => _ubahStok(doc.id, stok, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fungsi Logika: Mengurangi atau Menambah Stok di Firebase
  Future<void> _ubahStok(String docId, int stokSekarang, int perubahan) async {
    int stokBaru = stokSekarang + perubahan;
    if (stokBaru < 0) stokBaru = 0; // Stok tidak boleh minus

    await FirebaseFirestore.instance.collection('inventaris').doc(docId).update(
      {'stok': stokBaru},
    );
  }

  // Fungsi Tampilan: Pop-up untuk menambah barang baru
  void _tampilkanDialogTambahBarang(BuildContext context) {
    TextEditingController namaController = TextEditingController();
    TextEditingController stokController = TextEditingController();
    String kategoriPilihan = 'Minuman';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // Agar dropdown bisa berubah state di dalam dialog
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Tambah Barang',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: namaController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nama Barang',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextField(
                    controller: stokController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Stok Awal',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: kategoriPilihan,
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: ['Minuman', 'Suplemen', 'Alat Gym'].map((
                      String kategori,
                    ) {
                      return DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (baru) {
                      if (baru != null) setState(() => kategoriPilihan = baru);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Batal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    if (namaController.text.isNotEmpty &&
                        stokController.text.isNotEmpty) {
                      Navigator.pop(context); // Tutup dialog
                      // Simpan ke Firestore
                      await FirebaseFirestore.instance
                          .collection('inventaris')
                          .add({
                            'nama_barang': namaController.text,
                            'stok': int.tryParse(stokController.text) ?? 0,
                            'kategori': kategoriPilihan,
                          });
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
