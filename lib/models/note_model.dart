// الكلاس (Model) نستخدمه لتمثيل البيانات ككائنات (Objects) بدلاً من خرائط (Maps) لسهولة التعامل معها برمجياً وتجنب الأخطاء
class NoteModel {
  // نستخدم الأي دي كـ nullable (int?)
  // لأن المهمة أو الملاحظة الجديدة لا تملك
  //ID حتى يتم حفظها في قاعدة البيانات
  final int? id;
  // subjectId يمكن أن يكون null لأن الملاحظة قد تكون "ملاحظة عامة" غير مرتبطة بمادة محددة
  final int? subjectId;
  final String title;
  final String content;
  final String createdAt;
  final String? updatedAt;

  NoteModel({
    this.id,
    this.subjectId,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  // دالة fromMap: تأخذ البيانات (Map)
  //القادمة من قاعدة البيانات (SQLite) وتحولها إلى كائن
  //(Object) من نوع NoteModel
  factory NoteModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return NoteModel(
      id: map['id'],
      subjectId: map['subjectId'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'],
    );
  }

  // دالة toMap: تحول الكائن (Object) إلى خريطة (Map) حتى نتمكن من حفظها أو إدراجها داخل قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
