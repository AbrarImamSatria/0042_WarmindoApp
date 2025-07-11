// presentation/utils/error_handler.dart
/// Helper class untuk mengelola error handling secara konsisten
class ErrorHandler {
  
  /// Mengubah exception menjadi pesan error yang user-friendly
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      String message = error.toString();
      
      // Hapus prefix "Exception: " jika ada
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      
      // Mapping error umum ke pesan yang lebih friendly
      return _mapErrorMessage(message);
    }
    
    return 'Terjadi kesalahan tidak terduga';
  }
  
  /// Mapping pesan error ke bahasa yang lebih user-friendly
  static String _mapErrorMessage(String message) {
    // Error database umum
    if (message.contains('database') || message.contains('sql')) {
      return 'Terjadi kesalahan pada database';
    }
    
    // Error koneksi
    if (message.contains('connection') || message.contains('network')) {
      return 'Masalah koneksi, silakan coba lagi';
    }
    
    // Error validasi
    if (message.contains('validation') || message.contains('invalid')) {
      return 'Data yang dimasukkan tidak valid';
    }
    
    // Error permission
    if (message.contains('permission') || message.contains('access')) {
      return 'Tidak memiliki izin untuk aksi ini';
    }
    
    // Return pesan asli jika sudah user-friendly
    return message;
  }
  
  /// Konstanta untuk pesan error umum
  static const String networkError = 'Masalah koneksi internet';
  static const String databaseError = 'Terjadi kesalahan pada database';
  static const String validationError = 'Data yang dimasukkan tidak valid';
  static const String permissionError = 'Tidak memiliki izin untuk aksi ini';
  static const String generalError = 'Terjadi kesalahan tidak terduga';
}