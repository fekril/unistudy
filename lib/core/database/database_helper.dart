import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  // تطبيق نمط Singleton Pattern:
  // يضمن وجود نسخة واحدة (Instance) فقط من قاعدة البيانات في الذاكرة لتقليل استهلاك الموارد وتجنب تضارب البيانات
  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // عند طلب قاعدة البيانات، إذا كانت موجودة نرجعها، وإذا لا ننشئها
  Future<Database> get database async {
    if (_database != null)
      return _database!;

    _database = await _initDB(
      'unistudy.db',
    );
    return _database!;
  }

  Future<Database> _initDB(
    String fileName,
  ) async {
    final dbPath =
        await getDatabasesPath();

    final path = join(dbPath, fileName);

    // الدالة openDatabase تقوم بإنشاء أو فتح قاعدة البيانات الموجودة في المسار المحدد
    return await openDatabase(
      path,
      // رقم الإصدار (version): يُستخدم لمعرفة إذا كان هناك تحديث في هيكل الجداول للقيام بعملية الترقية
      version: 2,
      // onCreate: تُستدعى مرة واحدة فقط عند إنشاء قاعدة البيانات لأول مرة
      onCreate: _createDB,
      // onUpgrade: تُستدعى عندما يكون رقم الإصدار الحالي أعلى من الإصدار القديم
      onUpgrade: _upgradeDB,
    );
  }

  // هذه الدالة يتم تنفيذها أول مرة فقط عند إنشاء قاعدة البيانات
  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute('''
    CREATE TABLE subjects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      doctorName TEXT,
      room TEXT,
      color INTEGER NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subjectId INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      type TEXT NOT NULL,
      dueDate TEXT NOT NULL,
      status TEXT NOT NULL,
      priority TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      -- Foreign Key: لربط المهمة بمادة معينة، وبفضل ON DELETE CASCADE تُحذف المهمة تلقائياً إذا حُذفت مادتها
      FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE CASCADE
    )
  ''');

    await db.execute('''
    CREATE TABLE notes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subjectId INTEGER,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT,
      -- ON DELETE SET NULL: إذا حُذفت المادة المرتبطة، لا تُحذف الملاحظة بل تصبح ملاحظة "عامة" لحماية بيانات المستخدم
      FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE SET NULL
    )
  ''');
  }

  // دالة onUpgrade: تنفذ فقط إذا تم رفع الـ version لتحديث الجداول بدون مسح البيانات القديمة للمستخدم
  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subjectId INTEGER,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (subjectId) REFERENCES subjects (id) ON DELETE SET NULL
      )
    ''');
    }
  }

  // =========================
  // Subjects CRUD
  // =========================

  // عمليات الـ CRUD: إنشاء (Insert)، استعلام (Query)، تعديل (Update)، وحذف (Delete)

  Future<int> insertSubject(
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    // نقوم بإدخال البيانات (Insert) كـ Map داخل الجدول المطلوب
    return await db.insert(
      'subjects',
      data,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>
  getSubjects() async {
    final db = await instance.database;

    return await db.query(
      'subjects',
      orderBy: 'id DESC',
    );
  }

  Future<int> updateSubject(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    return await db.update(
      'subjects',
      data,
      where: 'id = ?',
      whereArgs: [id], //
    );
  }

  Future<int> deleteSubject(
    int id,
  ) async {
    final db = await instance.database;

    return await db.delete(
      'subjects',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // Tasks CRUD
  // =========================

  Future<int> insertTask(
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    return await db.insert(
      'tasks',
      data,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>
  getTasks() async {
    final db = await instance.database;

    return await db.query(
      'tasks',
      orderBy: 'dueDate ASC',
    );
  }

  Future<List<Map<String, dynamic>>>
  getTasksByStatus(
    String status,
  ) async {
    final db = await instance.database;

    return await db.query(
      'tasks',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'dueDate ASC',
    );
  }

  Future<List<Map<String, dynamic>>>
  getTasksBySubject(
    int subjectId,
  ) async {
    final db = await instance.database;

    return await db.query(
      'tasks',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
      orderBy: 'dueDate ASC',
    );
  }

  Future<int> updateTask(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;

    return await db.update(
      'tasks',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;

    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markTaskAsDone(
    int id,
  ) async {
    final db = await instance.database;

    return await db.update(
      'tasks',
      {'status': 'مكتملة'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // Statistics
  // =========================

  // دوال الإحصائيات: تستخدم استعلامات SQL المباشرة (rawQuery) لجلب إجمالي عدد السجلات
  Future<int> getSubjectsCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM subjects',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  Future<int> getTasksCount() async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tasks',
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  Future<int> getTasksCountByStatus(
    String status,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM tasks WHERE status = ?',
      [status],
    );

    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // =========================
  // Notes CRUD
  // =========================

  Future<int> insertNote(
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;
    return await db.insert(
      'notes',
      data,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>>
  getNotes() async {
    final db = await instance.database;
    return await db.query(
      'notes',
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>>
  getNotesBySubject(
    int subjectId,
  ) async {
    final db = await instance.database;
    return await db.query(
      'notes',
      where: 'subjectId = ?',
      whereArgs: [subjectId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?>
  getNoteById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<int> updateNote(
    int id,
    Map<String, dynamic> data,
  ) async {
    final db = await instance.database;
    return await db.update(
      'notes',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getNotesCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM notes',
    );
    return Sqflite.firstIntValue(
          result,
        ) ??
        0;
  }

  // إغلاق قاعدة البيانات عند الحاجة
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
