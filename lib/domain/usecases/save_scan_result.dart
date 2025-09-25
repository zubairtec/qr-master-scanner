import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';

class SaveScanResult {
  final ScanRepository repository;

  SaveScanResult(this.repository);

  Future<void> call(ScanResult result) async {
    return await repository.saveScanResult(result);
  }
}
