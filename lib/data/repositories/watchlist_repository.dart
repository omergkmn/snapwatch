import '../models/media_title.dart';
import '../models/watchlist_item.dart';
import '../services/local_storage_service.dart';

class WatchlistRepository {
  WatchlistRepository(this._storage);

  final LocalStorageService _storage;

  /// Newest first.
  List<WatchlistItem> get items => _storage.readWatchlist();

  WatchStatus? statusOf(MediaTitle title) {
    final id = WatchlistItem.idOf(title);
    return items.where((item) => item.id == id).firstOrNull?.status;
  }

  Future<void> add(MediaTitle title) async {
    if (statusOf(title) != null) return;

    final item = WatchlistItem(
      title: title,
      status: WatchStatus.toWatch,
      addedAt: DateTime.now(),
    );
    await _storage.saveWatchlist([item, ...items]);
  }

  Future<void> setStatus(MediaTitle title, WatchStatus status) async {
    final id = WatchlistItem.idOf(title);
    await _storage.saveWatchlist([
      for (final item in items)
        item.id == id ? item.copyWith(status: status) : item,
    ]);
  }

  Future<void> remove(MediaTitle title) async {
    final id = WatchlistItem.idOf(title);
    await _storage.saveWatchlist(items.where((item) => item.id != id).toList());
  }
}
