import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/note_controller.dart';
import '../../controllers/subject_controller.dart';
import '../../models/note_model.dart';

class AddEditNoteScreen
    extends StatefulWidget {
  final NoteModel? note;
  final bool fromDetails;

  const AddEditNoteScreen({
    super.key,
    this.note,
    this.fromDetails = false,
  });

  @override
  State<AddEditNoteScreen>
  createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState
    extends State<AddEditNoteScreen> {
  final NoteController noteController =
      Get.find<NoteController>();
  final SubjectController
  subjectController =
      Get.find<SubjectController>();

  final _formKey =
      GlobalKey<FormState>();

  late TextEditingController
  _titleController;
  late TextEditingController
  _contentController;

  int? _selectedSubjectId;

  @override
  void initState() {
    super.initState();
    final note = widget.note;

    _titleController =
        TextEditingController(
          text: note?.title ?? '',
        );
    _contentController =
        TextEditingController(
          text: note?.content ?? '',
        );

    if (note != null) {
      _selectedSubjectId =
          note.subjectId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    FocusScope.of(
      context,
    ).unfocus(); // إخفاء الكيبورد

    if (_formKey.currentState!
        .validate()) {
      final now = DateTime.now()
          .toIso8601String();
      final note = NoteModel(
        id: widget.note?.id,
        subjectId: _selectedSubjectId,
        title: _titleController.text
            .trim(),
        content: _contentController.text
            .trim(),
        createdAt:
            widget.note?.createdAt ??
            now,
        updatedAt: widget.note != null
            ? now
            : null,
      );

      if (widget.note == null) {
        await noteController.addNote(
          note,
        );
        Navigator.pop(context);
      } else {
        await noteController.updateNote(
          note.id!,
          note,
        );
        if (widget.fromDetails) {
          Get.back(); // Pop AddEdit screen
          // Get.back(); // Pop Details screen
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      Get.snackbar(
        'تنبيه',
        'يرجى كتابة عنوان ومحتوى الملاحظة',
        snackPosition:
            SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;

    // استخدام Directionality مع TextDirection.rtl لإجبار الشاشة على أن تكون من اليمين لليسار لأن التطبيق باللغة العربية
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEdit
                ? 'تعديل الملاحظة'
                : 'إضافة ملاحظة جديدة',
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom:
                  MediaQuery.of(
                    context,
                  ).viewInsets.bottom +
                  20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                _buildLabel(
                  'عنوان الملاحظة',
                ),
                TextFormField(
                  controller:
                      _titleController,
                  textInputAction:
                      TextInputAction
                          .next,
                  decoration:
                      _inputDecoration(
                        'مثال: قوانين هامة في الفيزياء',
                      ),
                  // منع الرموز الغريبة ولكن السماح بالأرقام
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(
                      RegExp(
                        r'[!@#\$%^&\*\(\)_\+=\[\]\{\};:"\\|<>\?]',
                      ),
                    ),
                  ],
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'عنوان الملاحظة مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),

                _buildLabel(
                  'المادة الدراسية (اختياري)',
                ),
                DropdownButtonFormField<
                  int?
                >(
                  value:
                      _selectedSubjectId,
                  decoration:
                      _inputDecoration(
                        'اختر المادة',
                      ),
                  items: [
                    const DropdownMenuItem<
                      int?
                    >(
                      value: null,
                      child: Text(
                        'ملاحظة عامة (بدون مادة)',
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
                    setState(() {
                      _selectedSubjectId =
                          value;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),

                _buildLabel(
                  'محتوى الملاحظة',
                ),
                TextFormField(
                  controller:
                      _contentController,
                  maxLines: 12,
                  textInputAction:
                      TextInputAction
                          .newline,
                  decoration:
                      _inputDecoration(
                        'اكتب الملاحظات هنا...',
                      ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'محتوى الملاحظة مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 32,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              16,
                            ),
                      ),
                    ),
                    onPressed:
                        _saveNote,
                    child: Text(
                      isEdit
                          ? 'حفظ التعديلات'
                          : 'إضافة الملاحظة',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
        right: 4.0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
  ) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(
        context,
      ).cardColor,
      contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(
        height: 0.8,
      ),
    );
  }
}
