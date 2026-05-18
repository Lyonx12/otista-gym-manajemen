import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../members/scan_qr_screen.dart'; // Nanti kita buat file ini
import '../members/member_list_screen.dart'; // <-- IMPORT BARU UNTUK CARI MANUAL

class ReceptionistDashboardScreen extends StatelessWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF39FF14),
        elevation: 0,
        title: const Text(
          'Portal Resepsionis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // Dialog konfirmasi keluar
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text(
                    'Keluar Sistem',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Apakah Anda yakin ingin menutup sif dan keluar?',
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await authService.keluar();
                      },
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Keluar (Tutup Sif)',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selamat Datang, Staff!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih tindakan operasional di bawah ini:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // TOMBOL UTAMA: SCAN QR (Sangat Besar)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanQrScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF39FF14).withValues(alpha: 0.4),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_scanner, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'SCAN QR PELANGGAN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Verifikasi Pembayaran & Aktifkan Member',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TOMBOL SEKUNDER: Cari Manual (Sudah Aktif!)
            OutlinedButton.icon(
              onPressed: () {
                // <-- FUNGSI BARU: Pindah ke halaman MemberListScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MemberListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.search, color: Color(0xFF39FF14)),
              label: const Text('Cari Data Pelanggan Manual'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF39FF14),
                side: const BorderSide(color: Color(0xFF39FF14)),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
