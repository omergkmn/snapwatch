import '../../data/models/subscription_plan.dart';

enum PaywallStatus {
  idle,
  purchasing,
  restoring,
  purchased,
  restored,
  nothingToRestore,
}

class PaywallState {
  const PaywallState({
    this.selectedPlan = SubscriptionPlan.yearly,
    this.status = PaywallStatus.idle,
  });

  final SubscriptionPlan selectedPlan;
  final PaywallStatus status;

  bool get isBusy =>
      status == PaywallStatus.purchasing || status == PaywallStatus.restoring;

  PaywallState copyWith({
    SubscriptionPlan? selectedPlan,
    PaywallStatus? status,
  }) {
    return PaywallState(
      selectedPlan: selectedPlan ?? this.selectedPlan,
      status: status ?? this.status,
    );
  }
}
