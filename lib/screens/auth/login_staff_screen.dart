import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginStaffScreen extends StatefulWidget {
  const LoginStaffScreen({super.key});

  @override
  State<LoginStaffScreen> createState() => _LoginStaffScreenState();
}

class _LoginStaffScreenState extends State<LoginStaffScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _kataSandiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();
  bool _sedangMemuat = false;

  // Menggunakan gaya input yang persis dengan aplikasi pelanggan
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF39FF14)),
      filled: true,
      fillColor: Colors.grey[900],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF39FF14), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  void _prosesLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _sedangMemuat = true;
    });

    String email = _emailController.text.trim();
    String sandi = _kataSandiController.text.trim();

    bool berhasil = await _authService.loginStaff(email, sandi);

    if (mounted) {
      setState(() {
        _sedangMemuat = false;
      });

      if (!berhasil) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akses Ditolak. Periksa email atau sandi Anda.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Catatan: Jika berhasil, kita TIDAK perlu menulis Navigator.push.
      // Karena di main.dart kita sudah memasang GerbangAksesStaff (StreamBuilder)
      // yang akan otomatis memindahkan layar begitu mendeteksi ada akun yang berhasil login.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo_otista.png',
                    width: 120,
                    height: 120,
                    // Tambahkan fallback jika gambar belum ada agar tidak error
                    errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.security, size: 100, color: Color(0xFF39FF14)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Portal Manajemen\nOtista Gym',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Akses Khusus Internal',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Input Email (Bukan Telepon)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Email Staff', Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input Kata Sandi
                TextFormField(
                  controller: _kataSandiController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Kata Sandi', Icons.lock_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Tombol Masuk Portal
                ElevatedButton(
                  onPressed: _sedangMemuat ? null : _prosesLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF39FF14), 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFF39FF14).withValues(alpha: 0.5),
                  ),
                  child: _sedangMemuat
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'MASUK PORTAL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}