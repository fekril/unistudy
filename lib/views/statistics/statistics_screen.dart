import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/task_controller.dart';
import '../../core/constants/app_colors.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإحصائيات'),
        ),
        // FutureBuilder: ويدجت ذكية تبني نفسها بناءً على حالة (State) الـ Future الممرر لها
        // مفيدة جداً عند جلب البيانات من قاعدة البيانات لأنها تأخذ وقتاً
        body: FutureBuilder<Map<String, int>>(
          future: taskController.getStatistics(),
          builder: (context, snapshot) {
            // التحقق من حالة الاتصال: إذا كان ينتظر جلب البيانات يعرض مؤشر تحميل
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('حدث خطأ أثناء تحميل الإحصائيات'),
              );
            }

            final data = snapshot.data ?? {};
            final int totalTasks = data['total'] ?? 0;
            final int completedTasks = data['completed'] ?? 0;
            final int overdueTasks = data['overdue'] ?? 0;
            final int pendingTasks = data['pending'] ?? 0;
            final int totalSubjects = data['subjects'] ?? 0;

            double progress = 0.0;
            if (totalTasks > 0) {
              progress = completedTasks / totalTasks;
            }

            String message = '';
            if (totalTasks == 0) {
              message = 'لا توجد مهام بعد، أضف مهمتك الأولى!';
            } else if (progress == 0.0) {
              message = 'ابدأ الآن، أول خطوة تصنع الفرق';
            } else if (progress < 0.5) {
              message = 'أنت في الطريق، استمر';
            } else if (progress < 1.0) {
              message = 'ممتاز، اقتربت من الإنجاز';
            } else {
              message = 'رائع جدًا، أنهيت كل مهامك';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بطاقة نسبة الإنجاز
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'نسبة الإنجاز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 12,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'تفاصيل الإحصائيات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  _buildStatRow(
                    context,
                    title: 'إجمالي المواد',
                    value: totalSubjects.toString(),
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    title: 'إجمالي المهام',
                    value: totalTasks.toString(),
                    icon: Icons.task_rounded,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    title: 'المهام المكتملة',
                    value: completedTasks.toString(),
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    title: 'قيد التنفيذ',
                    value: pendingTasks.toString(),
                    icon: Icons.hourglass_top_rounded,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    title: 'المهام المتأخرة',
                    value: overdueTasks.toString(),
                    icon: Icons.error_rounded,
                    color: AppColors.danger,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
