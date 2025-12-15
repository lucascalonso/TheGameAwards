class CategoryGame {
  int? id;
  int categoryId;
  int gameId;

  CategoryGame({
    this.id,
    required this.categoryId,
    required this.gameId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'game_id': gameId,
    };
  }

  factory CategoryGame.fromMap(Map<String, dynamic> map) {
    return CategoryGame(
      id: map['id'],
      categoryId: map['category_id'],
      gameId: map['game_id'],
    );
  }
}