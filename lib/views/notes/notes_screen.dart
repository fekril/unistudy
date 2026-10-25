import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'
    hide TextDirection;

import '../../controllers/note_controller.dart';
import '../../controllers/subject_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../models/note_model.dart';
import 'add_edit_note_screen.dart';
import 'note_details_screen.dart';

class NotesScreen
    extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController
    noteController =
        Get.find<NoteController>();
    final SubjectController
    subjectController =
        Get.find<SubjectController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الملاحظات الدراسية',
          ),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(
                  70,
                ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
              child: Obx(() {
                return DropdownButtonFormField<
                  int?
                >(
                  value: noteController
                      .selectedSubjectFilter
                      .value,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal:
                              16,
                        ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).cardColor,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                      borderSide:
                          BorderSide
                              .none,
                    ),
                    prefixIcon: const Icon(
                      Icons
                          .filter_list_rounded,
                    ),
                  ),
                  hint: const Text(
                    'تصفية حسب المادة',
                  ),
                  items: [
                    const DropdownMenuItem<
                      int?
                    >(
                      value: null,
                      child: Text(
                        'الكل',
                      ),
                    ),
                    const DropdownMenuItem<
                      int?
                    >(
                      value: -1,
                      child: Text(
                        'ملاحظات عامة',
                      ),
                    ),
                    ...subjectController
                        .subjects
                        .map((subject) {
                          return DropdownMenuItem<
                            int?
                          >(
                            value:
                                subject
                                    .id,
                            child: Text(
                              subject
                                  .name,
                            ),
                          );
                        }),
                  ],
                  onChanged: (value) {
                    noteController
                        .filterBySubject(
                          value,
                        );
                  },
                );
              }),
            ),
          ),
        ),
        floatingActionButton:
            FloatingActionButton.extended(
              onPressed: () {
                Get.to(
                  () =>
                      const AddEditNoteScreen(),
                );
              },
              icon: const Icon(
                Icons.edit_note_rounded,
              ),
              label: const Text(
                'إضافة ملاحظة',
              ),
            ),
        body: Obx(() {
          if (noteController
              .isLoading
              .value) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (noteController
              .notes
              .isEmpty) {
            return const Center(
              child: Text(
                'لا توجد ملاحظات مطابقة',
              ),
            );
          }

          return ListView.separated(
            padding:
                const EdgeInsets.all(
                  18,
                ),
            itemCount: noteController
                .notes
                .length,
            separatorBuilder: (_, __) =>
                const SizedBox(
                  height: 12,
                ),
            itemBuilder: (context, index) {
              final note =
                  noteController
                      .notes[index];

              final subject =
                  subjectController
                      .subjects
                      .firstWhereOrNull(
                        (s) =>
                            s.id ==
                            note.subjectId,
                      );

              return _NoteCard(
                note: note,
                subjectName:
                    subject?.name,
                onTap: () {
                  Get.to(
                    () =>
                        NoteDetailsScreen(
                          note: note,
                        ),
                  );
                },
                onEdit: () {
                  Get.to(
                    () =>
                        AddEditNoteScreen(
                          note: note,
                        ),
                  );
                },
                onDelete: () {
                  _confirmDeleteNote(
                    noteController,
                    note,
                  );
                },
              );
            },
          );
        }),
      ),
    );
  }

  void _confirmDeleteNote(
    NoteController controller,
    NoteModel note,
  ) {
    Get.defaultDialog(
      title: 'حذف الملاحظة',
      middleText:
          'هل أنت متأكد من حذف الملاحظة "${note.title}"؟',
      textCancel: 'إلغاء',
      textConfirm: 'حذف',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.danger,
      onConfirm: () async {
        if (note.id != null) {
          await controller.deleteNote(
            note.id!,
          );
          Get.back();
        }
      },
    );
  }
}

class _NoteCard
    extends StatelessWidget {
  final NoteModel note;
  final String? subjectName;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    this.subjectName,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(
          16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).cardColor,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey
                .withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(
                    alpha: 0.04,
                  ),
              blurRadius: 12,
              offset: const Offset(
                0,
                6,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                  decoration: BoxDecoration(
                    color: AppColors
                        .primary
                        .withValues(
                          alpha: 0.1,
                        ),
                    borderRadius:
                        BorderRadius.circular(
                          10,
                        ),
                  ),
                  child: Text(
                    subjectName ??
                        'ملاحظة عامة',
                    style:
                        const TextStyle(
                          color: AppColors
                              .primary,
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              note.content,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons
                      .access_time_rounded,
                  size: 14,
                  color:
                      Colors.grey[400],
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  _formatDate(
                    note.createdAt,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors
                        .grey[500],
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons
                        .edit_note_rounded,
                  ),
                  color:
                      AppColors.primary,
                  iconSize: 22,
                  constraints:
                      const BoxConstraints(),
                  padding:
                      const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons
                        .delete_outline_rounded,
                  ),
                  color:
                      AppColors.danger,
                  iconSize: 22,
                  constraints:
                      const BoxConstraints(),
                  padding:
                      EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(
    String dateString,
  ) {
    try {
      final date = DateTime.parse(
        dateString,
      );
      return DateFormat(
        'yyyy/MM/dd hh:mm a',
      ).format(date);
    } catch (e) {
      return dateString;
    }
  }
}
