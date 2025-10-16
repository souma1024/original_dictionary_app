import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {

  // private constructor （このクラス内からしか使えないコンストラクタ）つまり、ほかのクラスで、
  // インスタンス生成できなくなるため、同時に二つ以上のDBインスタンスが存在しなくなる。          
  AppDatabase._();

  // 以下のようにすると、AppDatabase.instanceのみが唯一のDBの窓口
  static final AppDatabase instance = AppDatabase._();

  static const _dbName = 'original_dict_app.db';
  static const _dbVersion = 1;

  Database? _db;

  // databaseという名前のgetterを記述している。(get は予約語で、get (名前)~ でgetterを定義)
  // AppDatabase.instance.database　でdatabaseを取得。
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initializeDatabase();
    return _db!;
  }

  Future<Database> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // 外部キーを有効化
        await db.execute('PRAGMA foreign_keys = ON;');
      },
      onCreate: (db, version) async {
        // cards
        await db.execute('''
          CREATE TABLE cards (
            id INTEGER PRIMARY KEY,
            name VARCHAR NOT NULL,
            intro TEXT NOT NULL,
            is_fave INTEGER NOT NULL DEFAULT 0 CHECK (is_fave IN (0,1)),
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        // tags（名前はユニークにするのが一般的）
        await db.execute('''
          CREATE TABLE tags (
            id INTEGER PRIMARY KEY,
            name VARCHAR NOT NULL UNIQUE,
            created_at TEXT,
            updated_at TEXT
          );
        ''');

        // 中間テーブル
        await db.execute('''
          CREATE TABLE card_tags (
            id INTEGER PRIMARY KEY,
            card_id INTEGER NOT NULL,
            tag_id INTEGER NOT NULL,
            created_at TEXT,
            FOREIGN KEY (card_id) REFERENCES cards (id) ON DELETE CASCADE,
            FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE,
            UNIQUE (card_id, tag_id)
          );
        ''');

        // 参照先に合わせたインデックス
        // await db.execute('CREATE INDEX idx_card_tags_card_id ON card_tags(card_id);');
        // await db.execute('CREATE INDEX idx_card_tags_tag_id  ON card_tags(tag_id);');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 例:
        // if (oldVersion < 2) { await db.execute('ALTER TABLE cards ADD COLUMN ...'); }
      },
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}