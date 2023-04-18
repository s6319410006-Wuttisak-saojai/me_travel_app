// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:me_travel_app/model/user.dart';
import 'package:me_travel_app/utils/db_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class RegisterUI extends StatefulWidget {
  const RegisterUI({super.key});

  @override
  State<RegisterUI> createState() => _RegisterUIState();
}

class _RegisterUIState extends State<RegisterUI> {
  bool passwordShowFlag = true;

  //ตัวคุม Textfield
  TextEditingController fullnameCtrl = TextEditingController(text: '');
  TextEditingController emailCtrl = TextEditingController(text: '');
  TextEditingController phoneCtrl = TextEditingController(text: '');
  TextEditingController usernameCtrl = TextEditingController(text: '');
  TextEditingController passwordCtrl = TextEditingController(text: '');

  //ตัวแปลรูปที่มาจาก Gallery
  File? imgFile;

  //สร้างตัวเก็บรูป
  String pictureDir = '';

  //เปิดกล้อง
  selectImageFromGallery() async {
    //เลือกรูปจาก Gallery
    XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img == null) return;

    //เปลี่ยนชื่อรูป
    Directory directory = await getApplicationDocumentsDirectory();
    String newFileDir = directory.path + Uuid().v4();
    pictureDir = newFileDir; //กำหนดที่อยู่

    //แสดงรูปที่หน้าจอ
    File imgFileNew = File(newFileDir);
    await imgFileNew.writeAsBytes(File(img.path).readAsBytesSync());
    setState(() {
      imgFile = imgFileNew;
    });
  }

  //เปิด Gallery
  selectImageFromCamera() async {
    //เลือกรูปจาก Gallery
    XFile? img = await ImagePicker().pickImage(source: ImageSource.camera);

    if (img == null) return;

    //เปลี่ยนชื่อรูป
    Directory directory = await getApplicationDocumentsDirectory();
    String newFileDir = directory.path + Uuid().v4();
    pictureDir = newFileDir; //กำหนดที่อยู่

    //แสดงรูปที่หน้าจอ
    File imgFileNew = File(newFileDir);
    await imgFileNew.writeAsBytes(File(img.path).readAsBytesSync());
    setState(() {
      imgFile = imgFileNew;
    });
  }

  //สร้าง method แสดง dialog
  showWarningDialog(BuildContext context, String msg) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'คำเตือน',
            style: GoogleFonts.kanit(),
          ),
          content: Text(
            msg,
            style: GoogleFonts.kanit(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.kanit(),
              ),
            ),
          ],
        );
      },
    );
  }

//Method บันทึกข้อมูล User to database
  saveUserToDB(context) async {
    int id = await DBHelper.createUser(
      User(
        fullname: fullnameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        username: usernameCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
        picture: pictureDir,
      ),
    );

    if (id != 0) {
      showCompleteDialog(context, 'บันทึกข้อมูลเรียบร้อยแล้ว').then((value) {
        Navigator.pop(context);
      });
    } else {
      showCompleteDialog(context, 'มีข้อผิดพลาดเกิดขึ้นในการบันทึกข้อมูล');
    }
  }

  //แสดงข้อความเสร็จสิ้น
  showCompleteDialog(BuildContext context, String msg) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'ผลการทำงาน',
            style: GoogleFonts.kanit(),
          ),
          content: Text(
            msg,
            style: GoogleFonts.kanit(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.kanit(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //var visibility_off;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          'ลงทะเบียนเข้าใช้งาน',
          style: GoogleFonts.kanit(),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  imgFile == null
                      ? CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: MediaQuery.of(context).size.width * 0.20,
                          child: ClipOval(
                            child: Image.asset('assets/images/logo.png'),
                          ),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: MediaQuery.of(context).size.width * 0.20,
                          backgroundImage: FileImage(
                            imgFile!,
                          ),
                        ),
                  IconButton(
                    onPressed: () {
                      //แสดง modalButtom เลือก Gallery/Camera
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    selectImageFromCamera();
                                    Navigator.pop(context);
                                  },
                                  leading: Icon(FontAwesomeIcons.camera),
                                  title: Text('ถ่ายรูป'),
                                ),
                                Divider(),
                                ListTile(
                                  onTap: () {
                                    selectImageFromGallery();
                                    Navigator.pop(context);
                                  },
                                  leading: Icon(Icons.camera),
                                  title: Text('เลือกรูป'),
                                ),
                              ],
                            );
                          });
                    },
                    icon: Icon(FontAwesomeIcons.cameraRetro),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextField(
                  controller: fullnameCtrl,
                  style: GoogleFonts.kanit(),
                  decoration: InputDecoration(
                    labelText: 'ชื่อ-สกุล',
                    labelStyle: GoogleFonts.kanit(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'ป้อนชื่อและนามสกุล',
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.kanit(),
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    labelStyle: GoogleFonts.kanit(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'ป้อนอีเมล',
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.kanit(),
                  decoration: InputDecoration(
                    labelText: 'เบอร์โทร',
                    labelStyle: GoogleFonts.kanit(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'ป้อนเบอร์โทร',
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextField(
                  controller: usernameCtrl,
                  style: GoogleFonts.kanit(),
                  decoration: InputDecoration(
                    labelText: 'ชื่อผู้ใช้',
                    labelStyle: GoogleFonts.kanit(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'ป้อนชื่อผู้ใช้',
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.1,
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.width * 0.1,
                ),
                child: TextField(
                  controller: passwordCtrl,
                  obscureText: passwordShowFlag,
                  style: GoogleFonts.kanit(),
                  decoration: InputDecoration(
                    labelText: 'รหัสผ่าน',
                    labelStyle: GoogleFonts.kanit(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: 'ป้อนรหัสผ่าน',
                    hintStyle: GoogleFonts.kanit(
                      color: Colors.grey[400],
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          if (passwordShowFlag == true) {
                            passwordShowFlag == false;
                          } else {
                            passwordShowFlag == true;
                          }
                        });
                      },
                      icon: Icon(
                        passwordShowFlag == true
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  //validate หน้าจอ คือ ตรวจสอบว่าป้อนครบไหม
                  //หากยังไม่ครบ แสดง Error เตือน
                  //ป้อนครบแล้ว กลับไปหน้า Login
                  if (fullnameCtrl.text.trim().length == 0) {
                    showWarningDialog(context, 'ป้อนชื่อ-สกุลด้วย...');
                  } else if (emailCtrl.text.trim().length == 0) {
                    showWarningDialog(context, 'ป้อนอีเมลด้วย...');
                  } else if (phoneCtrl.text.trim().length == 0) {
                    showWarningDialog(context, 'ป้อนเบอร์โทรด้วย...');
                  } else if (usernameCtrl.text.trim().length == 0) {
                    showWarningDialog(context, 'ป้อนชื่อผู้ใช้ด้วย...');
                  } else if (passwordCtrl.text.trim().length == 0) {
                    showWarningDialog(context, 'ป้อนรหัสด้วย...');
                  } else if (pictureDir.length == 0) {
                    showWarningDialog(context, 'เลือกรูป-ถ่ายรูปด้วยด้วย...');
                  } else {
                    //ผ่านพร้อมลง Database
                    saveUserToDB(context);
                  }
                },
                child: Text(
                  'ลงทะเบียน',
                  style: GoogleFonts.kanit(),
                ),
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      MediaQuery.of(context).size.width * 0.7,
                      MediaQuery.of(context).size.width * 0.125,
                    ),
                    backgroundColor: Colors.blueGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
