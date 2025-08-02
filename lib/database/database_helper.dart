import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migrations/database_migrations.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'compasso_fiscal.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: DatabaseMigrations.onCreate,
    );
  }

  Future<void> fecharDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> limparDados() async {
    final db = await database;
    await db.delete('contribuicoes');
    await db.delete('membros');
    await db.delete('configuracoes');
    await DatabaseMigrations.insertConfiguracoesDefault(db);
  }
}
