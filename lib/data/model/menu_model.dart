class MenuModel {
  final int? id;
  final String nama;
  final double harga;
  final String kategori;
  final String? foto;

  MenuModel({
    this.id,
    required this.nama,
    required this.harga,
    required this.kategori,
    this.foto,
  });

  // Convert from Map (Database)
  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      harga: map['harga'] as double,
      kategori: map['kategori'] as String,
      foto: map['foto'] as String?,
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'kategori': kategori,
      'foto': foto,
    };
  }

  // Convert to Map without ID (for insert)
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Copy with method for updating
  MenuModel copyWith({
    int? id,
    String? nama,
    double? harga,
    String? kategori,
    String? foto,
  }) {
    return MenuModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      harga: harga ?? this.harga,
      kategori: kategori ?? this.kategori,
      foto: foto ?? this.foto,
    );
  }

  // Check if menu is food
  bool get isFood => kategori == 'makanan';

  // Check if menu is drink
  bool get isDrink => kategori == 'minuman';

  // Format harga untuk display
  String get formattedHarga => 'Rp ${harga.toStringAsFixed(0)}';

  @override
  String toString() {
    return 'MenuModel(id: $id, nama: $nama, harga: $harga, kategori: $kategori, foto: $foto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MenuModel &&
        other.id == id &&
        other.nama == nama &&
        other.harga == harga &&
        other.kategori == kategori &&
        other.foto == foto;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nama.hashCode ^
        harga.hashCode ^
        kategori.hashCode ^
        foto.hashCode;
  }
}