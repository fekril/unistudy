import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/database/database_helper.dart';
import '../models/task_model.dart';

class TaskController
    extends GetxController {
  // كل هذه المتغيرات تنتهي بـ .obs لتكون "تفاعلية"، وستحدث الشاشات المتصلة بها عبر (Obx) عند تغير قيمتها
  // قائمة المهام الأصلية (كل المهام)
  final allTasks = <TaskModel>[].obs;

  // قائمة المهام المعروضة بعد الفلترة
  final tasks = <TaskModel>[].obs;

  // حالة التحميل
  var isLoading = false.obs;

  // الفلتر الحالي حسب الحالة
  var selectedStatusFilter = 'الكل'.obs;

  // الفلتر الحالي حسب المادة
  var selectedSubjectFilter =
      Rxn<int>();

  // ========== الإحصائيات ==========
  var totalTasks = 0.obs;
  var completedTasks = 0.obs;
  var pendingTasks = 0.obs;
  var overdueTasks = 0.obs;
  var subjectsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // بمجرد إنشاء هذا الـ Controller، نقوم بجلب المهام لكي تظهر للمستخدم فور دخوله التطبيق
    fetchTasks();
  }

  // =========================
  // جلب المهام وتحديث الإحصائيات
  // =========================
  Future<void> fetchTasks() async {
    try {
      isLoading.value = true;

      // فحص وتحديث المهام المتأخرة تلقائياً
      await _checkAndUpdateOverdueTasks();

      final data = await DatabaseHelper
          .instance
          .getTasks();
      allTasks.value = data
          .map(
            (e) => TaskModel.fromMap(e),
          )
          .toList();

      // تحديث الإحصائيات
      await _refreshStatistics();

      // تطبيق الفلتر الحالي
      _applyFilters();
    } catch (e) {
      debugPrint(
        'خطأ أثناء جلب المهام: $e',
      );
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء جلب المهام',
        snackPosition:
            SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // تحديث حالة المهام إلى "متأخرة" إذا تجاوزت الوقت
  // =========================
  Future<void>
  _checkAndUpdateOverdueTasks() async {
    try {
      final data = await DatabaseHelper
          .instance
          .getTasks();
      final now = DateTime.now();
      final today = DateTime(
        now.year,
        now.month,
        now.day,
      );

      for (var map in data) {
        if (map['status'] ==
            'قيد التنفيذ') {
          try {
            final dueDateStr =
                map['dueDate'];
            final dueDate =
                DateTime.parse(
                  dueDateStr,
                );
            final taskDate = DateTime(
              dueDate.year,
              dueDate.month,
              dueDate.day,
            );

            if (taskDate.isBefore(
              today,
            )) {
              // تعديل الحالة إلى متأخرة
              final updatedMap =
                  Map<
                    String,
                    dynamic
                  >.from(map);
              updatedMap['status'] =
                  'متأخرة';
              await DatabaseHelper
                  .instance
                  .updateTask(
                    map['id'],
                    updatedMap,
                  );
            }
          } catch (e) {
            // تجاهل أخطاء تحويل التاريخ
          }
        }
      }
    } catch (e) {
      debugPrint(
        'خطأ أثناء التحقق من المهام المتأخرة: $e',
      );
    }
  }

  // =========================
  // تحديث الإحصائيات من قاعدة البيانات
  // =========================
  Future<void>
  _refreshStatistics() async {
    try {
      subjectsCount.value =
          await DatabaseHelper.instance
              .getSubjectsCount();
      totalTasks.value =
          await DatabaseHelper.instance
              .getTasksCount();
      completedTasks.value =
          await DatabaseHelper.instance
              .getTasksCountByStatus(
                'مكتملة',
              );
      overdueTasks.value =
          await DatabaseHelper.instance
              .getTasksCountByStatus(
                'متأخرة',
              );
      pendingTasks.value =
          await DatabaseHelper.instance
              .getTasksCountByStatus(
                'قيد التنفيذ',
              );
    } catch (e) {
      debugPrint(
        'خطأ أثناء تحديث الإحصائيات: $e',
      );
    }
  }

  // =========================
  // تطبيق الفلاتر على القائمة
  // =========================
  void _applyFilters() {
    List<TaskModel> filtered =
        List.from(allTasks);

    // فلتر حسب الحالة
    if (selectedStatusFilter.value !=
        'الكل') {
      filtered = filtered
          .where(
            (task) =>
                task.status ==
                selectedStatusFilter
                    .value,
          )
          .toList();
    }

    // فلتر حسب المادة
    if (selectedSubjectFilter.value !=
        null) {
      filtered = filtered
          .where(
            (task) =>
                task.subjectId ==
                selectedSubjectFilter
                    .value,
          )
          .toList();
    }

    tasks.value = filtered;
  }

  // =========================
  // تغيير فلتر الحالة
  // =========================
  void filterByStatus(String status) {
    selectedStatusFilter.value = status;
    _applyFilters();
  }

  // =========================
  // تغيير فلتر المادة
  // =========================
  void filterBySubject(int? subjectId) {
    selectedSubjectFilter.value =
        subjectId;
    _applyFilters();
  }

  // =========================
  // إضافة مهمة
  // =========================
  Future<void> addTask(
    TaskModel task,
  ) async {
    try {
      await DatabaseHelper.instance
          .insertTask(task.toMap());
      await fetchTasks();

      Get.snackbar(
        'تم بنجاح ✅',
        'تمت إضافة المهمة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء إضافة المهمة: $e',
      );
      Get.snackbar(
        'خطأ',
        'فشل إضافة المهمة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // حذف مهمة
  // =========================
  Future<void> deleteTask(
    int id,
  ) async {
    try {
      await DatabaseHelper.instance
          .deleteTask(id);
      await fetchTasks();

      Get.snackbar(
        'تم ✅',
        'تم حذف المهمة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء حذف المهمة: $e',
      );
      Get.snackbar(
        'خطأ',
        'فشل حذف المهمة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // تعديل مهمة
  // =========================
  Future<void> updateTask(
    int id,
    TaskModel task,
  ) async {
    try {
      await DatabaseHelper.instance
          .updateTask(id, task.toMap());
      await fetchTasks();

      Get.snackbar(
        'تم ✅',
        'تم تعديل المهمة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء تعديل المهمة: $e',
      );
      Get.snackbar(
        'خطأ',
        'فشل تعديل المهمة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // تعليم المهمة كمكتملة
  // =========================
  Future<void> markTaskAsDone(
    int id,
  ) async {
    try {
      await DatabaseHelper.instance
          .markTaskAsDone(id);
      await fetchTasks();

      Get.snackbar(
        'أحسنت! 🎉',
        'تم إكمال المهمة بنجاح',
        snackPosition:
            SnackPosition.TOP,
      );
    } catch (e) {
      debugPrint(
        'خطأ أثناء تحديث المهمة: $e',
      );
      Get.snackbar(
        'خطأ',
        'فشل تحديث المهمة',
        snackPosition:
            SnackPosition.TOP,
      );
    }
  }

  // =========================
  // جلب الإحصائيات كـ Future (لاستخدام FutureBuilder)
  // =========================
  Future<Map<String, int>>
  getStatistics() async {
    final subjects =
        await DatabaseHelper.instance
            .getSubjectsCount();
    final total = await DatabaseHelper
        .instance
        .getTasksCount();
    final completed =
        await DatabaseHelper.instance
            .getTasksCountByStatus(
              'مكتملة',
            );
    final overdue = await DatabaseHelper
        .instance
        .getTasksCountByStatus(
          'متأخرة',
        );
    final pending = await DatabaseHelper
        .instance
        .getTasksCountByStatus(
          'قيد التنفيذ',
        );

    return {
      'subjects': subjects,
      'total': total,
      'completed': completed,
      'overdue': overdue,
      'pending': pending,
    };
  }
}
