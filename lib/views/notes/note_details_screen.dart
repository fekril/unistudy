import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/note_controller.dart';
import '../../controllers/subject_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import 'add_edit_note_screen.dart';

class NoteDetailsScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final NoteController noteController = Get.find<NoteController>();
    final SubjectController subjectController = Get.find<SubjectController>();

    final subject = subjectController.subjects.firstWhereOrNull(
      (s) => s.id == note.subjectId,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الملاحظة'),
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => AddEditNoteScreen(note: note, fromDetails: true));
              },
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: 'تعديل',
            ),
            IconButton(
              onPressed: () {
                _confirmDeleteNote(noteController, note);
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
                    Text(
                      note.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subject?.name ?? 'ملاحظة عامة',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      note.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // تواريخ الملاحظة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.grey, size: 18),
                        const SizedBox(width: 12),
                        Text(
                          'تاريخ الإنشاء: ${_formatDate(note.createdAt)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    if (note.updatedAt != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.update_rounded, color: Colors.grey, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'آخر تعديل: ${_formatDate(note.updatedAt!)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy/MM/dd hh:mm a').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _confirmDeleteNote(NoteController controller, NoteModel note) {
    Get.defaultDialog(
      title: 'حذف الملاحظة',
      middleText: 'هل أنت متأكد من حذف الملاحظة "${note.title}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        if (note.id != null) {
          await controller.deleteNote(note.id!);
          Get.back(); // إغلاق الدايلوج
          Get.back(); // العودة لشاشة الملاحظات
        }
      },
    );
  }
}
