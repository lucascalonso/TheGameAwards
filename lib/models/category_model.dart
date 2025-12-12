class Category {
  int? id;
  int userId;
  String title;
  String? description;
  String date; // Data de validade

  Category({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      date: map['date'],
    );
  }

  bool get isActive => DateTime.parse(date).isAfter(DateTime.now());
}
