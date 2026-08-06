import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class JournalEntry {
  final int? id;
  final String gratitude;
  final String improvement;
  final String goals;

  JournalEntry({
    this.id,
    required this.gratitude,
    required this.improvement,
    required this.goals,
  });

  JournalEntry copyWith({
    int? id,
    String? gratitude,
    String? improvement,
    String? goals,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      gratitude: gratitude ?? this.gratitude,
      improvement: improvement ?? this.improvement,
      goals: goals ?? this.goals,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'gratitude': gratitude,
      'improvement': improvement,
      'goals': goals,
    };
  }

  factory JournalEntry.fromMap(Map<String, Object?> map) {
    return JournalEntry(
      id: map['id'] as int?,
      gratitude: map['gratitude'] as String,
      improvement: map['improvement'] as String,
      goals: map['goals'] as String,
    );
  }
}

class JournalDatabase {
  static final JournalDatabase instance = JournalDatabase._init();
  static Database? _database;

  JournalDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('journal.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gratitude TEXT NOT NULL,
        improvement TEXT NOT NULL,
        goals TEXT NOT NULL
      )
    ''');
  }

  Future<JournalEntry> create(JournalEntry entry) async {
    final db = await database;
    final id = await db.insert('journal', entry.toMap());

    return entry.copyWith(id: id);
  }

  Future<int> update(JournalEntry entry) async {
    final db = await database;
    return db.update(
      'journal',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return db.delete('journal', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countEntries() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM journal');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<JournalEntry>> readAllEntries() async {
    final db = await database;
    final orderBy = 'id DESC';
    final result = await db.query('journal', orderBy: orderBy);
    return result.map((row) => JournalEntry.fromMap(row)).toList();
  }

  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
