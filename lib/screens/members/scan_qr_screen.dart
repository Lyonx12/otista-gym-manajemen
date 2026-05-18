import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  // Pengontrol kamera
  MobileScannerController cameraController = MobileScannerController();
  
  // Kunci (Lock) agar kamera tidak nge-scan 100x dalam sedetik
  bool _sudahScan = false; 
  final FirestoreService _firestoreService = FirestoreService();

  // Fungsi yang dipanggil saat kamera berhasil membaca kotak QR
  void _prosesDataQR(String uidPelanggan) async {
    // Munculkan efek loading di layar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF39FF14))),
    );

    try {
      // Menarik data asli pelanggan dari Firebase menggunakan UID dari QR Code
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(uidPelanggan).get();

      // Tutup efek loading
      if (mounted) Navigator.pop(context);

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String nama = data['nama_lengkap'] ?? 'Pelanggan';
        bool statusMember = data['status_member'] ?? false;

        // Buka menu pop-up dari bawah untuk konfirmasi
        if (mounted) {
          _tampilkanMenuKonfirmasi(uidPelanggan, nama, statusMember);
        }
      } else {
        _tampilkanPesanError('QR Code tidak dikenali oleh sistem Gym Otista.');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _tampilkanPesanError('Gagal terhubung ke database.');
    }
  }

  void _tampilkanPesanError(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red),
    );
    // Buka kunci lagi agar bisa scan ulang
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _sudahScan = false);
    });
  }

  void _tampilkanMenuKonfirmasi(String uid, String nama, bool isAktif) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true, // Agar pop-up bisa membesar menyesuaikan isi
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Icon(Icons.verified_user, size: 60, color: Color(0xFF39FF14)),
              const SizedBox(height: 16),
              const Text('Data Pelanggan Ditemukan', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 8),
              Text(nama.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Cek jika sudah aktif, beri peringatan. Jika belum, tampilkan tombol bayar.
              if (isAktif)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: const Text('STATUS: MEMBER SUDAH AKTIF\nPelanggan ini sudah memiliki akses masuk.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF39FF14))),
                )
              else
                Column(
                  children: [
                    const Text('Status: MENUNGGU PEMBAYARAN', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context); // Tutup pop-up
                          
                          // Eksekusi fungsi Aktifkan Member dari file FirestoreService
                          // Kita asumsikan pelanggan beli paket 30 Hari
                          bool sukses = await _firestoreService.aktifkanMember(uid, 30); 
                          
                          if (sukses && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pembayaran Diterima! Member berhasil diaktifkan.'), backgroundColor: Colors.green),
                            );
                            Navigator.pop(context); // Kembali ke Dashboard Resepsionis
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF39FF14),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('KONFIRMASI LUNAS & AKTIFKAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Saat pop-up ditutup (baik disengaja maupun tidak), buka kunci kamera lagi
      setState(() => _sudahScan = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFF39FF14)),
        title: const Text('Arahkan ke QR Code', style: TextStyle(color: Color(0xFF39FF14))),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(), // Fitur Senter
          ),
        ],
      ),
      // Tampilan Kamera Utama
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_sudahScan) return; // Jika sedang proses, abaikan tangkapan kamera lain
              
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String? rawValue = barcodes.first.rawValue;
                if (rawValue != null) {
                  setState(() => _sudahScan = true); // Kunci kamera
                  _prosesDataQR(rawValue); // Proses UID-nya
                }
              }
            },
          ),
          // Overlay Garis Kotak Scanner (Efek Visual)
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF39FF14), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Pastikan QR Code berada di dalam kotak hijau',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}