import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/subscription_plan.dart';
import '../../data/repositories/subscription_repository.dart';
import 'paywall_state.dart';

class PaywallCubit extends Cubit<PaywallState> {
  PaywallCubit(this._subscriptionRepository) : super(const PaywallState());

  final SubscriptionRepository _subscriptionRepository;

  void planSelected(SubscriptionPlan plan) {
    if (state.isBusy) return;
    emit(state.copyWith(selectedPlan: plan, status: PaywallStatus.idle));
  }

  Future<void> purchase() async {
    if (state.isBusy) return;

    emit(state.copyWith(status: PaywallStatus.purchasing));
    await _subscriptionRepository.purchase(state.selectedPlan);
    emit(state.copyWith(status: PaywallStatus.purchased));
  }

  Future<void> restore() async {
    if (state.isBusy) return;

    emit(state.copyWith(status: PaywallStatus.restoring));
    final plan = await _subscriptionRepository.restore();
    emit(
      state.copyWith(
        status: plan == null
            ? PaywallStatus.nothingToRestore
            : PaywallStatus.restored,
      ),
    );
  }
}
