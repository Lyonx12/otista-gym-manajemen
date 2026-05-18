import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
// IMPORT KEEMPAT HALAMAN LAPORAN
import '../reports/financial_report_screen.dart';
import '../reports/history_screen.dart';
import '../reports/inventory_screen.dart';
import '../reports/complaint_screen.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF39FF14),
        elevation: 0,
        title: const Text(
          'Portal Pemilik (Owner)',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await AuthService().keluar();
            },
            tooltip: 'Keluar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAGIAN 1: STATISTIK REAL-TIME ---
            const Text(
              'Statistik Member',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF39FF14),
                      ),
                    ),
                  );
                }

                int memberAktif = 0;
                int memberBelumBayar = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    var data = doc.data() as Map<String, dynamic>;
                    String status = (data['status_member'] ?? '')
                        .toString()
                        .toLowerCase();
                    String role = (data['role'] ?? '').toString().toLowerCase();

                    // Abaikan akun owner dan receptionist dari hitungan
                    if (role == 'owner' || role == 'receptionist') continue;

                    if (status == 'aktif' || status == 'true') {
                      memberAktif++;
                    } else {
                      memberBelumBayar++;
                    }
                  }
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Member Aktif',
                        count: memberAktif.toString(),
                        icon: Icons.check_circle,
                        color: const Color(0xFF39FF14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Belum Bayar',
                        count: memberBelumBayar.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),

            // --- BAGIAN 2: MENU PENGAWASAN OPERASIONAL ---
            const Text(
              'Pengawasan Operasional',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Menu Laporan Keuangan
            _buildMenuCard(
              context: context,
              icon: Icons.account_balance_wallet,
              title: 'Keuangan & Pendapatan',
              subtitle: 'Pantau arus kas dan riwayat transaksi pendaftaran.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FinancialReportScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. Menu Masa Aktif & History Member
            _buildMenuCard(
              context: context,
              icon: Icons.history_edu,
              title: 'History & Masa Aktif',
              subtitle: 'Tinjau riwayat kedatangan dan sisa masa aktif member.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. Menu Inventory & Stok Barang
            _buildMenuCard(
              context: context,
              icon: Icons.inventory,
              title: 'Inventaris & Stok Barang',
              subtitle: 'Kelola stok suplemen, minuman, dan laporan barang.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 4. Menu Kerusakan & Pengaduan
            _buildMenuCard(
              context: context,
              icon: Icons.report_problem,
              title: 'Kerusakan & Pengaduan',
              subtitle: 'Laporan alat gym yang rusak dan komplain pelanggan.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComplaintScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget Pembuat Kotak Statistik
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 28),
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pembuat Kartu Menu
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF39FF14)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
