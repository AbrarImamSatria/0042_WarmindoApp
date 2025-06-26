class TransaksiModel {
  final int? id;
  final DateTime tanggal;
  final double totalBayar;
  final String metodeBayar;
  final int idPengguna;

  TransaksiModel({
    this.id,
    required this.tanggal,
    required this.totalBayar,
    required this.metodeBayar,
    required this.idPengguna,
  });

  // Convert from Map (Database)
  factory TransaksiModel.fromMap(Map<String, dynamic> map) {
    return TransaksiModel(
      id: map['id'] as int?,
      tanggal: DateTime.parse(map['tanggal'] as String),
      totalBayar: map['total_bayar'] as double,
      metodeBayar: map['metode_bayar'] as String,
      idPengguna: map['id_pengguna'] as int,
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tanggal': tanggal.toIso8601String(),
      'total_bayar': totalBayar,
      'metode_bayar': metodeBayar,
      'id_pengguna': idPengguna,
    };
  }

  // Convert to Map without ID (for insert)
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Copy with method for updating
  TransaksiModel copyWith({
    int? id,
    DateTime? tanggal,
    double? totalBayar,
    String? metodeBayar,
    int? idPengguna,
  }) {
    return TransaksiModel(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      totalBayar: totalBayar ?? this.totalBayar,
      metodeBayar: metodeBayar ?? this.metodeBayar,
      idPengguna: idPengguna ?? this.idPengguna,
    );
  }

  // Check payment method
  bool get isCash => metodeBayar == 'tunai';
  bool get isQris => metodeBayar == 'qris';

  // Format total untuk display
  String get formattedTotal => 'Rp ${totalBayar.toStringAsFixed(0)}';

  // Format tanggal untuk display
  String get formattedDate {
    return '${tanggal.day}/${tanggal.month}/${tanggal.year}';
  }

  // Format waktu untuk display
  String get formattedTime {
    return '${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
  }

  // Generate transaction code
  String get transactionCode {
    final dateStr = tanggal.toString().substring(0, 10).replaceAll('-', '');
    final timeStr = tanggal.toString().substring(11, 16).replaceAll(':', '');
    return 'TRX$dateStr$timeStr';
  }

  @override
  String toString() {
    return 'TransaksiModel(id: $id, tanggal: $tanggal, totalBayar: $totalBayar, metodeBayar: $metodeBayar, idPengguna: $idPengguna)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransaksiModel &&
        other.id == id &&
        other.tanggal == tanggal &&
        other.totalBayar == totalBayar &&
        other.metodeBayar == metodeBayar &&
        other.idPengguna == idPengguna;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        tanggal.hashCode ^
        totalBayar.hashCode ^
        metodeBayar.hashCode ^
        idPengguna.hashCode;
  }
}