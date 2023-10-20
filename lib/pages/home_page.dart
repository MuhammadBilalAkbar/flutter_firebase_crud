import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_firebase_crud/models/student_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Reference
final studentRef = FirebaseFirestore.instance.collection('students');
/// Snapshots
final snapshots = studentRef.snapshots();
/// Reference to document
final studentDoc = studentRef.doc();

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dobController = TextEditingController();

  // final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StreamBuilder<List<Student>>(
          stream: getStudents(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.map(buildStudent).toList(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Something went wrong!'
                  '\n\nhasError: ${snapshot.hasError}'
                  '\n\nError: ${snapshot.error}'
                  '\n\nhasData: ${snapshot.hasData}'
                  '\n\ndata: ${snapshot.data}',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
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
                    decoration: InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: ageController,
                    decoration: InputDecoration(hintText: 'Age'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: dobController,
                    decoration: InputDecoration(hintText: 'Birthday'),
                    onTap: () => selectDate(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      addStudent();
                      ageController.clear();
                      dobController.clear();
                      nameController.clear();
                      debugPrint(
                          'New student `${studentDoc.id}` has been created successfully');
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          );
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addStudent() async {
    debugPrint(studentDoc.toString());
    debugPrint(studentDoc.id);
    final json = {
      'name': nameController.text,
      'age': int.parse(ageController.text),
      'birthday': DateTime.parse(dobController.text),
    };

    /// Create document and write data to Firebase
    // await studentDoc.set(json);
    // await studentRef.doc().set(json);
    await studentRef.add(json);

    /// Behind the scenes, .add(...) and .doc().set(...) are completely equivalent,
    /// so you can use whichever is more convenient.
  }

  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (picked != null) {
      setState(
        () => dobController.text = picked.toString(),
      );
    }
  }

  Stream<List<Student>> getStudents() {
    return studentRef.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => Student.fromJson(doc.data()),
            )
            .toList();
      },
    );
  }

  ListTile buildStudent(Student student) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(student.age.toString()),
      ),
      title: Text(student.name),
      // title: Text(student.id),
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
                  // studentRef.doc().update(student.id)
                  Navigator.pop(context);
                },
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  // studentDoc.delete();
                  studentRef
                      .doc(student.id)
                      .delete()
                      .then(
                        (value) => debugPrint(
                            'Student of id `${student.id}` has been deleted successfully'),
                      )
                      .catchError(
                          (error) => debugPrint('Delete failed: $error'));
                  ;
                },
              ),
            ),
          ];
        },
      ),
    );
  }
}
