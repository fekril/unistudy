class TaskModel {
  final int? id;
  final int? subjectId;
  final String title;
  final String description;
  final String type;
  final String dueDate;
  final String status;
  final String priority;
  final String createdAt;

  TaskModel({
    this.id,
    this.subjectId,
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  // تحويل البيانات القادمة من قاعدة البيانات إلى Object
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      subjectId: map['subjectId'],
      title: map['title'],
      description: map['description'] ?? '',
      type: map['type'],
      dueDate: map['dueDate'],
      status: map['status'],
      priority: map['priority'],
      createdAt: map['createdAt'],
    );
  }

  // تحويل Object إلى Map حتى نستطيع حفظه داخل قاعدة البيانات
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'type': type,
      'dueDate': dueDate,
      'status': status,
      'priority': priority,
      'createdAt': createdAt,
    };
  }
}