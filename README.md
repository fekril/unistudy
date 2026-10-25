<div align="center">

# 🎓 UniStudy

**Your smart companion to organize university subjects, tasks, and notes.**
**رفيقك الذكي لتنظيم موادك الجامعية ومهامك وملاحظاتك.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.8+-0175C2?logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/State-GetX-8A2BE2)
![SQLite](https://img.shields.io/badge/DB-SQLite-003B57?logo=sqlite&logoColor=white)
![Platforms](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20-4F46E5)

[English](#-english) • [العربية](#-العربية)

</div>

---

## 🇬🇧 English

### Overview
**UniStudy** is a cross-platform Flutter application that helps university students manage their academic life in one place: organize subjects, track tasks and deadlines, write notes, and monitor progress through statistics. All data is stored locally on the device, so it works fully offline.

### ✨ Features
- 📚 **Subjects management** – add, edit, and delete your courses.
- ✅ **Tasks tracking** – create tasks linked to subjects, with details and completion status.
- 📝 **Notes** – write, edit, and view study notes per subject.
- 📊 **Statistics** – visualize your progress and productivity.
- 🌗 **Light / Dark theme** – switchable theme with a clean modern design.
- 🌍 **Arabic-first (RTL)** – interface designed for Arabic with right-to-left layout.
- 💾 **Offline storage** – local SQLite database, no account or internet needed.
- 🎞️ **Smooth animations** – staggered list animations and a splash screen.

### 🛠️ Tech Stack
| Area | Technology |
|------|------------|
| Framework | Flutter / Dart (SDK ^3.8.1) |
| State management & navigation | [GetX](https://pub.dev/packages/get) |
| Local database | [sqflite](https://pub.dev/packages/sqflite) + `sqflite_common_ffi` (desktop) |
| Fonts | `google_fonts` |
| Animations | `flutter_staggered_animations` |
| Formatting | `intl` |

### 🗂️ Project Structure
```
lib/
├── main.dart            # App entry point & dependency injection
├── controllers/         # GetX controllers (subjects, tasks, notes, theme)
├── core/
│   ├── constants/       # App colors
│   ├── database/        # SQLite helper
│   └── theme/           # Light & dark themes
├── models/              # Subject, Task, Note models
└── views/               # Screens: splash, home, subjects, tasks, notes, statistics
```

### 🚀 Getting Started
**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.8.1).

```bash
# 1. Clone the repository
git clone https://github.com/<your-username>/unistudy.git
cd unistudy

# 2. Install dependencies
flutter pub get

# 3. (Optional) Generate launcher icons
dart run flutter_launcher_icons

# 4. Run the app
flutter run
```

Build a release APK:
```bash
flutter build apk --release
```

### 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to open an issue or submit a pull request.

### 📄 License
This project is open source. Add your preferred license (e.g., MIT) in a `LICENSE` file.

---

## 🇸🇦 العربية

<div dir="rtl">

### نظرة عامة
**يوني ستدي (UniStudy)** تطبيق مبني بـ Flutter يعمل على عدة منصات، يساعد طلاب الجامعات على تنظيم حياتهم الدراسية في مكان واحد: إدارة المواد، متابعة المهام والمواعيد النهائية، كتابة الملاحظات، ومراقبة التقدّم عبر الإحصائيات. جميع البيانات تُخزَّن محليًا على الجهاز، فيعمل التطبيق بالكامل بدون إنترنت.

### ✨ المميزات
- 📚 **إدارة المواد** – إضافة موادك الدراسية وتعديلها وحذفها.
- ✅ **متابعة المهام** – إنشاء مهام مرتبطة بالمواد مع التفاصيل وحالة الإنجاز.
- 📝 **الملاحظات** – كتابة وتعديل وعرض ملاحظات الدراسة لكل مادة.
- 📊 **الإحصائيات** – عرض تقدّمك وإنتاجيتك بشكل مرئي.
- 🌗 **الوضع الفاتح / الداكن** – تبديل السمة بتصميم عصري أنيق.
- 🌍 **واجهة عربية (RTL)** – تصميم موجّه للغة العربية من اليمين لليسار.
- 💾 **تخزين محلي** – قاعدة بيانات SQLite بدون حساب أو اتصال بالإنترنت.
- 🎞️ **حركات سلسة** – أنيميشن للقوائم وشاشة بداية (Splash).

### 🛠️ التقنيات المستخدمة
| المجال | التقنية |
|------|------------|
| الإطار | Flutter / Dart (SDK ^3.8.1) |
| إدارة الحالة والتنقل | [GetX](https://pub.dev/packages/get) |
| قاعدة البيانات المحلية | [sqflite](https://pub.dev/packages/sqflite) + `sqflite_common_ffi` (لسطح المكتب) |
| الخطوط | `google_fonts` |
| الحركات | `flutter_staggered_animations` |
| التنسيق | `intl` |

### 🗂️ هيكل المشروع
```
lib/
├── main.dart            # نقطة بداية التطبيق وحقن الاعتمادات
├── controllers/         # المتحكمات (المواد، المهام، الملاحظات، السمة)
├── core/
│   ├── constants/       # ألوان التطبيق
│   ├── database/        # مساعد قاعدة البيانات
│   └── theme/           # السمة الفاتحة والداكنة
├── models/              # نماذج المادة والمهمة والملاحظة
└── views/               # الشاشات: البداية، الرئيسية، المواد، المهام، الملاحظات، الإحصائيات
```

### 🚀 طريقة التشغيل
**المتطلبات:** [Flutter SDK](https://docs.flutter.dev/get-started/install) (إصدار Dart ^3.8.1).

```bash
# 1. استنساخ المستودع
git clone https://github.com/<your-username>/unistudy.git
cd unistudy

# 2. تثبيت الحزم
flutter pub get

# 3. (اختياري) توليد أيقونة التطبيق
dart run flutter_launcher_icons

# 4. تشغيل التطبيق
flutter run
```

بناء ملف APK للإصدار النهائي:
```bash
flutter build apk --release
```
