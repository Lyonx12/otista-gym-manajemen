import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/staff_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Mengambil Data Staff (Untuk Gerbang Logika / Cek Jabatan)
  Future<StaffModel?> getProfilStaff(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('staff_users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return StaffModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Sistem: Gagal mengambil data staff. Error: $e");
      return null;
    }
  }

  // 2. Fungsi Utama Resepsionis: MENGAKTIFKAN MEMBER PELANGGAN
  // Ini akan dieksekusi setelah pelanggan bayar cash di meja depan
  Future<bool> aktifkanMember(String uidPelanggan, int masaAktifHari) async {
    try {
      // Menghitung tanggal kadaluarsa dari hari ini
      DateTime tanggalBerakhir = DateTime.now().add(Duration(days: masaAktifHari));

      await _db.collection('users').doc(uidPelanggan).update({
        'status_member': true,
        'tanggal_berakhir_member': Timestamp.fromDate(tanggalBerakhir),
      });

      debugPrint("Sistem: Member berhasil diaktifkan!");
      return true;
    } catch (e) {
      debugPrint("Sistem: Gagal mengaktifkan member. Error: $e");
      return false;
    }
  }
}