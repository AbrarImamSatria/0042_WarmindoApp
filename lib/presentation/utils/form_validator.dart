// presentation/utils/form_validator.dart
/// Helper class untuk validasi form input
class FormValidator {
  
  /// Validasi field yang wajib diisi
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    return null;
  }
  
  /// Validasi nama pengguna
  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama pengguna tidak boleh kosong';
    }
    
    if (value.trim().length < 3) {
      return 'Nama pengguna minimal 3 karakter';
    }
    
    if (value.trim().length > 20) {
      return 'Nama pengguna maksimal 20 karakter';
    }
    
    // Hanya boleh huruf, angka, underscore, dan titik
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value.trim())) {
      return 'Nama pengguna hanya boleh berisi huruf, angka, underscore, dan titik';
    }
    
    return null;
  }
  
  /// Validasi password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    if (value.length > 20) {
      return 'Password maksimal 20 karakter';
    }
    
    return null;
  }
  
  /// Validasi konfirmasi password
  static String? confirmPassword(String? value, String? originalPassword) {
    final passwordError = password(value);
    if (passwordError != null) return passwordError;
    
    if (value != originalPassword) {
      return 'Konfirmasi password tidak sesuai';
    }
    
    return null;
  }
  
  /// Validasi nomor telepon
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opsional
    }
    
    // Hapus semua karakter non-digit
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanNumber.length < 10 || cleanNumber.length > 15) {
      return 'Nomor telepon harus 10-15 digit';
    }
    
    return null;
  }
  
  /// Validasi alamat
  static String? address(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Opsional
    }
    
    if (value.trim().length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    
    if (value.trim().length > 200) {
      return 'Alamat maksimal 200 karakter';
    }
    
    return null;
  }
  
  /// Validasi nama menu
  static String? menuName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama menu tidak boleh kosong';
    }
    
    if (value.trim().length < 2) {
      return 'Nama menu minimal 2 karakter';
    }
    
    if (value.trim().length > 50) {
      return 'Nama menu maksimal 50 karakter';
    }
    
    return null;
  }
  
  /// Validasi harga
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    
    // Hapus karakter non-digit kecuali titik dan koma
    String cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    double? price = double.tryParse(cleanValue);
    if (price == null) {
      return 'Format harga tidak valid';
    }
    
    if (price <= 0) {
      return 'Harga harus lebih dari 0';
    }
    
    if (price > 1000000) {
      return 'Harga tidak boleh lebih dari 1 juta';
    }
    
    return null;
  }
  
  /// Validasi jumlah/quantity
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Jumlah tidak boleh kosong';
    }
    
    int? qty = int.tryParse(value);
    if (qty == null) {
      return 'Jumlah harus berupa angka';
    }
    
    if (qty <= 0) {
      return 'Jumlah harus lebih dari 0';
    }
    
    if (qty > 100) {
      return 'Jumlah maksimal 100';
    }
    
    return null;
  }
}