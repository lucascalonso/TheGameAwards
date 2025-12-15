class UserVote {
  int? id;
  int userId;
  int categoryId;
  int voteGameId; // ID do jogo votado

  UserVote({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.voteGameId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'vote_game_id': voteGameId,
    };
  }

  factory UserVote.fromMap(Map<String, dynamic> map) {
    return UserVote(
      id: map['id'],
      userId: map['user_id'],
      categoryId: map['category_id'],
      voteGameId: map['vote_game_id'],
    );
  }
}