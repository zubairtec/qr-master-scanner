import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';

class DeleteScanHistory {
  final ScanRepository repository;

  DeleteScanHistory(this.repository);

  Future<void> call() async {
    return await repository.deleteScanHistory();
  }
}
