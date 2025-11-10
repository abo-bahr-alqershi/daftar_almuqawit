import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_widget.dart';

/// شاشة الملف الشخصي
/// 
/// تسمح للمستخدم بتحديث معلوماته الشخصية وصورة الحساب
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _profileImagePath;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// تحميل بيانات المستخدم
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: تحميل البيانات من SharedPreferences أو قاعدة البيانات
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _nameController.text = 'أحمد محمد'; // مثال
        _emailController.text = 'ahmed@example.com';
        _phoneController.text = '777123456';
        _businessNameController.text = 'محل القات';
        _addressController.text = 'صنعاء، اليمن';
        _profileImagePath = null; // يمكن تحميلها من الإعدادات
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل تحميل البيانات: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// اختيار صورة البروفايل
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
          _profileImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل اختيار الصورة: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// عرض خيارات اختيار الصورة
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusL),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceL),
              Text('اختر صورة', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.spaceL),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null || _profileImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: AppColors.danger),
                  title: const Text('حذف الصورة'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImagePath = null;
                      _profileImageFile = null;
                    });
                  },
                ),
              const SizedBox(height: AppDimensions.spaceM),
              AppButton.secondary(
                text: 'إلغاء',
                onPressed: () => Navigator.pop(context),
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// حفظ البيانات
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // TODO: حفظ البيانات في SharedPreferences أو قاعدة البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() => _isSaving = false);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ البيانات بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ البيانات: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text('الملف الشخصي', style: AppTextStyles.titleLarge),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const LoadingWidget.large(message: 'جارِ تحميل البيانات...')
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // صورة البروفايل
            _buildProfileImage(),
            const SizedBox(height: AppDimensions.spaceXL),

            // حقول الإدخال
            Text('المعلومات الشخصية', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField(
              controller: _nameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الكامل',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'example@email.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'البريد الإلكتروني غير صحيح';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.phone(
              controller: _phoneController,
              label: 'رقم الهاتف',
              hint: '777123456',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                if (value.length < 9) {
                  return 'رقم الهاتف غير صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            Text('معلومات العمل', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField(
              controller: _businessNameController,
              label: 'اسم المحل',
              hint: 'أدخل اسم المحل',
              prefixIcon: Icons.store,
            ),
            const SizedBox(height: AppDimensions.spaceM),

            AppTextField.multiline(
              controller: _addressController,
              label: 'العنوان',
              hint: 'أدخل عنوان المحل',
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spaceXL),

            // أزرار الحفظ والإلغاء
            AppButton.primary(
              text: _isSaving ? 'جارِ الحفظ...' : 'حفظ التغييرات',
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving ? null : Icons.save,
              fullWidth: true,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            AppButton.secondary(
              text: 'إلغاء',
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          // الصورة
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 3),
            ),
            child: _profileImageFile != null
                ? ClipOval(
                    child: Image.file(
                      _profileImageFile!,
                      fit: BoxFit.cover,
                    ),
                  )
                : _profileImagePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(_profileImagePath!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      ),
          ),

          // زر التحرير
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: _showImageSourceOptions,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 3),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.textOnDark,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
