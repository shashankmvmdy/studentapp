import 'dart:io';
import 'package:excel/excel.dart';
import 'database_helper.dart';

Future<void> importExcel(File file) async {
  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  final db = await DatabaseHelper.instance.database;

  for (var table in excel.tables.keys) {
    for (var row in excel.tables[table]!.rows.skip(1)) {
      await db.insert('Students', {
        'student_name': row[0]?.value,
        'roll_number': row[1]?.value,
        'course_name': row[2]?.value,
      });
    }
  }
}