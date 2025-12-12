class Genre {
  int? id;
  String name;

  Genre({this.id, required this.name});

  factory Genre.fromMap(Map<String, dynamic> map) {
    return Genre(id: map['id'], name: map['name']);
  }
}
