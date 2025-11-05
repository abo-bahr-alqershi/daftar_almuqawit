/// حالة استخدام إنشاء نسخة احتياطية
/// تجمع جميع البيانات وتضغطها وتشفرها وترفعها للسحابة

import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import '../../repositories/backup_repository.dart';
import '../../repositories/sales_repository.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/customer_repository.dart';
import '../../repositories/supplier_repository.dart';
import '../../repositories/debt_repository.dart';
import '../../repositories/expense_repository.dart';
import '../base/base_usecase.dart';

/// حالة استخدام إنشاء نسخة احتياطية
class CreateBackup implements UseCase<String, CreateBackupParams> {
  final BackupRepository backupRepo;
  final SalesRepository salesRepo;
  final PurchaseRepository purchaseRepo;
  final CustomerRepository customerRepo;
  final SupplierRepository supplierRepo;
  final DebtRepository debtRepo;
  final ExpenseRepository expenseRepo;
  
  CreateBackup(
    this.backupRepo,
    this.salesRepo,
    this.purchaseRepo,
    this.customerRepo,
    this.supplierRepo,
    this.debtRepo,
    this.expenseRepo,
  );
  
  @override
  Future<String> call(CreateBackupParams params) async {
    try {
      // جمع جميع البيانات
      final data = await _collectAllData();
      
      // تحويل البيانات إلى JSON
      final jsonData = jsonEncode(data);
      
      // إنشاء ملف مؤقت
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'backup_$timestamp';
      final jsonFile = File('${tempDir.path}/$backupFileName.json');
      await jsonFile.writeAsString(jsonData);
      
      // ضغط البيانات
      final compressedFile = await _compressFile(jsonFile, params.compress);
      
      // تشفير النسخة إذا طلب ذلك
      File finalFile = compressedFile;
      if (params.encrypt && params.encryptionKey != null) {
        finalFile = await _encryptFile(compressedFile, params.encryptionKey!);
      }
      
      // حفظ محلياً
      String? localPath;
      if (params.saveLocally) {
        localPath = await _saveLocally(finalFile);
      }
      
      // رفع للسحابة
      String? cloudPath;
      if (params.uploadToCloud) {
        cloudPath = await backupRepo.uploadToCloud(finalFile.path);
      }
      
      // حذف الملفات المؤقتة
      await jsonFile.delete();
      if (compressedFile.path != finalFile.path) {
        await compressedFile.delete();
      }
      
      return localPath ?? cloudPath ?? finalFile.path;
    } catch (e) {
      throw Exception('فشل إنشاء النسخة الاحتياطية: $e');
    }
  }
  
  /// جمع جميع البيانات
  Future<Map<String, dynamic>> _collectAllData() async {
    return {
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
      'sales': (await salesRepo.getAll()).map((e) => e.toJson()).toList(),
      'purchases': (await purchaseRepo.getAll()).map((e) => e.toJson()).toList(),
      'customers': (await customerRepo.getAll()).map((e) => e.toJson()).toList(),
      'suppliers': (await supplierRepo.getAll()).map((e) => e.toJson()).toList(),
      'debts': (await debtRepo.getAll()).map((e) => e.toJson()).toList(),
      'expenses': (await expenseRepo.getAll()).map((e) => e.toJson()).toList(),
    };
  }
  
  /// ضغط الملف
  Future<File> _compressFile(File file, bool compress) async {
    if (!compress) return file;
    
    final bytes = await file.readAsBytes();
    final archive = Archive();
    archive.addFile(ArchiveFile(
      file.path.split('/').last,
      bytes.length,
      bytes,
    ));
    
    final zipData = ZipEncoder().encode(archive);
    final zipFile = File('${file.path}.zip');
    await zipFile.writeAsBytes(zipData!);
    
    return zipFile;
  }
  
  /// تشفير الملف
  Future<File> _encryptFile(File file, String key) async {
    // TODO: تطبيق التشفير الفعلي
    // يمكن استخدام مكتبة مثل encrypt
    return file;
  }
  
  /// حفظ محلياً
  Future<String> _saveLocally(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    final fileName = file.path.split('/').last;
    final localFile = File('${backupDir.path}/$fileName');
    await file.copy(localFile.path);
    
    return localFile.path;
  }
}

/// معاملات إنشاء النسخة الاحتياطية
class CreateBackupParams {
  final bool compress;
  final bool encrypt;
  final String? encryptionKey;
  final bool saveLocally;
  final bool uploadToCloud;
  
  const CreateBackupParams({
    this.compress = true,
    this.encrypt = false,
    this.encryptionKey,
    this.saveLocally = true,
    this.uploadToCloud = false,
  });
}
