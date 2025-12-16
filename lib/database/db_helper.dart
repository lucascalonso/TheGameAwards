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

    //só pra limpar o db dessa vez, depois comentar (Lucas)
    //await deleteDatabase(path);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // --- CRIAÇÃO DAS TABELAS ---
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

        // Users
        await db.execute(
          "INSERT INTO user(name, email, password, role) VALUES('Teste 1', 'teste1@teste', '123456', 0)",
        );
        await db.execute(
          "INSERT INTO user(name, email, password, role) VALUES('Teste 2', 'teste2@teste', '123456', 0)",
        );
        await db.execute(
          "INSERT INTO user(name, email, password, role) VALUES('Teste 3', 'teste3@teste', '123456', 0)",
        );
        await db.execute(
          "INSERT INTO user(name, email, password, role) VALUES('Teste 4', 'teste4@teste', '123456', 1)",
        );
        await db.execute(
          "INSERT INTO user(name, email, password, role) VALUES('Teste 5', 'teste5@teste', '123456', 1)",
        );

        // Genres
        await db.execute("INSERT INTO genre(name) VALUES('Aventura')");
        await db.execute("INSERT INTO genre(name) VALUES('Ação')");
        await db.execute("INSERT INTO genre(name) VALUES('RPG')");
        await db.execute("INSERT INTO genre(name) VALUES('Indie')");
        await db.execute("INSERT INTO genre(name) VALUES('Plataforma')");
        await db.execute("INSERT INTO genre(name) VALUES('Metroidvania')");
        await db.execute("INSERT INTO genre(name) VALUES('Rogue Lite')");
        await db.execute("INSERT INTO genre(name) VALUES('Survival Horror')");
        await db.execute("INSERT INTO genre(name) VALUES('Mundo Aberto')");

        // Games
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'Clair Obscur: Expedition 33', 'Once a year, the Paintress wakes and paints upon her monolith. Paints her cursed number. And everyone past that age turns to smoke and fades away. Year by year, that number ticks down and more of us are erased. Tomorrow she’ll wake and paint “33.” And tomorrow we depart on our final mission - Destroy the Paintress, so she can never paint death again. We are Expedition 33.Clair Obscur: Expedition 33 is a ground-breaking turn-based RPG with unique real-time mechanics, making battles more immersive and addictive than ever. Explore a fantasy world inspired by Belle Époque France in which you battle devastating enemies.', '2025-04-24');",
        );
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(1, 'Hades 2', 'The first-ever sequel from Supergiant Games builds on the best aspects of the original god-like rogue-like dungeon crawler in an all-new, action-packed, endlessly replayable experience rooted in the Underworld of Greek myth and its deep connections to the dawn of witchcraft.', '2025-09-25');",
        );
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(2, 'Hollow Knight: Silksong', 'As the lethal hunter Hornet, adventure through a kingdom ruled by silk and song! Captured and taken to this unfamiliar world, prepare to battle mighty foes and solve ancient mysteries as you ascend on a deadly pilgrimage to the kingdom’s peak.Hollow Knight: Silksong is the epic sequel to Hollow Knight, the award winning action-adventure. Journey to all-new lands, discover new powers, battle vast hordes of bugs and beasts and uncover secrets tied to your nature and your past. ', '2025-09-04');",
        );
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(3, 'Death Stranding 2: On the Beach', 'Com companheiros ao seu lado, Sam inicia uma nova jornada para salvar a humanidade da extinção.Junte-se a eles na travessia desse mundo problemático repleto de inimigos sobrenaturais, obstáculos e uma questão inquietante: deveríamos ter nos conectado?Hideo Kojima, o lendário designer de jogos, muda o mundo mais uma vez.', '2025-06-26');",
        );
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(3, 'Donkey Kong Bananza', 'Donkey Kong Bananza é um jogo eletrônico de plataforma desenvolvido e publicado pela Nintendo para o Nintendo Switch 2. O jogador controla o gorila Donkey Kong, que se aventura no subsolo com a jovem Pauline para recuperar artefatos conhecido como Cristais de Banândio de um grupo de macacos vilões.', '2025-07-17');",
        );
        await db.execute(
          "INSERT INTO game(user_id, name, description, release_date) VALUES(3, 'Kingdom Come: Deliverance II', 'Kingdom Come: Deliverance II é um RPG de ação desenvolvido pela Warhorse Studios e publicado pela Deep Silver. Sequência de Kingdom Come: Deliverance, o jogo foi lançado para PlayStation 5, Windows e Xbox Series X/S no dia 4 de fevereiro de 2025', '2025-02-04');",
        );

        // Game Genres
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(1, 3)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(2, 2)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(2, 3)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(2, 4)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(3, 2)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(3, 3)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(3, 4)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(4, 2)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(5, 1)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(5, 2)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(6, 3)",
        );
        await db.execute(
          "INSERT INTO game_genre(game_id, genre_id) VALUES(6, 9)",
        );

        // Categories
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Game of the Year','Recognizing a game that delivers the absolute best experience across all creative and technical fields.', '2025-12-11', 0)",
        );
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Best Narrative','For outstanding storytelling and narrative development in a game.', '2025-12-11', 0)",
        );
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Best RPG','For the best game designed with rich player character customization and progression, including massively multiplayer experiences.', '2025-12-11', 0)",
        );
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Best Family','For the best game appropriate for family play, irrespective of genre or platform.', '2025-12-11', 0)",
        );
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Best Independent Game','For outstanding creative and technical achievement in a game made outside the traditional publisher system.', '2025-12-11', 1)",
        );
        await db.execute(
          "INSERT INTO category(title, description, date, user_id) VALUES('Best Fighting','For the best game designed primarily around head-to-head combat.', '2025-12-11', 1)",
        );

        // Category Games
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 1)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 2)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 3)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 4)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 5)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(1, 6)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(2, 1)",
        );
        await db.execute(
          "INSERT INTO category_game(category_id, game_id) VALUES(2, 2)",
        );

        // User Votes
        await db.execute(
          "INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 1, 3)",
        );
        await db.execute(
          "INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 2, 1)",
        );
        await db.execute(
          "INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(4, 1, 3)",
        );
        await db.execute(
          "INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(5, 1, 1)",
        );
        await db.execute(
          "INSERT INTO user_vote(user_id, category_id, vote_game_id) VALUES(5, 2, 2)",
        );
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
          sql +=
              "JOIN game_genre gg ON g.id = gg.game_id WHERE gg.genre_id = ? AND g.name = ?";
          args = [genreId, gameName];
        } else {
          sql += "WHERE g.name = ?";
          args = [gameName];
        }

        return await db.rawQuery(sql, args);
      } else {
        return []; // Ninguém nessa posição
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
    return await db.delete('game', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    await db.delete('category_game', where: 'category_id = ?', whereArgs: [id]);
    await db.delete('user_vote', where: 'category_id = ?', whereArgs: [id]);
    return await db.delete('category', where: 'id = ?', whereArgs: [id]);
  }
}
