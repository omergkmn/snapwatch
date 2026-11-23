import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/watchlist_item.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(
    this._userRepository,
    this._subscriptionRepository,
    this._watchlistRepository,
  ) : super(const HomeState());

  final UserRepository _userRepository;
  final SubscriptionRepository _subscriptionRepository;
  final WatchlistRepository _watchlistRepository;

  /// Called on open and whenever the user may have scanned, subscribed or
  /// changed the watchlist on another screen.
  void refresh() {
    final items = _watchlistRepository.items;
    emit(
      HomeState(
        name: _userRepository.profile?.name ?? '',
        isPremium: _subscriptionRepository.isPremium,
        remainingFreeScans: _subscriptionRepository.remainingFreeScans,
        canScan: _subscriptionRepository.canScan,
        toWatch: items
            .where((item) => item.status == WatchStatus.toWatch)
            .toList(),
        watched: items
            .where((item) => item.status == WatchStatus.watched)
            .toList(),
      ),
    );
  }

  Future<void> remove(WatchlistItem item) async {
    // Update the screen first so the swiped row disappears right away.
    emit(state.withoutItem(item));
    await _watchlistRepository.remove(item.title);
  }
}
