class SubjectModel {
  final int? id;
  final String name;
  final String doctorName;
  final String room;
  final int color;

  SubjectModel({
    this.id,
    required this.name,
    required this.doctorName,
    required this.room,
    required this.color,
  });

  // تحويل البيانات من Map قادمة من قاعدة البيانات إلى Object
  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'],
      name: map['name'],
      doctorName: map['doctorName'] ?? '',
      room: map['room'] ?? '',
      color: map['color'],
    );
  }

  // تحويل Object إلى Map حتى نستطيع حفظه داخل sqflite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'doctorName': doctorName,
      'room': room,
      'color': color,
    };
  }
}