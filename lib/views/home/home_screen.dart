import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/task_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../subjects/subjects_screen.dart';
import '../tasks/tasks_screen.dart';
import '../statistics/statistics_screen.dart';
import '../notes/notes_screen.dart';
import '../../controllers/note_controller.dart';
import '../../controllers/subject_controller.dart';

class HomeScreen
    extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  Timer? _timer;
  int _quoteIndex = 0;

  final List<String> _quotes = [
    'ابدأ بخطوة بسيطة اليوم، وغدًا سترى الفرق ✨',
    'كل مهمة تنجزها تقرّبك من هدفك 🎯',
    'رتّب وقتك، وخلّي دراستك أسهل 📚',
    'لا تنتظر الحماس، ابدأ وسيأتي الحماس 🚀',
    'إنجاز صغير اليوم يصنع نجاحًا كبيرًا غدًا 🌟',
    'ذاكر بذكاء، وليس بضغط 💡',
  ];

  @override
  void initState() {
    super.initState();
    // إعداد Timer يعمل بشكل دوري لتغيير العبارات التحفيزية كل 5 ثواني لزيادة التفاعل في الواجهة
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) {
        setState(() {
          _quoteIndex =
              (_quoteIndex + 1) %
              _quotes.length;
        });
      },
    );
  }

  @override
  void dispose() {
    // دالة dispose تُستدعى عند إغلاق الشاشة، ونستخدمها هنا لإيقاف Timer لمنع تسرب الذاكرة (Memory Leak)
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController
    themeController =
        Get.find<ThemeController>();
    final TaskController
    taskController =
        Get.find<TaskController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('UNISTUDY'),
          actions: [
            Obx(
              () => IconButton(
                onPressed:
                    themeController
                        .toggleTheme,
                icon: Icon(
                  themeController
                          .isDarkMode
                          .value
                      ? Icons
                            .light_mode_rounded
                      : Icons
                            .dark_mode_rounded,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.all(
                  18,
                ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'مرحبًا بك 👋',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  'جاهز تنظم موادك ومهامك اليوم؟',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 24,
                ),

                // بطاقة تحفيزية
                AnimatedSwitcher(
                  duration:
                      const Duration(
                        milliseconds:
                            500,
                      ),
                  child: Container(
                    key: ValueKey<int>(
                      _quoteIndex,
                    ),
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                          18,
                        ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors
                              .primary,
                          AppColors
                              .secondary,
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(
                            24,
                          ),
                    ),
                    child: Text(
                      _quotes[_quoteIndex],
                      style: const TextStyle(
                        color: Colors
                            .white,
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // الإحصائيات
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title:
                              'المواد',
                          value: Get.find<SubjectController>()
                              .subjects
                              .length
                              .toString(),
                          icon: Icons
                              .menu_book_rounded,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _StatCard(
                          title:
                              'المهام',
                          value: taskController
                              .totalTasks
                              .value
                              .toString(),
                          icon: Icons
                              .task_alt_rounded,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _StatCard(
                          title:
                              'الملاحظات',
                          value:
                              Get.find<
                                    NoteController
                                  >()
                                  .totalNotesCount
                                  .value
                                  .toString(),
                          icon: Icons
                              .notes_rounded,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title:
                              'مكتملة',
                          value: taskController
                              .completedTasks
                              .value
                              .toString(),
                          icon: Icons
                              .check_circle_rounded,
                          iconColor:
                              AppColors
                                  .success,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _StatCard(
                          title:
                              'قيد التنفيذ',
                          value: taskController
                              .pendingTasks
                              .value
                              .toString(),
                          icon: Icons
                              .hourglass_top_rounded,
                          iconColor:
                              AppColors
                                  .warning,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: _StatCard(
                          title:
                              'متأخرة',
                          value: taskController
                              .overdueTasks
                              .value
                              .toString(),
                          icon: Icons
                              .warning_rounded,
                          iconColor:
                              AppColors
                                  .danger,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // أزرار التنقل
                Row(
                  children: [
                    Expanded(
                      child: _NavigationCard(
                        title: 'المهام',
                        icon: Icons
                            .task_rounded,
                        color: AppColors
                            .primary,
                        onTap: () {
                          Get.to(
                            () =>
                                const TasksScreen(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: _NavigationCard(
                        title:
                            'الإحصائيات',
                        icon: Icons
                            .pie_chart_rounded,
                        color: AppColors
                            .secondary,
                        onTap: () {
                          Get.to(
                            () =>
                                const StatisticsScreen(),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    Expanded(
                      child: _NavigationCard(
                        title:
                            'الملاحظات',
                        icon: Icons
                            .notes_rounded,
                        color: AppColors
                            .warning,
                        onTap: () {
                          Get.to(
                            () =>
                                const NotesScreen(),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              16,
                            ),
                      ),
                    ),
                    onPressed: () {
                      Get.to(
                        () =>
                            const SubjectsScreen(),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .menu_book_rounded,
                    ),
                    label: const Text(
                      'إدارة المواد الدراسية',
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
}

class _StatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
                  alpha: 0.04,
                ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  fontWeight:
                      FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationCard
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
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
          color: color.withValues(
            alpha: 0.1,
          ),
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: color.withValues(
              alpha: 0.3,
            ),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
