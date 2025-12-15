import '../database/db_helper.dart'; // Caminho ajustado para seu arquivo
import '../models/user_model.dart'; // Ajuste o caminho conforme sua estrutura de pastas

class UserRepository {
  final DbHelper _dbHelper = DbHelper();

  // Método para cadastrar um novo usuário
  Future<int> registerUser(User user) async {
    final db = await _dbHelper.database;
    
    // Insere o usuário utilizando o método toMap do modelo
    // ConflictAlgorithm.replace ou ignore pode ser usado dependendo da regra, 
    // mas aqui vamos deixar padrão pois e-mails duplicados checamos antes.
    return await db.insert('user', user.toMap());
  }

  // Método para realizar login
  // Retorna o objeto User se as credenciais estiverem corretas, ou null caso contrário.
  Future<User?> loginUser(String email, String password) async {
    final db = await _dbHelper.database;

    // Busca usuário pelo email e senha
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    
    return null; // Usuário não encontrado ou senha incorreta
  }

  // Método auxiliar para verificar se o email já existe antes de cadastrar
  Future<bool> checkEmailExists(String email) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'email = ?',
      whereArgs: [email],
    );

    return maps.isNotEmpty;
  }
  
  // Opcional: Método para buscar usuário por ID (útil para sessões)
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'user',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
}