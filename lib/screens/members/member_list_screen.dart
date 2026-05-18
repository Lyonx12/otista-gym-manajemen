import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  String keywordCari = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFF39FF14)),
        title: const Text(
          'Data Pelanggan (Manual)',
          style: TextStyle(
            color: Color(0xFF39FF14),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Kolom Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email pelanggan...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF39FF14)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF39FF14)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  keywordCari = value.toLowerCase();
                });
              },
            ),
          ),

          // Daftar Pelanggan dari Firestore
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
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
                      'Belum ada data pelanggan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Filter data berdasarkan ketikan resepsionis
                var daftarPelanggan = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String nama = (data['nama_lengkap'] ?? '')
                      .toString()
                      .toLowerCase();
                  String email = (data['email'] ?? '').toString().toLowerCase();
                  return nama.contains(keywordCari) ||
                      email.contains(keywordCari);
                }).toList();

                if (daftarPelanggan.isEmpty) {
                  return const Center(
                    child: Text(
                      'Pelanggan tidak ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: daftarPelanggan.length,
                  itemBuilder: (context, index) {
                    var data =
                        daftarPelanggan[index].data() as Map<String, dynamic>;

                    // --- PERBAIKAN DI SINI ---
                    // Kita ubah apapun bentuk datanya (bool atau teks) menjadi String dengan aman
                    String statusRaw = (data['status_member'] ?? false)
                        .toString()
                        .toLowerCase();
                    bool isAktif = statusRaw == 'aktif' || statusRaw == 'true';
                    String teksStatus = isAktif ? 'AKTIF' : 'TIDAK AKTIF';
                    // -------------------------

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: isAktif
                              ? const Color(0xFF39FF14)
                              : Colors.grey.shade800,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isAktif
                              ? const Color(0xFF39FF14).withValues(alpha: 0.2)
                              : Colors.grey[800],
                          child: Icon(
                            Icons.person,
                            color: isAktif
                                ? const Color(0xFF39FF14)
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          data['nama_lengkap'] ?? 'Tanpa Nama',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          data['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isAktif
                                ? const Color(0xFF39FF14)
                                : Colors.transparent,
                            border: Border.all(
                              color: isAktif
                                  ? const Color(0xFF39FF14)
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            teksStatus, // <-- Sekarang menggunakan teksStatus yang aman
                            style: TextStyle(
                              color: isAktif ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text(
                                'Aktivasi Member',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                'Apakah Anda yakin ingin mengaktifkan pembayaran member untuk pelanggan ${data['nama_lengkap']}?',
                                style: const TextStyle(color: Colors.grey),
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
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    try {
                                      // 1. Jalankan perintah update data
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(daftarPelanggan[index].id)
                                          .update({'status_member': 'aktif'});

                                      // 2. Jika sukses, munculkan snackbar hijau
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: const Color(
                                              0xFF39FF14,
                                            ),
                                            content: Text(
                                              'Member ${data['nama_lengkap']} berhasil diaktifkan!',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      // 3. JIKA GAGAL, DOSA UTAMANYA AKAN MUNCUL DI SINI (WARNA MERAH)
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.redAccent,
                                            content: Text(
                                              'Gagal mengubah data: $e',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF39FF14),
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text(
                                    'Aktifkan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
