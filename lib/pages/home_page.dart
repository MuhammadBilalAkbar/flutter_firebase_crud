import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Reference
final studentColl = FirebaseFirestore.instance.collection('students');

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final dobController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: studentColl.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final age = snapshot.data!.docs[index]['age'];
                        final birthday = snapshot.data!.docs[index]['birthday'];
                        final name = snapshot.data!.docs[index]['name'];
                        final id = snapshot.data!.docs[index].id;
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(age.toString()),
                          ),
                          title: Text('$name `$id`'),
                          subtitle: Text((birthday as Timestamp)
                              .toDate()
                              .toIso8601String()),
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
                                      Navigator.pop(context);
                                      editStudent(
                                          id, name, age, birthday.toDate());
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    leading: const Icon(Icons.delete),
                                    title: const Text('Delete'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      deleteStudent(id);
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
                    'Something went wrong!'
                    '\n\nhasError: ${snapshot.hasError}'
                    '\n\nError: ${snapshot.error}'
                    '\n\nhasData: ${snapshot.hasData}'
                    '\n\ndata: ${snapshot.data}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addStudent,
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteStudent(String id) async {
    studentColl.doc(id).delete().then((value) {
      debugPrint('Student of id `$id` deleted successfully');
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
    });
  }

  Future<void> editStudent(
      String id, String name, int age, DateTime dob) async {
    nameController.text = name;
    ageController.text = age.toString();
    dobController.text = dob.toIso8601String();
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
              onPressed: () {
                studentColl.doc(id).update({
                  // 'age': ageController.text,
                  // 'name': nameController.text,
                  // 'birthday': dobController.text,
                  'name': nameController.text,
                  'age': int.parse(ageController.text),
                  'birthday': DateTime.parse(dobController.text),
                }).then((value) {
                  debugPrint('Student updated/edited successfully');
                });
                Navigator.pop(context);
                ageController.clear();
                dobController.clear();
                nameController.clear();
              },
              child: const Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addStudent() async {
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
              onPressed: () {
                studentColl.add({
                  'name': nameController.text,
                  'age': int.parse(ageController.text),
                  'birthday': DateTime.parse(dobController.text),
                }).then((value) {
                  debugPrint('New student added/created successfully');
                });
                // await studentColl.doc().set({json});
                /// Behind the scenes, .add(...) and .doc().set(...) are completely equivalent,
                /// so you can use whichever is more convenient.
                Navigator.pop(context);
                ageController.clear();
                dobController.clear();
                nameController.clear();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
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
}
