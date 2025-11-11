/// خدمة Google Drive للنسخ الاحتياطي
///
/// توفر رفع وتحميل وإدارة النسخ الاحتياطية في Google Drive
///
/// الميزات:
/// - رفع النسخ الاحتياطية إلى Google Drive
/// - تحميل النسخ من Drive
/// - عرض قائمة النسخ الاحتياطية
/// - حذف النسخ القديمة
/// - البحث عن ملفات النسخ الاحتياطي

import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'logger_service.dart';

/// خدمة Google Drive
class GoogleDriveService {
  GoogleDriveService._();

  static final GoogleDriveService _instance = GoogleDriveService._();
  static GoogleDriveService get instance => _instance;

  final LoggerService _logger = LoggerService();

  // Google Sign In - الأذونات الصحيحة
  late final GoogleSignIn _googleSignIn;

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;
  bool _isInitialized = false;

  /// تهيئة الخدمة
  void _initialize() {
    if (_isInitialized) return;

    _googleSignIn = GoogleSignIn(
      scopes: [
        drive.DriveApi.driveFileScope, // الوصول الكامل للملفات
        drive.DriveApi.driveAppdataScope, // بيانات التطبيق
      ],
      // إعدادات إضافية للعمل بشكل أفضل
      signInOption: SignInOption.standard,
    );

    // الاستماع لتغييرات الحساب
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;
      if (account != null) {
        _logger.info('👤 تغير الحساب: ${account.email}');
        _setupDriveApi(account);
      } else {
        _driveApi = null;
        _logger.info('👤 تم تسجيل الخروج');
      }
    });

    _isInitialized = true;
  }

  /// إعداد Drive API
  Future<void> _setupDriveApi(GoogleSignInAccount account) async {
    try {
      final authHeaders = await account.authHeaders;
      final authenticateClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticateClient);
      _logger.info('✅ تم إعداد Drive API بنجاح');
    } catch (e) {
      _logger.error('❌ فشل إعداد Drive API', error: e);
    }
  }

  /// التحقق من تسجيل الدخول
  bool get isSignedIn {
    _initialize();
    return _currentUser != null && _driveApi != null;
  }

  /// الحصول على البريد الإلكتروني للمستخدم
  String? get userEmail {
    _initialize();
    return _currentUser?.email;
  }

  // ========== المصادقة ==========

  /// تسجيل الدخول إلى Google Drive
  Future<bool> signIn() async {
    try {
      _initialize();

      _logger.info('🔐 بدء تسجيل الدخول إلى Google Drive...');

      // محاولة تسجيل دخول صامت أولاً
      GoogleSignInAccount? account = await _googleSignIn.signInSilently(
        suppressErrors: true,
      );

      // إذا فشل، نطلب تسجيل دخول تفاعلي
      if (account == null) {
        _logger.info('📱 طلب تسجيل دخول تفاعلي...');
        account = await _googleSignIn.signIn();
      }

      if (account == null) {
        _logger.warning('❌ المستخدم ألغى تسجيل الدخول');
        return false;
      }

      _currentUser = account;

      // إنشاء DriveApi
      await _setupDriveApi(account);

      if (_driveApi == null) {
        _logger.error('❌ فشل إنشاء DriveApi');
        return false;
      }

      _logger.info('✅ تم تسجيل الدخول بنجاح: ${account.email}');
      _logger.info('📧 البريد: ${account.email}');
      _logger.info('🆔 المعرف: ${account.id}');

      return true;
    } catch (e, stackTrace) {
      _logger.error(
        '❌ فشل تسجيل الدخول إلى Google Drive',
        error: e,
        stackTrace: stackTrace,
      );

      // تفاصيل أكثر عن الخطأ
      if (e.toString().contains('PlatformException')) {
        _logger.error('❌ خطأ في النظام - تحقق من إعدادات Android/iOS');
      } else if (e.toString().contains('DEVELOPER_ERROR')) {
        _logger.error('❌ خطأ في الإعدادات - تحقق من SHA-1 في Firebase Console');
      }

      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      _initialize();
      await _googleSignIn.signOut();
      _currentUser = null;
      _driveApi = null;
      _logger.info('✅ تم تسجيل الخروج من Google Drive');
    } catch (e) {
      _logger.error('❌ فشل تسجيل الخروج', error: e);
    }
  }

  /// تسجيل الدخول الصامت (إذا كان المستخدم مسجل سابقاً)
  Future<bool> signInSilently() async {
    try {
      _initialize();

      _logger.info('🔄 محاولة تسجيل دخول صامت...');

      final account = await _googleSignIn.signInSilently(suppressErrors: false);

      if (account == null) {
        _logger.info('ℹ️ لا يوجد حساب محفوظ');
        return false;
      }

      _currentUser = account;
      await _setupDriveApi(account);

      if (_driveApi == null) {
        _logger.warning('⚠️ فشل إعداد DriveApi');
        return false;
      }

      _logger.info('✅ تم تسجيل الدخول التلقائي: ${account.email}');
      return true;
    } catch (e) {
      _logger.warning(
        '⚠️ فشل تسجيل الدخول التلقائي',
        data: {'error': e.toString()},
      );
      return false;
    }
  }

  /// فصل الاتصال (disconnect)
  Future<void> disconnect() async {
    try {
      _initialize();
      await _googleSignIn.disconnect();
      _currentUser = null;
      _driveApi = null;
      _logger.info('✅ تم فصل الاتصال من Google Drive');
    } catch (e) {
      _logger.error('❌ فشل فصل الاتصال', error: e);
    }
  }

  // ========== رفع النسخ الاحتياطية ==========

  /// رفع ملف نسخة احتياطية إلى Google Drive
  ///
  /// Returns: معرف الملف في Google Drive
  Future<String> uploadBackup(
    String filePath, {
    Function(double progress)? onProgress,
  }) async {
    if (!isSignedIn) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: $filePath');
      }

      final fileName = path.basename(filePath);
      _logger.info('📤 رفع النسخة الاحتياطية إلى Google Drive: $fileName');

      // إنشاء مجلد النسخ الاحتياطية إذا لم يكن موجوداً
      final folderId = await _getOrCreateBackupFolder();

      // إعداد معلومات الملف
      final driveFile = drive.File();
      driveFile.name = fileName;
      driveFile.parents = [folderId];
      driveFile.description =
          'نسخة احتياطية من تطبيق دفتر المقوت - ${DateTime.now().toIso8601String()}';

      // رفع الملف
      final media = drive.Media(file.openRead(), await file.length());

      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      _logger.info('✅ تم رفع النسخة بنجاح! File ID: ${uploadedFile.id}');

      // TODO: يمكن إضافة تتبع التقدم هنا إذا لزم الأمر
      onProgress?.call(1.0);

      return uploadedFile.id!;
    } catch (e, stackTrace) {
      _logger.error(
        '❌ فشل رفع النسخة الاحتياطية إلى Google Drive',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// الحصول على مجلد النسخ الاحتياطية أو إنشاؤه
  Future<String> _getOrCreateBackupFolder() async {
    const folderName = 'دفتر_المقوت_نسخ_احتياطية';

    try {
      // البحث عن المجلد
      final query =
          "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";

      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        _logger.info(
          '📁 وُجد مجلد النسخ الاحتياطية: ${fileList.files!.first.id}',
        );
        return fileList.files!.first.id!;
      }

      // إنشاء المجلد إذا لم يكن موجوداً
      _logger.info('📁 إنشاء مجلد النسخ الاحتياطية...');

      final folder = drive.File();
      folder.name = folderName;
      folder.mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await _driveApi!.files.create(folder);

      _logger.info('✅ تم إنشاء المجلد: ${createdFolder.id}');
      return createdFolder.id!;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل الحصول على/إنشاء مجلد النسخ الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== قائمة النسخ الاحتياطية ==========

  /// الحصول على قائمة النسخ الاحتياطية من Google Drive
  Future<List<DriveBackupInfo>> listBackups() async {
    if (!isSignedIn) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      _logger.info('📋 جلب قائمة النسخ الاحتياطية من Google Drive...');

      final folderId = await _getOrCreateBackupFolder();

      final query = "'$folderId' in parents and trashed=false";

      final fileList = await _driveApi!.files.list(
        q: query,
        spaces: 'drive',
        orderBy: 'createdTime desc',
        $fields:
            'files(id, name, size, createdTime, modifiedTime, description)',
      );

      final backups = <DriveBackupInfo>[];

      if (fileList.files != null) {
        for (final file in fileList.files!) {
          backups.add(
            DriveBackupInfo(
              id: file.id!,
              name: file.name!,
              size: int.tryParse(file.size ?? '0') ?? 0,
              createdTime: file.createdTime ?? DateTime.now(),
              modifiedTime: file.modifiedTime ?? DateTime.now(),
              description: file.description,
            ),
          );
        }
      }

      _logger.info('✅ تم العثور على ${backups.length} نسخة احتياطية');
      return backups;
    } catch (e, stackTrace) {
      _logger.error(
        'فشل جلب قائمة النسخ الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // ========== تحميل النسخ ==========

  /// تحميل نسخة احتياطية من Google Drive
  Future<String> downloadBackup(
    String fileId,
    String localPath, {
    Function(double progress)? onProgress,
  }) async {
    if (!isSignedIn) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      _logger.info('⬇️ بدء تحميل النسخة الاحتياطية من Google Drive...');

      final media =
          await _driveApi!.files.get(
                fileId,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final file = File(localPath);
      await file.parent.create(recursive: true);

      final sink = file.openWrite();

      await for (var data in media.stream) {
        sink.add(data);
        // TODO: يمكن حساب التقدم هنا
      }

      await sink.close();

      _logger.info('✅ تم تحميل النسخة بنجاح: $localPath');
      onProgress?.call(1.0);

      return localPath;
    } catch (e, stackTrace) {
      _logger.error(
        '❌ فشل تحميل النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ========== حذف النسخ ==========

  /// حذف نسخة احتياطية من Google Drive
  Future<void> deleteBackup(String fileId) async {
    if (!isSignedIn) {
      throw Exception('يجب تسجيل الدخول أولاً');
    }

    try {
      _logger.info('🗑️ حذف النسخة الاحتياطية: $fileId');

      await _driveApi!.files.delete(fileId);

      _logger.info('✅ تم حذف النسخة بنجاح');
    } catch (e, stackTrace) {
      _logger.error(
        'فشل حذف النسخة الاحتياطية',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// حذف النسخ القديمة (أقدم من X يوم)
  Future<int> deleteOldBackups({int daysOld = 30, int keepLast = 5}) async {
    try {
      final backups = await listBackups();

      if (backups.length <= keepLast) {
        _logger.info('عدد النسخ ($keepLast أو أقل) - لن يتم الحذف');
        return 0;
      }

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      final toDelete = backups
          .skip(keepLast)
          .where((backup) => backup.createdTime.isBefore(cutoffDate));

      for (final backup in toDelete) {
        try {
          await deleteBackup(backup.id);
          deletedCount++;
        } catch (e) {
          _logger.warning('فشل حذف: ${backup.name}');
          _logger.d('تفاصيل الخطأ: $e');
        }
      }

      _logger.info('تم حذف $deletedCount نسخة احتياطية قديمة');
      return deletedCount;
    } catch (e) {
      _logger.error('فشل حذف النسخ القديمة', error: e);
      return 0;
    }
  }
}

/// HTTP Client مخصص لـ googleapis
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

/// معلومات نسخة احتياطية في Google Drive
class DriveBackupInfo {
  final String id;
  final String name;
  final int size;
  final DateTime createdTime;
  final DateTime modifiedTime;
  final String? description;

  const DriveBackupInfo({
    required this.id,
    required this.name,
    required this.size,
    required this.createdTime,
    required this.modifiedTime,
    this.description,
  });

  /// حجم الملف بصيغة قابلة للقراءة
  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// الوقت منذ الإنشاء
  String get timeAgo {
    final diff = DateTime.now().difference(createdTime);

    if (diff.inSeconds < 60) return 'منذ ${diff.inSeconds} ثانية';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'size': size,
    'sizeFormatted': sizeFormatted,
    'createdTime': createdTime.toIso8601String(),
    'modifiedTime': modifiedTime.toIso8601String(),
    'timeAgo': timeAgo,
    'description': description,
  };
}
