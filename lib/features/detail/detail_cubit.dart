import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/media_title.dart';
import '../../data/models/watchlist_item.dart';
import '../../data/repositories/watchlist_repository.dart';

/// The state is the title's place in the watchlist; null means not added.
class DetailCubit extends Cubit<WatchStatus?> {
  DetailCubit(this._watchlistRepository, this._title)
    : super(_watchlistRepository.statusOf(_title));

  final WatchlistRepository _watchlistRepository;
  final MediaTitle _title;

  Future<void> addToWatchlist() async {
    await _watchlistRepository.add(_title);
    _reload();
  }

  Future<void> setWatched(bool watched) async {
    await _watchlistRepository.setStatus(
      _title,
      watched ? WatchStatus.watched : WatchStatus.toWatch,
    );
    _reload();
  }

  Future<void> removeFromWatchlist() async {
    await _watchlistRepository.remove(_title);
    _reload();
  }

  void _reload() => emit(_watchlistRepository.statusOf(_title));
}
