import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String id;
  final String name;
  final int age;
  final DateTime birthday;

  Student({
    this.id = '',
    required this.name,
    required this.age,
    required this.birthday,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'birthday': birthday,
    };
  }

  factory Student.fromJson(String id, Map<String, dynamic> json) {
    return Student(
      id: id,
      name: json['name'],
      age: json['age'],
      birthday: (json['birthday'] as Timestamp).toDate(),
    );
  }
}
