import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi Login Khusus Staff (Pakai Email Asli)
  Future<bool> loginStaff(String emailStaff, String kataSandi) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailStaff, 
        password: kataSandi
      );
      debugPrint("Sistem: Login Staff berhasil untuk $emailStaff");
      return true;
    } catch (e) {
      debugPrint("Sistem: Login Staff gagal. Error: $e");
      return false; 
    }
  }

  Future<void> keluar() async {
    await _auth.signOut();
    debugPrint("Sistem: Staff berhasil keluar dari sistem.");
  }
}