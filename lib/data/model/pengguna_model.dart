class PenggunaModel {
  final int? id;
  final String nama;
  final String password;
  final String role;
  final String? alamat;

  PenggunaModel({
    this.id,
    required this.nama,
    required this.password,
    required this.role,
    this.alamat,
  });

  // Convert from Map (Database)
  factory PenggunaModel.fromMap(Map<String, dynamic> map) {
    return PenggunaModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      alamat: map['alamat'] as String?,
    );
  }

  // Convert to Map (Database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'password': password,
      'role': role,
      'alamat': alamat,
    };
  }

  // Convert to Map without ID (for insert)
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Copy with method for updating
  PenggunaModel copyWith({
    int? id,
    String? nama,
    String? password,
    String? role,
    String? alamat,
  }) {
    return PenggunaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      password: password ?? this.password,
      role: role ?? this.role,
      alamat: alamat ?? this.alamat,
    );
  }

  // Check if user is owner
  bool get isOwner => role == 'pemilik';

  // Check if user is employee
  bool get isEmployee => role == 'karyawan';

  @override
  String toString() {
    return 'PenggunaModel(id: $id, nama: $nama, role: $role, alamat: $alamat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PenggunaModel &&
        other.id == id &&
        other.nama == nama &&
        other.password == password &&
        other.role == role &&
        other.alamat == alamat;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nama.hashCode ^
        password.hashCode ^
        role.hashCode ^
        alamat.hashCode;
  }
}