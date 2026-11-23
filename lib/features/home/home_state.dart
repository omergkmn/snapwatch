import '../../data/models/watchlist_item.dart';

class HomeState {
  const HomeState({
    this.name = '',
    this.isPremium = false,
    this.remainingFreeScans = 0,
    this.canScan = false,
    this.toWatch = const [],
    this.watched = const [],
  });

  final String name;
  final bool isPremium;
  final int remainingFreeScans;
  final bool canScan;
  final List<WatchlistItem> toWatch;
  final List<WatchlistItem> watched;

  HomeState withoutItem(WatchlistItem removed) {
    bool keep(WatchlistItem item) => item.id != removed.id;
    return HomeState(
      name: name,
      isPremium: isPremium,
      remainingFreeScans: remainingFreeScans,
      canScan: canScan,
      toWatch: toWatch.where(keep).toList(),
      watched: watched.where(keep).toList(),
    );
  }
}
