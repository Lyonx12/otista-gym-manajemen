import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import file konfigurasi Firebase (Nanti kita generate)
import 'firebase_options.dart';

// Import Halaman-halaman kita
import 'screens/auth/login_staff_screen.dart';
import 'screens/dashboard/receptionist_dashboard_screen.dart';
import 'screens/dashboard/owner_dashboard_screen.dart';

void main() async {
  // Pastikan mesin Flutter sudah siap sebelum memanggil Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const AplikasiManajemenGym());
}

class AplikasiManajemenGym extends StatelessWidget {
  const AplikasiManajemenGym({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portal Manajemen Gym',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok kanan
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF39FF14), // Hijau Neon Otista
          brightness: Brightness.dark,
          surface: Colors.grey[900], // Warna kartu gelap
        ),
        useMaterial3: true,
      ),
      // Layar pertama yang dibuka adalah Gerbang Logika
      home: const GerbangAksesStaff(),
    );
  }
}

/// =========================================================
/// GERBANG AKSES STAFF (Role-Based Access Control)
/// =========================================================
class GerbangAksesStaff extends StatelessWidget {
  const GerbangAksesStaff({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // 1. Cek apakah ada sesi login Auth yang aktif
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFF39FF14))));
        }

        // 2. Jika ada user yang sedang login
        if (authSnapshot.hasData && authSnapshot.data != null) {
          String uid = authSnapshot.data!.uid;

          return FutureBuilder<DocumentSnapshot>(
            // 3. Tembak ke tabel 'staff_users' di Firestore untuk mencari tahu jabatannya
            future: FirebaseFirestore.instance.collection('staff_users').doc(uid).get(),
            builder: (context, staffSnapshot) {
              if (staffSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Color(0xFF39FF14))));
              }
              
              // 4. Jika data staff ditemukan di database
              if (staffSnapshot.hasData && staffSnapshot.data!.exists) {
                Map<String, dynamic> dataStaff = staffSnapshot.data!.data() as Map<String, dynamic>;
                String jabatan = dataStaff['role'] ?? '';
                
                // 5. CABANG LOGIKA: Arahkan sesuai jabatan
                if (jabatan == 'owner') {
                  return const OwnerDashboardScreen();
                } else if (jabatan == 'receptionist') {
                  return const ReceptionistDashboardScreen();
                } else {
                  return _layarDitolak(context, 'Peran Anda tidak dikenali sistem.');
                }
              }

              // Jika user ada di Auth Firebase tapi BUKAN staff (misal pelanggan iseng nyoba login)
              return _layarDitolak(context, 'Akses Ditolak. Anda bukan Staff.');
            },
          );
        }

        // Jika BELUM login sama sekali, kembalikan ke layar Login
        return const LoginStaffScreen();
      },
    );
  }

  // Desain layar peringatan jika pelanggan mencoba menyusup
  Widget _layarDitolak(BuildContext context, String alasan) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, color: Colors.redAccent, size: 80),
            const SizedBox(height: 16),
            Text(alasan, style: const TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async => await FirebaseAuth.instance.signOut(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              child: const Text('KEMBALI'),
            )
          ],
        ),
      ),
    );
  }
}