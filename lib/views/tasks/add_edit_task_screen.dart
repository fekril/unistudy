import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../controllers/subject_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  final bool fromDetails;

  const AddEditTaskScreen({super.key, this.task, this.fromDetails = false});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final TaskController taskController = Get.find<TaskController>();
  final SubjectController subjectController = Get.find<SubjectController>();

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  int? _selectedSubjectId;
  String _selectedType = 'واجب';
  String _selectedStatus = 'قيد التنفيذ';
  String _selectedPriority = 'متوسطة';
  DateTime _selectedDate = DateTime.now();

  final List<String> _types = ['واجب', 'اختبار', 'مشروع', 'ملاحظة'];
  final List<String> _statuses = ['قيد التنفيذ', 'مكتملة', 'متأخرة'];
  final List<String> _priorities = ['منخفضة', 'متوسطة', 'عالية'];

  @override
  void initState() {
    super.initState();
    final task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');

    if (task != null) {
      _selectedSubjectId = task.subjectId;
      _selectedStatus = _statuses.contains(task.status) ? task.status : 'مكتملة';
      _selectedPriority = _priorities.contains(task.priority) ? task.priority : 'متوسطة';
      _selectedType = _types.contains(task.type) ? task.type : 'واجب';
      try {
        _selectedDate = DateTime.parse(task.dueDate);
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    // مهم جداً تحرير الذاكرة المستخدمة للـ Controllers عند إغلاق الشاشة لتجنب مشاكل الذاكرة (Memory Leaks)
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // استخدام async/await في دالة _pickDate لانتظار اختيار المستخدم للتاريخ من الويدجت الجاهزة showDatePicker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() async {
    // FocusScope.of(context).unfocus() تخفي الكيبورد فور الضغط على زر الحفظ لتنظيف الشاشة
    FocusScope.of(context).unfocus(); 

    // التأكد من أن جميع الحقول توافق قواعد الـ Validation الموضوعة لها قبل الحفظ
    if (_formKey.currentState!.validate()) {
      final task = TaskModel(
        id: widget.task?.id,
        subjectId: _selectedSubjectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        dueDate: _selectedDate.toIso8601String(),
        status: _selectedStatus,
        priority: _selectedPriority,
        createdAt: widget.task?.createdAt ?? DateTime.now().toIso8601String(),
      );

      if (widget.task == null) {
        await taskController.addTask(task);
        Navigator.pop(context);
      } else {
        await taskController.updateTask(task.id!, task);
        if (widget.fromDetails) {
          Get.back(); // Pop AddEdit screen
          Get.back(); // Pop Details screen
        } else {
          Navigator.pop(context);
        }
      }
    } else {
      Get.snackbar(
        'تنبيه',
        'يرجى التأكد من إدخال البيانات بشكل صحيح',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
        ),
        body: Form(
          key: _formKey, // مفتاح الـ Form يستخدم لتشغيل Validation على جميع الحقول دفعة واحدة
          // نستخدم SingleChildScrollView لحل مشكلة ظهور خطأ (Bottom Overflowed) عند ظهور الكيبورد
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              // viewInsets.bottom تضيف مسافة تعادل ارتفاع الكيبورد حتى لا تُغطي على الحقول
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('عنوان المهمة'),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('مثال: واجب رياضيات'),
                  // inputFormatters: تسمح لنا بوضع قيود على ما يمكن للمستخدم إدخاله (Data Validation)
                  // هنا نمنع إدخال الرموز الغريبة للمحافظة على نظافة البيانات
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'[0-9!@#\$%^&\*\(\)_\+=\[\]\{\};:"\\|<>\/\?]')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'عنوان المهمة مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildLabel('الوصف (اختياري)'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: _inputDecoration('اكتب تفاصيل المهمة هنا...'),
                ),
                const SizedBox(height: 16),

                _buildLabel('المادة الدراسية'),
                DropdownButtonFormField<int?>(
                  value: _selectedSubjectId,
                  decoration: _inputDecoration('اختر المادة'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('بدون مادة'),
                    ),
                    ...subjectController.subjects.map((subject) {
                      return DropdownMenuItem<int?>(
                        value: subject.id,
                        child: Text(subject.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('نوع المهمة'),
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: _inputDecoration(''),
                            items: _types.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('تاريخ التسليم'),
                          InkWell(
                            onTap: () => _pickDate(context),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      DateFormat('yyyy/MM/dd').format(_selectedDate),
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('حالة المهمة'),
                          DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: _inputDecoration(''),
                            items: _statuses.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('الأولوية'),
                          DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: _inputDecoration(''),
                            items: _priorities.map((priority) {
                              return DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPriority = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _saveTask,
                    child: Text(
                      isEdit ? 'حفظ التعديلات' : 'إضافة المهمة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(height: 0.8),
    );
  }
}
