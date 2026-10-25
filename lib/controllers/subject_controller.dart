import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/database/database_helper.dart';
import '../models/subject_model.dart';

// SubjectController: وراثة GetxController تساعدنا على ربط منطق العمل (البيانات) بالشاشات وإدارة التغييرات بسهولة
class SubjectController
    extends GetxController {
  // المتغير التفاعلي (.obs) لقائمة المواد. أي شاشة تستمع لهذا المتغير (Obx) ستتحدث تلقائياً إذا أضفنا مادة جديدة
  // قائمة المواد الدراسية
  final subjects = <SubjectModel>[].obs;

  // حالة التحميل
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // تحميل المواد عند بداية تشغيل الكنترولر
    fetchSubjects();
  }

  // =========================
  // جلب جميع المواد
  // =========================
  // نستخدم async لأن العملية غير متزامنة وتحتاج انتظار (await) الرد من قاعدة البيانات دون تجميد التطبيق
  Future<void> fetchSubjects() async {
    try {
      isLoading.value =
          true; // تفعيل حالة التحميل

      final data = await DatabaseHelper
          .instance
          .getSubjects();

      subjects.assignAll(
        data
            .map(
              (item) =>
                  SubjectModel.fromMap(
                    item,
                  ),
            )
            .toList(),
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء جلب المواد: $e',
      );

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب المواد',
        snackPosition:
            SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // إضافة مادة جديدة
  // =========================
  Future<bool> addSubject(
    SubjectModel subject,
  ) async {
    try {
      final id = await DatabaseHelper
          .instance
          .insertSubject(
            subject.toMap(),
          );

      debugPrint(
        'تم حفظ المادة بنجاح، رقم المادة: $id',
      );

      // بعد الإضافة، نستدعي fetchSubjects() ليقوم بجلب القائمة كاملة ومحدثة لتعكسها واجهة المستخدم على الفور
      await fetchSubjects();

      Get.snackbar(
        'تم',
        'تمت إضافة المادة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      debugPrint(
        'خطأ أثناء إضافة المادة: $e',
      );

      Get.snackbar(
        'خطأ',
        'فشل إضافة المادة: $e',
        snackPosition:
            SnackPosition.TOP,
      );

      return false;
    }
  }

  // =========================
  // حذف مادة
  // =========================
  Future<bool> deleteSubject(
    int id,
  ) async {
    try {
      await DatabaseHelper.instance
          .deleteSubject(id);

      await fetchSubjects();

      Get.snackbar(
        'تم',
        'تم حذف المادة',
        snackPosition:
            SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      debugPrint(
        'خطأ أثناء حذف المادة: $e',
      );

      Get.snackbar(
        'خطأ',
        'فشل حذف المادة: $e',
        snackPosition:
            SnackPosition.TOP,
      );

      return false;
    }
  }

  // =========================
  // تعديل مادة
  // =========================
  Future<bool> updateSubject(
    int id,
    SubjectModel subject,
  ) async {
    try {
      await DatabaseHelper.instance
          .updateSubject(
            id,
            subject.toMap(),
          );

      await fetchSubjects();

      Get.snackbar(
        'تم',
        'تم تعديل المادة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );

      return true;
    } catch (e) {
      debugPrint(
        'خطأ أثناء تعديل المادة: $e',
      );

      Get.snackbar(
        'خطأ',
        'فشل تعديل المادة: $e',
        snackPosition:
            SnackPosition.TOP,
      );

      return false;
    }
  }
}
