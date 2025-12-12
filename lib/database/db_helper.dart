import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  DbHelper._internal();

  factory DbHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    // Inicialização para Desktop/Mobile
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'award.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR NOT NULL,
            email VARCHAR NOT NULL,
            password VARCHAR NOT NULL,
            role INTEGER NOT NULL
          )''');

        await db.execute('''
          CREATE TABLE genre(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name VARCHAR NOT NULL
          )''');

        await db.execute('''
          CREATE TABLE game(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name VARCHAR NOT NULL UNIQUE,
            description TEXT NOT NULL,
            release_date VARCHAR NOT NULL,
            FOREIGN KEY(user_id) REFERENCES user(id)
          )''');

        await db.execute('''
          CREATE TABLE game_genre(
            game_id INTEGER NOT NULL,
            genre_id INTEGER NOT NULL,
            FOREIGN KEY(game_id) REFERENCES game(id),
            FOREIGN KEY(genre_id) REFERENCES genre(id)
          )''');

        await db.execute('''
          CREATE TABLE category(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title VARCHAR NOT NULL,
            description TEXT,  
            date VARCHAR NOT NULL,
            FOREIGN KEY(user_id) REFERENCES user(id)
          )''');

        await db.execute('''
          CREATE TABLE category_game(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category_id INTEGER NOT NULL,
            game_id INTEGER NOT NULL,
            FOREIGN KEY(category_id) REFERENCES category(id),
            FOREIGN KEY(game_id) REFERENCES game(id)
          )''');

        await db.execute('''
          CREATE TABLE user_vote(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            category_id INTEGER NOT NULL,
            vote_game_id INTEGER NOT NULL,    
            FOREIGN KEY(user_id) REFERENCES user(id),
            FOREIGN KEY(category_id) REFERENCES category(id),
            FOREIGN KEY(vote_game_id) REFERENCES category_game(game_id)
          )''');

        // Inserir gêneros padrão aqui se desejar
      },
    );
  }

  // Exemplo de método para Login
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'user',
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getRankingByCategory(
    int categoryId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT g.name, COUNT(v.id) as total_votes
    FROM game g
    JOIN category_game cg ON g.id = cg.game_id
    LEFT JOIN user_vote v ON cg.game_id = v.vote_game_id AND cg.category_id = v.category_id
    WHERE cg.category_id = ?
    GROUP BY g.id
    ORDER BY total_votes DESC
  ''',
      [categoryId],
    );
  }
}
