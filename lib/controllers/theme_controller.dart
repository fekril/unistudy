import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ThemeController: يدير مظهر التطبيق (Light / Dark) لجميع الشاشات من مكان واحد
class ThemeController
    extends GetxController {
  // هذا المتغير يحدد هل الوضع الحالي داكن أم لا (استخدمنا .obs ليكون تفاعلي)
  var isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value =
        !isDarkMode.value;

    // Get.changeThemeMode تقوم بتغيير الـ Theme بشكل مباشر وفوري بدون الحاجة لإعادة تشغيل التطبيق
    Get.changeThemeMode(
      isDarkMode.value
          ? ThemeMode.dark
          : ThemeMode.light,
    );
  }
}
