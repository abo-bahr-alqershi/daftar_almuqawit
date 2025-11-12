import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/settings_tile.dart';
import 'backup_screen.dart';
import 'profile_screen.dart';
import 'language_screen.dart';
import 'theme_screen.dart';
import 'about_screen.dart';
import '../../blocs/settings/settings_bloc.dart';
import '../../blocs/settings/settings_event.dart';
import '../../blocs/settings/settings_state.dart';

/// شاشة الإعدادات الرئيسية - تصميم راقي هادئ
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    context.read<SettingsBloc>().add(LoadSettings());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: BlocBuilder<SettingsBloc, SettingsState>(
                    builder: (context, state) {
                      if (state is SettingsInitial) {
                        return _buildLoadingState();
                      }

                      if (state is SettingsError) {
                        return _buildErrorState(state.message);
                      }

                      final settingsState = state as SettingsLoaded;

                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAccountSection(),
                            const SizedBox(height: 24),
                            _buildAppearanceSection(),
                            const SizedBox(height: 24),
                            _buildNotificationsSection(settingsState),
                            const SizedBox(height: 24),
                            _buildDataSection(settingsState),
                            const SizedBox(height: 24),
                            _buildAboutSection(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withOpacity(0.08),
          AppColors.info.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildModernAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.success],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'الإعدادات',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'تخصيص التطبيق حسب احتياجاتك',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _SectionCard(
      title: 'الحساب',
      icon: Icons.person_rounded,
      color: AppColors.primary,
      children: [
        SettingsTile(
          title: 'الملف الشخصي',
          subtitle: 'إدارة معلومات حسابك',
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.primary,
          onTap: () => _navigateTo(const ProfileScreen()),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _SectionCard(
      title: 'المظهر',
      icon: Icons.palette_rounded,
      color: AppColors.info,
      children: [
        SettingsTile(
          title: 'اللغة',
          subtitle: 'العربية',
          icon: Icons.language_rounded,
          iconColor: AppColors.info,
          onTap: () => _navigateTo(const LanguageScreen()),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'المظهر',
          subtitle: 'فاتح، داكن، أو تلقائي',
          icon: Icons.brightness_6_rounded,
          iconColor: AppColors.warning,
          onTap: () => _navigateTo(const ThemeScreen()),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(SettingsLoaded state) {
    return _SectionCard(
      title: 'الإشعارات',
      icon: Icons.notifications_rounded,
      color: AppColors.success,
      children: [
        SettingsTile(
          title: 'تفعيل الإشعارات',
          subtitle: 'استقبال إشعارات التطبيق',
          icon: Icons.notifications_active_rounded,
          iconColor: AppColors.success,
          trailing: Switch(
            value: state.notificationsEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              context.read<SettingsBloc>().add(ToggleNotifications(value));
            },
            activeColor: AppColors.success,
          ),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'الصوت',
          subtitle: 'تشغيل أصوات الإشعارات',
          icon: Icons.volume_up_rounded,
          iconColor: AppColors.info,
          trailing: Switch(
            value: state.soundEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              context.read<SettingsBloc>().add(ToggleSound(value));
            },
            activeColor: AppColors.info,
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(SettingsLoaded state) {
    return _SectionCard(
      title: 'البيانات والمزامنة',
      icon: Icons.cloud_sync_rounded,
      color: AppColors.purchases,
      children: [
        SettingsTile(
          title: 'المزامنة التلقائية',
          subtitle: 'مزامنة البيانات مع السحابة تلقائياً',
          icon: Icons.sync_rounded,
          iconColor: AppColors.purchases,
          trailing: Switch(
            value: state.autoSyncEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              context.read<SettingsBloc>().add(ToggleAutoSync(value));
            },
            activeColor: AppColors.purchases,
          ),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'النسخ الاحتياطي',
          subtitle: 'إدارة النسخ الاحتياطية للبيانات',
          icon: Icons.backup_rounded,
          iconColor: AppColors.warning,
          onTap: () => _navigateTo(const BackupScreen()),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SectionCard(
      title: 'حول التطبيق',
      icon: Icons.info_rounded,
      color: AppColors.textSecondary,
      children: [
        SettingsTile(
          title: 'حول التطبيق',
          subtitle: 'الإصدار، الترخيص، والمزيد',
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.textSecondary,
          onTap: () => _navigateTo(const AboutScreen()),
        ),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'تقييم التطبيق',
          subtitle: 'شاركنا رأيك في المتجر',
          icon: Icons.star_outline_rounded,
          iconColor: AppColors.warning,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 8),
        SettingsTile(
          title: 'التواصل معنا',
          subtitle: 'لأي استفسارات أو اقتراحات',
          icon: Icons.email_outlined,
          iconColor: AppColors.info,
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(100),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.danger.withOpacity(0.1),
                    AppColors.danger.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'حدث خطأ',
              style: AppTextStyles.h3.copyWith(color: AppColors.danger),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsBloc>().add(LoadSettings());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
