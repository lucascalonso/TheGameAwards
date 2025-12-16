import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart'; // Importante adicionar este import

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  // Mudamos para versão 2 para aplicar a correção da coluna image_url
  static const int _databaseVersion = 2;

  DbHelper._internal();

  factory DbHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    // Inicialização para Desktop/Mobile
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), 'award.db');

    // DICA: Se quiser resetar tudo do zero e perder os dados antigos,
    // descomente a linha abaixo e rode o app uma vez:
    // await deleteDatabase(path);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Adicionado para migração
    );
  }

  // --- MIGRAÇÃO (Roda se a versão do banco mudar) ---
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Se o banco for da versão 1, adicionamos a coluna que faltava
      try {
        await db.execute("ALTER TABLE game ADD COLUMN image_url TEXT");
        print("MIGRAÇÃO: Coluna image_url adicionada com sucesso!");
      } catch (e) {
        // Ignora erro se a coluna já existir por algum motivo
        print("Erro na migração (pode ser ignorado se a coluna já existir): $e");
      }
    }
  }

  // --- CRIAÇÃO INICIAL (Roda apenas na primeira vez que instala o app) ---
  Future<void> _onCreate(Database db, int version) async {
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

    // Aqui já criamos com image_url para instalações novas
    await db.execute('''
      CREATE TABLE game(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name VARCHAR NOT NULL UNIQUE,
        description TEXT NOT NULL,
        image_url TEXT, 
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

    // --- SEED DATA (Dados iniciais) ---
    // Users
    await db.execute("INSERT INTO user(name, email, password, role) VALUES('Teste 1', 'teste1@teste', '123456', 0)");
    await db.execute("INSERT INTO user(name, email, password, role) VALUES('Teste 2', 'teste2@teste', '123456', 0)");
    await db.execute("INSERT INTO user(name, email, password, role) VALUES('Teste 3', 'teste3@teste', '123456', 0)");
    await db.execute("INSERT INTO user(name, email, password, role) VALUES('Teste 4', 'teste4@teste', '123456', 1)");
    await db.execute("INSERT INTO user(name, email, password, role) VALUES('Admin', 'admin@tga.com', '123', 1)"); // Admin padrão adicionado

    // Genres
    final genres = [
      'Aventura', 'Ação', 'RPG', 'Indie', 'Plataforma', 
      'Metroidvania', 'Rogue Lite', 'Survival Horror', 'Mundo Aberto'
    ];
    for (var g in genres) {
      await db.execute("INSERT INTO genre(name) VALUES('$g')");
    }

    // Games (Atualizados com image_url vazia ou placeholder se necessário)
    await db.execute("INSERT INTO game(user_id, name, description, release_date, image_url) VALUES(1, 'Clair Obscur: Expedition 33', 'Turn-based RPG...', '2025-04-24', 'https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2458030/library_600x900.jpg')");
    await db.execute("INSERT INTO game(user_id, name, description, release_date, image_url) VALUES(1, 'Hades 2', 'Sequel from Supergiant...', '2025-09-25', 'https://upload.wikimedia.org/wikipedia/en/c/c1/Hades_II_cover_art.jpg')");
    await db.execute("INSERT INTO game(user_id, name, description, release_date, image_url) VALUES(2, 'Hollow Knight: Silksong', 'Kingdom ruled by silk and song...', '2025-09-04', 'https://upload.wikimedia.org/wikipedia/en/6/6d/Hollow_Knight_Silksong_cover_art.png')");
    await db.execute("INSERT INTO game(user_id, name, description, release_date, image_url) VALUES(3, 'Death Stranding 2: On the Beach', 'Hideo Kojima changes the world...', '2025-06-26', 'https://miro.medium.com/v2/resize:fit:1400/1*bJ5Xf14O-Xq4yJ5YfX7ZqA.jpeg')");
    
    // Categories
    await db.execute("INSERT INTO category(title, description, date, user_id) VALUES('Game of the Year', 'The absolute best experience.', '2025-12-11', 0)");
    await db.execute("INSERT INTO category(title, description, date, user_id) VALUES('Best Narrative', 'Outstanding storytelling.', '2025-12-11', 0)");

    // Category Games Links
    await db.execute("INSERT INTO category_game(category_id, game_id) VALUES(1, 1)");
    await db.execute("INSERT INTO category_game(category_id, game_id) VALUES(1, 2)");
    await db.execute("INSERT INTO category_game(category_id, game_id) VALUES(1, 3)");
    
    print("Database Criado com sucesso!");
  }

  // --- MÉTODOS DE CONSULTA (Mantidos do seu código original) ---

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'user',
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getRankingByCategory(int categoryId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT g.name, g.image_url, COUNT(v.id) as total_votes
      FROM game g
      JOIN category_game cg ON g.id = cg.game_id
      LEFT JOIN user_vote v ON cg.game_id = v.vote_game_id AND cg.category_id = v.category_id
      WHERE cg.category_id = ?
      GROUP BY g.id
      ORDER BY total_votes DESC
    ''', [categoryId]);
  }

  Future<List<Map<String, dynamic>>> searchGames({
    int? categoryId,
    int? genreId,
    int? position,
  }) async {
    final db = await database;

    if (position != null && categoryId != null) {
      final ranking = await getRankingByCategory(categoryId);
      if (ranking.length >= position) {
        final gameAtPosition = ranking[position - 1];
        final gameName = gameAtPosition['name'];

        String sql = "SELECT g.* FROM game g ";
        List<dynamic> args = [];

        if (genreId != null) {
          sql += "JOIN game_genre gg ON g.id = gg.game_id WHERE gg.genre_id = ? AND g.name = ?";
          args = [genreId, gameName];
        } else {
          sql += "WHERE g.name = ?";
          args = [gameName];
        }
        return await db.rawQuery(sql, args);
      } else {
        return [];
      }
    }

    String sql = "SELECT DISTINCT g.* FROM game g ";
    List<dynamic> args = [];
    List<String> whereClauses = [];

    if (categoryId != null) {
      sql += "JOIN category_game cg ON g.id = cg.game_id ";
      whereClauses.add("cg.category_id = ?");
      args.add(categoryId);
    }

    if (genreId != null) {
      sql += "JOIN game_genre gg ON g.id = gg.game_id ";
      whereClauses.add("gg.genre_id = ?");
      args.add(genreId);
    }

    if (whereClauses.isNotEmpty) {
      sql += "WHERE " + whereClauses.join(" AND ");
    }

    return await db.rawQuery(sql, args);
  }

  Future<List<Map<String, dynamic>>> getAllGenres() async {
    final db = await database;
    return await db.query('genre');
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query('category');
  }

  Future<int> deleteGame(int id) async {
    final db = await database;
    await db.delete('game_genre', where: 'game_id = ?', whereArgs: [id]); // Limpa relação de gênero
    await db.delete('category_game', where: 'game_id = ?', whereArgs: [id]);
    await db.delete('user_vote', where: 'vote_game_id = ?', whereArgs: [id]);
    return await db.delete('game', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    await db.delete('category_game', where: 'category_id = ?', whereArgs: [id]);
    await db.delete('user_vote', where: 'category_id = ?', whereArgs: [id]);
    return await db.delete('category', where: 'id = ?', whereArgs: [id]);
  }
}