import 'package:flutter/material.dart';
import 'database_helper.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {

  List<Map<String, dynamic>> students = [];
  int currentIndex = 0;
  Set<int> absentees = {};

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future loadStudents() async {
    final db = await DatabaseHelper.instance.database;
    final data = await db.query('Students');
    setState(() => students = data);
  }

  void markAbsent(int id) {
    absentees.add(id);
  }

  void nextStudent(bool isPresent) {
    if (!isPresent) {
      markAbsent(students[currentIndex]['id']);
    }

    if (currentIndex < students.length - 1) {
      setState(() => currentIndex++);
    } else {
      saveAbsentees();
    }
  }

  Future saveAbsentees() async {
    final db = await DatabaseHelper.instance.database;

    for (var id in absentees) {
      await db.insert('Absence', {
        'date_time': DateTime.now().toString(),
        'student_id': id
      });
    }

    printAbsentees();
  }

  void printAbsentees() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery('''
      SELECT student_name FROM Students
      INNER JOIN Absence ON Students.id = Absence.student_id
    ''');

    print("Absentees List:");
    result.forEach((e) => print(e['student_name']));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];

                Color color;
                if (index == currentIndex) {
                  color = Colors.yellow; // current
                } else if (absentees.contains(student['id'])) {
                  color = Colors.red; // absent
                } else {
                  color = Colors.white;
                }

                return Container(
                  color: color,
                  child: ListTile(
                    title: Text(student['student_name']),
                    subtitle: Text(student['roll_number']),
                    trailing: Switch(
                      value: absentees.contains(student['id']),
                      onChanged: (val) {
                        setState(() {
                          if (val)
                            absentees.add(student['id']);
                          else
                            absentees.remove(student['id']);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text("Present"),
                onPressed: () => nextStudent(true),
              ),
              ElevatedButton(
                child: Text("Absent"),
                onPressed: () => nextStudent(false),
              ),
            ],
          )
        ],
      ),
    );
  }
}