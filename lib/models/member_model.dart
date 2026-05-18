import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String idUser;
  final String namaLengkap;
  final String noTelepon;
  final bool statusMember;
  final DateTime? tanggalBerakhirMember;

  MemberModel({
    required this.idUser,
    required this.namaLengkap,
    required this.noTelepon,
    this.statusMember = false,
    this.tanggalBerakhirMember,
  });

  factory MemberModel.fromMap(Map<String, dynamic> map, String documentId) {
    return MemberModel(
      idUser: documentId,
      namaLengkap: map['nama_lengkap'] ?? '',
      noTelepon: map['no_telepon'] ?? '',
      statusMember: map['status_member'] ?? false,
      tanggalBerakhirMember: map['tanggal_berakhir_member'] != null 
          ? (map['tanggal_berakhir_member'] as Timestamp).toDate() 
          : null,
    );
  }
}