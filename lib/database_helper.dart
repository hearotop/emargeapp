import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'play_history.db');
    return await openDatabase(
      path,
      version: 8, // 版本号递增，触发升级逻辑
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE play_history(id INTEGER PRIMARY KEY AUTOINCREMENT, videoId TEXT, title TEXT, timestamp DATETIME, duration TEXT, coverUrl TEXT, videoUrl TEXT)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < newVersion) {
          try {
            db.execute('ALTER TABLE play_history ADD COLUMN duration TEXT');
            print('成功添加 duration 字段');
            db.execute('ALTER TABLE play_history ADD COLUMN coverUrl TEXT');
            print('成功添加 coverUrl 字段');
            db.execute('ALTER TABLE play_history ADD COLUMN videoUrl TEXT');
            print('成功添加 videoUrl 字段');
          } catch (e) {
            print('数据库升级出错: $e');
          }
        }
      },
    );
  }

  Future<void> insertPlayHistory(Map<String, dynamic> playHistory) async {
    try {
      // 添加系统时间
      playHistory['timestamp'] = DateTime.now().toIso8601String();
      final db = await database;
      // 删除该视频的旧记录
      await db.delete('play_history',
          where: 'videoId = ?', whereArgs: [playHistory['videoId']]);
      await db.insert(
        'play_history',
        playHistory,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('插入播放记录时出错: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPlayHistory() async {
    final db = await database;
    return await db.query('play_history', orderBy: 'timestamp DESC');
  }

  Future<void> deletePlayHistory(String videoId) async {
    final db = await database;
    await db.delete('play_history', where: 'videoId = ?', whereArgs: [videoId]);
  }
}
