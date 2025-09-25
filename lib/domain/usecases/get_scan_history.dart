import 'package:qr_master_scanner/domain/entities/scan_result.dart';
import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';

class GetScanHistory {
  final ScanRepository repository;

  GetScanHistory(this.repository);

  Future<List<ScanResult>> call() async {
    return await repository.getScanHistory();
  }
}
