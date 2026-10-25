import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/subject_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';

class SubjectsScreen extends StatelessWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubjectController subjectController = Get.find<SubjectController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المواد الدراسية'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            _showSubjectSheet(
              context: context,
              controller: subjectController,
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة مادة'),
        ),
        body: Obx(
          () {
            if (subjectController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (subjectController.subjects.isEmpty) {
              return const _EmptySubjects();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: subjectController.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final subject = subjectController.subjects[index];

                return _SubjectCard(
                  subject: subject,
                  onEdit: () {
                    _showSubjectSheet(
                      context: context,
                      controller: subjectController,
                      subject: subject,
                    );
                  },
                  onDelete: () {
                    _confirmDeleteSubject(
                      controller: subjectController,
                      subject: subject,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // =========================
  // نافذة إضافة أو تعديل مادة
  // =========================
  void _showSubjectSheet({
    required BuildContext context,
    required SubjectController controller,
    SubjectModel? subject,
  }) {
    final bool isEdit = subject != null;

    final nameController = TextEditingController(text: subject?.name ?? '');
    final doctorController =
        TextEditingController(text: subject?.doctorName ?? '');
    final roomController = TextEditingController(text: subject?.room ?? '');

    final int selectedColor = subject?.color ?? AppColors.primary.value;

    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  isEdit ? 'تعديل المادة' : 'إضافة مادة جديدة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 18),

                _CustomTextField(
                  controller: nameController,
                  label: 'اسم المادة',
                  icon: Icons.menu_book_rounded,
                ),

                const SizedBox(height: 12),

                _CustomTextField(
                  controller: doctorController,
                  label: 'اسم الدكتور',
                  icon: Icons.person_rounded,
                ),

                const SizedBox(height: 12),

                _CustomTextField(
                  controller: roomController,
                  label: 'القاعة',
                  icon: Icons.location_on_rounded,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameController.text.trim();
                      final doctorName = doctorController.text.trim();
                      final room = roomController.text.trim();

                      if (name.isEmpty) {
                        Get.snackbar(
                          'تنبيه',
                          'يرجى إدخال اسم المادة',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final newSubject = SubjectModel(
                        id: subject?.id,
                        name: name,
                        doctorName: doctorName,
                        room: room,
                        color: selectedColor,
                      );

                      bool success;

                      if (isEdit && subject.id != null) {
                        success = await controller.updateSubject(
                          subject.id!,
                          newSubject,
                        );
                      } else {
                        success = await controller.addSubject(newSubject);
                      }

                      if (success) {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      isEdit ? 'حفظ التعديل' : 'حفظ المادة',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // =========================
  // تأكيد حذف المادة
  // =========================
  void _confirmDeleteSubject({
    required SubjectController controller,
    required SubjectModel subject,
  }) {
    Get.defaultDialog(
      title: 'حذف المادة',
      middleText: 'هل أنت متأكد من حذف مادة "${subject.name}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        if (subject.id != null) {
          final success = await controller.deleteSubject(subject.id!);

          if (success) {
            Get.back();
          }
        }
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final Color subjectColor = Color(subject.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: subjectColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: subjectColor,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  subject.doctorName.isEmpty
                      ? 'لا يوجد اسم دكتور'
                      : 'الدكتور: ${subject.doctorName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  subject.room.isEmpty
                      ? 'لا توجد قاعة'
                      : 'القاعة: ${subject.room}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.primary,
            ),
          ),

          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySubjects extends StatelessWidget {
  const _EmptySubjects();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 72,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواد بعد',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة أول مادة لتنظيم مهامك واختباراتك',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}