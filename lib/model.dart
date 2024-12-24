class NotesModel {
  int? id;
  String? title;
  String? email;
  int? age;
  String? description;

  NotesModel(
      {required this.id,
      required this.title,
      required this.email,
      required this.age,
      required this.description});

  NotesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    email = json['email'];
    age = json['age'];
    description = json['description'];
  }

  Map<String, Object?> toMap() {
    return{
      'id':id,
      'title':title,
      'age':age,
      'description':description,
      'email':email
    };
  }
}
