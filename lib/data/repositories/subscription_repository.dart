import '../models/subscription_plan.dart';
import '../services/local_storage_service.dart';

/// The paywall is static, so the store is simulated with a short delay and a
/// locally saved plan. A real app would call the store SDK here.
class SubscriptionRepository {
  SubscriptionRepository(this._storage);

  final LocalStorageService _storage;

  static const freeScanLimit = 3;
  static const _storeDelay = Duration(seconds: 1);

  SubscriptionPlan? get activePlan => _storage.readActivePlan();

  bool get isPremium => activePlan != null;

  int get remainingFreeScans =>
      (freeScanLimit - _storage.scanCount).clamp(0, freeScanLimit);

  bool get canScan => isPremium || remainingFreeScans > 0;

  Future<void> recordScan() => _storage.saveScanCount(_storage.scanCount + 1);

  Future<void> purchase(SubscriptionPlan plan) async {
    await Future<void>.delayed(_storeDelay);
    await _storage.saveActivePlan(plan);
  }

  Future<SubscriptionPlan?> restore() async {
    await Future<void>.delayed(_storeDelay);
    return activePlan;
  }
}
