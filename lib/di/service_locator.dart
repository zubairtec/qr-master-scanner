import 'package:get_it/get_it.dart';
import 'package:qr_master_scanner/core/services/ad_service.dart';
import 'package:qr_master_scanner/data/repositories/qr_repository_impl.dart';
import 'package:qr_master_scanner/domain/repositories/qr_repository.dart';
import 'package:qr_master_scanner/domain/usecases/delete_scan_history.dart';
import 'package:qr_master_scanner/domain/usecases/get_scan_history.dart';
import 'package:qr_master_scanner/domain/usecases/save_scan_result.dart';
import 'package:qr_master_scanner/domain/usecases/toggle_favorite.dart';
import 'package:qr_master_scanner/presentation/provider/scanner_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Provider
  sl.registerFactory(
    () => ScanProvider(
      getScanHistory: sl(),
      saveScanResult: sl(),
      deleteScanHistory: sl(),
      toggleFavorite: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetScanHistory(sl()));
  sl.registerLazySingleton(() => SaveScanResult(sl()));
  sl.registerLazySingleton(() => DeleteScanHistory(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));

  // Repository
  sl.registerLazySingleton<ScanRepository>(() => ScanRepositoryImpl());
  sl.registerLazySingleton<AdService>(() => AdService());
}
