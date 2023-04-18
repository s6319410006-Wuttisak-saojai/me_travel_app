//ทำงานกับ database : splite
//สร้าง database /table
//การเพิ่ม ลบ แก้ไข ค้นหา ดู ดึง จาก Table

import 'package:me_travel_app/model/user.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
//โค้ดคำสั่งสร้าง database
  static Future<Database> db() async {
    return openDatabase(
      'metravelappdb',
      version: 1,
      onCreate: (Database database, int version) async {
        await createTable(database);
      },
    );
  }

//โค้ดคำสั่ง table
  static Future<void> createTable(Database database) async {
    await database.execute("""
CREATE TABLE usertb(
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  fullname TEXT,
  email TEXT,
  phone TEXT,
  username TEXT,
  password TEXT,
  picture TEXT
)
    """);
  }

//โค้ดคำสั่งเพิ่ม ลบ แก้ไข ดู ดึงข้อมูลจาก Table (อันนี้จะเยอะหน่อย)
//เพิ่มข้อมูลลงตาราง usertb
  static Future<int> createUser(User user) async {
    //ติดต่อdatabase
    final db = await DBHelper.db();

    //เพิ่มข้อมูลลงใน Table ใน Database
    final id = await db.insert(
      'usertb',
      user.toMap(),
    );

    return id;
  }

//สร้างเมธตอด signin โดยข้อมูลจากตาราง usertb
  static Future<User?> signinUser(String? username, String? password) async {
    //ติดต่อ Database
    final db = await DBHelper.db();

    //เอาข้อมูล usernameม, password ที่ส่งมาไปดูว่ามีในตาราง usertb ไหม
    List<Map<String, dynamic>> result = await db.query(
      'usertb',
      where: 'username = ? AND Password = ?',
      whereArgs: [username, password],
    );
    //ตรวจสอบผลการดูข้อมูลว่ามีไหม

    if (result.length > 0) {
      return User.fromMap(result[0]);
    } else {
      return null;
    }
  }
}
