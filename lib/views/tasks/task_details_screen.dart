import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/subject_controller.dart';
import '../../controllers/task_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import 'add_edit_task_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final SubjectController subjectController = Get.find<SubjectController>();

    final subject = subjectController.subjects.firstWhereOrNull(
      (s) => s.id == task.subjectId,
    );

    final bool isDone = task.status == 'مكتملة';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل المهمة'),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => AddEditTaskScreen(task: task, fromDetails: true));
              },
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'تعديل',
            ),
            IconButton(
              onPressed: () {
                _confirmDeleteTask(taskController, task);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              tooltip: 'حذف',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // البطاقة الرئيسية
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: isDone ? TextDecoration.lineThrough : null,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              color: _getStatusColor(task.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (task.description.isNotEmpty) ...[
                      Text(
                        'الوصف',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.menu_book_rounded,
                      title: 'المادة',
                      value: subject?.name ?? 'لا توجد مادة مرتبطة',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.category_rounded,
                      title: 'نوع المهمة',
                      value: task.type,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.calendar_month_rounded,
                      title: 'تاريخ التسليم',
                      value: _formatDate(task.dueDate),
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      context,
                      icon: Icons.flag_rounded,
                      title: 'الأولوية',
                      value: task.priority,
                      valueColor: _getPriorityColor(task.priority),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // بطاقة تاريخ الإنشاء
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'تم الإنشاء في: ${_formatDate(task.createdAt)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // زر إكمال المهمة
              if (!isDone)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      taskController.markTaskAsDone(task.id!);
                      Get.back();
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 28),
                    label: const Text(
                      'تعليم كمكتملة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'مكتملة') return AppColors.success;
    if (status == 'متأخرة') return AppColors.danger;
    return AppColors.warning;
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'عالية') return AppColors.danger;
    if (priority == 'متوسطة') return AppColors.warning;
    return AppColors.success;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _confirmDeleteTask(TaskController controller, TaskModel task) {
    Get.defaultDialog(
      title: 'حذف المهمة',
      middleText: 'هل أنت متأكد من حذف مهمة "${task.title}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        if (task.id != null) {
          await controller.deleteTask(task.id!);
          Get.back(); // إغلاق الدايلوج
          Get.back(); // العودة لشاشة المهام
        }
      },
    );
  }
}
