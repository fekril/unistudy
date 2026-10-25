import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/subject_controller.dart';
import '../../controllers/task_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task_model.dart';
import 'add_edit_task_screen.dart';
import 'task_details_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();
    final SubjectController subjectController = Get.find<SubjectController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المهام'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                // فلتر حسب المادة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Obx(() {
                    return DropdownButtonFormField<int?>(
                      value: taskController.selectedSubjectFilter.value,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.filter_alt_rounded),
                      ),
                      hint: const Text('تصفية حسب المادة'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('كل المواد'),
                        ),
                        ...subjectController.subjects.map((subject) {
                          return DropdownMenuItem<int?>(
                            value: subject.id,
                            child: Text(subject.name),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        taskController.filterBySubject(value);
                      },
                    );
                  }),
                ),
                // فلتر حسب الحالة
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Obx(() {
                    return Row(
                      children: [
                        _FilterChip(
                          label: 'الكل',
                          isSelected: taskController.selectedStatusFilter.value == 'الكل',
                          onTap: () => taskController.filterByStatus('الكل'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'قيد التنفيذ',
                          isSelected: taskController.selectedStatusFilter.value == 'قيد التنفيذ',
                          onTap: () => taskController.filterByStatus('قيد التنفيذ'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'مكتملة',
                          isSelected: taskController.selectedStatusFilter.value == 'مكتملة',
                          onTap: () => taskController.filterByStatus('مكتملة'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'متأخرة',
                          isSelected: taskController.selectedStatusFilter.value == 'متأخرة',
                          onTap: () => taskController.filterByStatus('متأخرة'),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => const AddEditTaskScreen());
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مهمة'),
        ),
        body: Obx(
          () {
            if (taskController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskController.tasks.isEmpty) {
              return const Center(
                child: Text('لا توجد مهام مطابقة'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: taskController.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = taskController.tasks[index];
                
                // البحث عن اسم المادة
                final subject = subjectController.subjects.firstWhereOrNull(
                  (s) => s.id == task.subjectId,
                );

                return _TaskCard(
                  task: task,
                  subjectName: subject?.name,
                  onTap: () {
                    Get.to(() => TaskDetailsScreen(task: task));
                  },
                  onEdit: () {
                    Get.to(() => AddEditTaskScreen(task: task));
                  },
                  onDelete: () {
                    _confirmDeleteTask(taskController, task);
                  },
                  onDone: () {
                    taskController.markTaskAsDone(task.id!);
                  },
                );
              },
            );
          },
        ),
      ),
    );
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
          Get.back();
        }
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final String? subjectName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDone;

  const _TaskCard({
    required this.task,
    this.subjectName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = task.status == 'مكتملة';
    final bool isOverdue = task.status == 'متأخرة';

    Color statusColor = AppColors.warning;
    if (isDone) statusColor = AppColors.success;
    if (isOverdue) statusColor = AppColors.danger;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border(
            right: BorderSide(
              color: statusColor,
              width: 6,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                            ),
                      ),
                      const SizedBox(height: 4),
                      if (subjectName != null)
                        Text(
                          'المادة: $subjectName',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(task.dueDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.flag_rounded, size: 14, color: _getPriorityColor(task.priority)),
                const SizedBox(width: 4),
                Text(
                  task.priority,
                  style: TextStyle(fontSize: 12, color: _getPriorityColor(task.priority)),
                ),
                const SizedBox(width: 12),
                Icon(Icons.label_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  task.type,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDone)
                  IconButton(
                    onPressed: onDone,
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    color: AppColors.success,
                    tooltip: 'إكمال',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: AppColors.primary,
                  tooltip: 'تعديل',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppColors.danger,
                  tooltip: 'حذف',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'عالية':
        return AppColors.danger;
      case 'متوسطة':
        return AppColors.warning;
      case 'منخفضة':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
