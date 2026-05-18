import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF39FF14),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'History & Masa Aktif',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF39FF14)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data member.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Menyaring agar akun owner dan resepsionis tidak ikut muncul di daftar history
          var dataPelanggan = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String role = (data['role'] ?? '').toString().toLowerCase();
            return role != 'owner' && role != 'receptionist';
          }).toList();

          if (dataPelanggan.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data pelanggan.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataPelanggan.length,
            itemBuilder: (context, index) {
              var data = dataPelanggan[index].data() as Map<String, dynamic>;
              String nama = data['nama_lengkap'] ?? 'Tanpa Nama';
              String status = (data['status_member'] ?? '')
                  .toString()
                  .toLowerCase();
              bool isAktif = status == 'aktif' || status == 'true';

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isAktif ? const Color(0xFF39FF14) : Colors.redAccent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isAktif
                        ? const Color(0xFF39FF14).withValues(alpha: 0.2)
                        : Colors.redAccent.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person,
                      color: isAktif
                          ? const Color(0xFF39FF14)
                          : Colors.redAccent,
                    ),
                  ),
                  title: Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    isAktif
                        ? 'Status: Aktif (Bisa Akses Gym)'
                        : 'Status: Menunggu Pembayaran / Non-Aktif',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: Icon(
                    isAktif ? Icons.check_circle : Icons.cancel,
                    color: isAktif ? const Color(0xFF39FF14) : Colors.redAccent,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
