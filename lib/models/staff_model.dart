class StaffModel {
  final String idStaff;
  final String namaLengkap;
  final String email;
  final String role; // Isinya nanti wajib: "owner" atau "receptionist"

  StaffModel({
    required this.idStaff,
    required this.namaLengkap,
    required this.email,
    required this.role,
  });

  factory StaffModel.fromMap(Map<String, dynamic> map, String documentId) {
    return StaffModel(
      idStaff: documentId,
      namaLengkap: map['nama_lengkap'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'receptionist', // Default aman jika kosong
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_lengkap': namaLengkap,
      'email': email,
      'role': role,
    };
  }
}