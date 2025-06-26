import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = 'warmindo_pos.db';
  static const int _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static const String tablePengguna = 'pengguna';
  static const String tableMenu = 'menu';
  static const String tableTransaksi = 'transaksi';
  static const String tableItemTransaksi = 'item_transaksi';

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Pengguna
    await db.execute('''
      CREATE TABLE $tablePengguna (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('pemilik', 'karyawan')),
        alamat TEXT
      )
    ''');

    // Tabel Menu
    await db.execute('''
      CREATE TABLE $tableMenu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        harga REAL NOT NULL,
        kategori TEXT NOT NULL CHECK (kategori IN ('makanan', 'minuman')),
        foto TEXT
      )
    ''');

    // Tabel Transaksi
    await db.execute('''
      CREATE TABLE $tableTransaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tanggal TEXT NOT NULL,
        total_bayar REAL NOT NULL,
        metode_bayar TEXT NOT NULL CHECK (metode_bayar IN ('tunai', 'qris')),
        id_pengguna INTEGER NOT NULL,
        FOREIGN KEY (id_pengguna) REFERENCES $tablePengguna (id)
      )
    ''');

    // Tabel Item Transaksi
    await db.execute('''
      CREATE TABLE $tableItemTransaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER NOT NULL,
        nama_menu TEXT NOT NULL,
        harga REAL NOT NULL,
        jumlah INTEGER NOT NULL,
        FOREIGN KEY (id_transaksi) REFERENCES $tableTransaksi (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_transaksi_tanggal ON $tableTransaksi (tanggal)
    ''');

    await db.execute('''
      CREATE INDEX idx_transaksi_pengguna ON $tableTransaksi (id_pengguna)
    ''');

    await db.execute('''
      CREATE INDEX idx_item_transaksi ON $tableItemTransaksi (id_transaksi)
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default pemilik account
    await db.insert(tablePengguna, {
      'nama': 'Pemilik',
      'password': '123456', 
      'alamat': null,
    });

    await db.insert(tablePengguna, {
      'nama': 'Karyawan',
      'password': '123456', 
      'role': 'karyawan',
      'alamat': null,
    });

    final menuItems = [
      // Makanan
      {
        'nama': 'Indomie Goreng',
        'harga': 8000,
        'kategori': 'makanan',
      },
      {
        'nama': 'Indomie Kuah',
        'harga': 8000,
        'kategori': 'makanan',
      },
      {
        'nama': 'Indomie Goreng Telur',
        'harga': 12000,
        'kategori': 'makanan',
      },
      {
        'nama': 'Indomie Kuah Telur',
        'harga': 12000,
        'kategori': 'makanan',
      },
      {
        'nama': 'Nasi Putih',
        'harga': 5000,
        'kategori': 'makanan',
      },
      // Minuman
      {
        'nama': 'Es Teh Manis',
        'harga': 5000,
        'kategori': 'minuman',
      },
      {
        'nama': 'Teh Manis Hangat',
        'harga': 4000,
        'kategori': 'minuman',
      },
      {
        'nama': 'Es Jeruk',
        'harga': 6000,
        'kategori': 'minuman',
      },
      {
        'nama': 'Jeruk Hangat',
        'harga': 5000,
        'kategori': 'minuman',
      },
      {
        'nama': 'Air Mineral',
        'harga': 4000,
        'kategori': 'minuman',
      },
    ];

    for (final item in menuItems) {
      await db.insert(tableMenu, {
        ...item,
        'foto': null,
      });
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }

  Future<bool> databaseExists() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await databaseFactory.databaseExists(path);
  }
}