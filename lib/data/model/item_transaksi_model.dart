class ItemTransaksiModel {
  final int? id;
  final int idTransaksi;
  final String namaMenu;
  final double harga;
  final int jumlah;

  ItemTransaksiModel({
    this.id,
    required this.idTransaksi,
    required this.namaMenu,
    required this.harga,
    required this.jumlah,
  });

  // Convert from Map (Database)
  factory ItemTransaksiModel.fromMap(Map<String, dynamic> map) {
    return ItemTransaksiModel(
      id: map['id'] as int?,
      idTransaksi: map['id_transaksi'] as int,
      namaMenu: map['nama_menu'] as String,
      harga: map['harga'] as double,
      jumlah: map['jumlah'] as int,
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_transaksi': idTransaksi,
      'nama_menu': namaMenu,
      'harga': harga,
      'jumlah': jumlah,
    };
  }

  // Convert to Map without ID (for insert)
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Copy with method for updating
  ItemTransaksiModel copyWith({
    int? id,
    int? idTransaksi,
    String? namaMenu,
    double? harga,
    int? jumlah,
  }) {
    return ItemTransaksiModel(
      id: id ?? this.id,
      idTransaksi: idTransaksi ?? this.idTransaksi,
      namaMenu: namaMenu ?? this.namaMenu,
      harga: harga ?? this.harga,
      jumlah: jumlah ?? this.jumlah,
    );
  }

  // Calculate subtotal
  double get subtotal => harga * jumlah;

  // Format harga untuk display
  String get formattedHarga => 'Rp ${harga.toStringAsFixed(0)}';

  // Format subtotal untuk display
  String get formattedSubtotal => 'Rp ${subtotal.toStringAsFixed(0)}';

  @override
  String toString() {
    return 'ItemTransaksiModel(id: $id, idTransaksi: $idTransaksi, namaMenu: $namaMenu, harga: $harga, jumlah: $jumlah)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemTransaksiModel &&
        other.id == id &&
        other.idTransaksi == idTransaksi &&
        other.namaMenu == namaMenu &&
        other.harga == harga &&
        other.jumlah == jumlah;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        idTransaksi.hashCode ^
        namaMenu.hashCode ^
        harga.hashCode ^
        jumlah.hashCode;
  }
}