import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'controllers/subject_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/note_controller.dart';
import 'controllers/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'views/splash/splash_screen.dart';

void main() {
  // التأكد من تهيئة كل أدوات Flutter الأساسية قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();

  // تفعيل SQLite عند تشغيل التطبيق على Windows / Linux / macOS
  // لأن sqflite العادي مخصص للعمل مباشرة على Android و iOS فقط
  if (Platform.isWindows ||
      Platform.isLinux ||
      Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory =
        databaseFactoryFfi;
  }

  // حقن التبعية (Dependency Injection) باستخدام Get.put
  // نقوم بتسجيل الـ Controllers هنا لتبقى في الذاكرة ويسهل الوصول إليها (عبر Get.find) من أي شاشة في التطبيق
  Get.put(ThemeController());
  Get.put(SubjectController());
  Get.put(TaskController());
  Get.put(NoteController());

  runApp(const UniStudyApp());
}

class UniStudyApp
    extends StatelessWidget {
  const UniStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدام
    //GetMaterialApp بدلاً من
    //MaterialApp لتفعيل ميزات State Management
    //والـ Navigation الخاصة بـ GetX
    return GetMaterialApp(
      title: 'UNISTUDY',
      debugShowCheckedModeBanner: false,

      // تفعيل اتجاه التطبيق من اليمين لليسار (RTL) لأن التطبيق موجه للطلاب العرب
      locale: const Locale('ar'),

      // إعدادات الثيمات (Light / Dark Mode) وربطها بالتصميم المخصص
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      home: const SplashScreen(),
    );
  }
}
