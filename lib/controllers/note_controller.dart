import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/database/database_helper.dart';
import '../models/note_model.dart';

// كلاس NoteController يرث من GetxController لإدارة الحالة (State Management)
// وفصل منطق العمل (Business Logic) عن واجهة المستخدم (UI)
class NoteController
    extends GetxController {
  // استخدام .obs يجعل المتغير "تفاعلياً" (Reactive)، أي عند تغير قيمته تتحدث الواجهة (Obx) تلقائياً
  final notes = <NoteModel>[].obs;
  // القائمة الأصلية التي تحتوي على كل الملاحظات
  final allNotes = <NoteModel>[].obs;

  // متغير تتبع حالة التحميل لتشغيل مؤشر التحميل (CircularProgressIndicator) في الواجهة
  var isLoading = false.obs;

  // الفلتر الحالي حسب المادة (null يعني كل الملاحظات، -1 تعني ملاحظات عامة بدون مادة)
  var selectedSubjectFilter =
      Rxn<int>();

  // عدد الملاحظات الكلي للإحصائيات أو الرئيسية
  var totalNotesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotes();
  }

  // =========================
  // جلب الملاحظات
  // =========================
  // نستخدم async / await لأن جلب البيانات من قاعدة البيانات عملية تأخذ وقتاً (Future)
  // ولا نريد تجميد واجهة المستخدم (UI Thread) أثناء الانتظار
  Future<void> fetchNotes() async {
    try {
      isLoading.value = true;
      final data = await DatabaseHelper
          .instance
          .getNotes();
      allNotes.value = data
          .map(
            (e) => NoteModel.fromMap(e),
          )
          .toList();
      totalNotesCount.value =
          await DatabaseHelper.instance
              .getNotesCount();
      _applyFilter();
    } catch (e) {
      debugPrint(
        'خطأ أثناء جلب الملاحظات: $e',
      );
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل الملاحظات',
        snackPosition:
            SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // تطبيق الفلتر
  // =========================
  void _applyFilter() {
    if (selectedSubjectFilter.value ==
        null) {
      // إظهار الكل
      notes.value = List.from(allNotes);
    } else if (selectedSubjectFilter
            .value ==
        -1) {
      // ملاحظات عامة (بدون مادة)
      notes.value = allNotes
          .where(
            (note) =>
                note.subjectId == null,
          )
          .toList();
    } else {
      // ملاحظات مرتبطة بمادة محددة
      notes.value = allNotes
          .where(
            (note) =>
                note.subjectId ==
                selectedSubjectFilter
                    .value,
          )
          .toList();
    }
  }

  // =========================
  // تغيير الفلتر
  // =========================
  void filterBySubject(int? subjectId) {
    selectedSubjectFilter.value =
        subjectId;
    _applyFilter();
  }

  // =========================
  // إضافة ملاحظة
  // =========================
  Future<void> addNote(
    NoteModel note,
  ) async {
    try {
      await DatabaseHelper.instance
          .insertNote(note.toMap());
      // نستدعي fetchNotes() مرة أخرى بعد الإضافة لتحديث القائمة وجلب البيانات الجديدة من قاعدة البيانات لتعكسها الواجهة فوراً
      await fetchNotes();
      Get.snackbar(
        'تم بنجاح ✅',
        'تمت إضافة الملاحظة',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء إضافة الملاحظة: $e',
      );
      Get.snackbar(
        'خطأ',
        'لم نتمكن من حفظ الملاحظة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // تعديل ملاحظة
  // =========================
  Future<void> updateNote(
    int id,
    NoteModel note,
  ) async {
    try {
      await DatabaseHelper.instance
          .updateNote(id, note.toMap());
      await fetchNotes();
      Get.snackbar(
        'تم التعديل ✅',
        'تم تحديث الملاحظة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء تعديل الملاحظة: $e',
      );
      Get.snackbar(
        'خطأ',
        'لم نتمكن من تعديل الملاحظة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // حذف ملاحظة
  // =========================
  Future<void> deleteNote(
    int id,
  ) async {
    try {
      await DatabaseHelper.instance
          .deleteNote(id);
      await fetchNotes();
      Get.snackbar(
        'تم الحذف 🗑️',
        'تم حذف الملاحظة',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء حذف الملاحظة: $e',
      );
      Get.snackbar(
        'خطأ',
        'فشل حذف الملاحظة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }
}
