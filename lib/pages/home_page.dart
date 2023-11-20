import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_crud/models/student_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final studentsCollection = FirebaseFirestore.instance.collection('students');

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dobController = TextEditingController();

  late Stream<List<Student>> fetchStudents;

  @override
  void initState() {
    super.initState();
    fetchStudents = readStudents();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Column(
          children: [
            StreamBuilder<List<Student>>(
              stream: fetchStudents,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final students = snapshot.data!;
                  // print(studentsCollection.doc().get());
                  // final hitherehowareyou = studentsCollection.doc().get();
                  // // final b= hitherehowareyou.re
                  // final a = snapshot.data[]
                  return Expanded(
                    child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(student.age.toString()),
                            ),
                            title: Text(student.name),
                            subtitle: Text(student.birthday.toString()),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: 1,
                                    child: ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit'),
                                      onTap: () {
                                        // print('student.id ${student.id}');
                                        Navigator.pop(context);
                                        showBottomSheet(
                                          isEditMode: true,
                                          student: student,
                                          // id: student.id,
                                          // name: student.name,
                                          // age: student.age,
                                          // dob: student.birthday,
                                        );
                                      },
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 2,
                                    child: ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete'),
                                      onTap: () {
                                        // print('student.id ${student.id}');
                                        Navigator.pop(context);
                                        deleteStudent();
                                      },
                                    ),
                                  ),
                                ];
                              },
                            ),
                          );
                        }),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong!\nError: ${snapshot.error}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(isEditMode: false),
          tooltip: 'Add Student',
          child: const Icon(Icons.add),
        ),
      );

  Future<void> showBottomSheet({
    required bool isEditMode,
    Student? student,
  }) async {
    if (isEditMode && student != null) {
      nameController.text = student.name;
      ageController.text = student.age.toString();
      dobController.text = student.birthday.toIso8601String();
    }
    return showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(hintText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dobController,
              decoration: const InputDecoration(hintText: 'Birthday'),
              onTap: selectDate,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => isEditMode ? updateStudent() : createStudent(),
              child: isEditMode ? const Text('Update') : const Text('Create'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Student>> readStudents() =>
      studentsCollection.snapshots().map((snapshot) => snapshot.docs.map((doc) {
            print('studentId: ${doc.reference.id}');
            return Student.fromJson(doc.data());
          }).toList());
asdf
  Future<void> deleteStudent() async {
    studentsCollection.doc().delete().then((value) {
      debugPrint('Student deleted successfully');
    }).onError((error, _) {
      debugPrint(error.toString());
    });
  }

  void updateStudent() {
    final student = Student(
      name: nameController.text,
      age: int.parse(ageController.text),
      birthday: DateTime.parse(dobController.text),
    );
    final json = student.toJson();
    studentsCollection.doc().update(json).then((value) {
      debugPrint('Student updated successfully');
    });
    Navigator.pop(context);
    clearData();
  }

  void createStudent() {
    final student = Student(
      name: nameController.text,
      age: int.parse(ageController.text),
      birthday: DateTime.parse(dobController.text),
    );
    final json = student.toJson();
    studentsCollection.add(json).then((value) {
      debugPrint('New student added/created successfully');
    });
    Navigator.pop(context);
    clearData();
  }

  void clearData() {
    ageController.clear();
    dobController.clear();
    nameController.clear();
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dobController.text = picked.toString());
    }
  }
}
