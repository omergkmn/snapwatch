import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/router.dart';
import '../../core/errors/app_exception.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/l10n/locale_keys.g.dart';
import '../../data/repositories/subscription_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/watchlist_repository.dart';
import 'home_cubit.dart';
import 'home_state.dart';
import '../scan/scan_request.dart';
import 'widgets/home_header.dart';
import 'widgets/scan_card.dart';
import 'widgets/tonight_card.dart';
import 'widgets/watchlist_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        context.read<UserRepository>(),
        context.read<SubscriptionRepository>(),
        context.read<WatchlistRepository>(),
      )..refresh(),
      child: const _HomeView(),
    );
  }
}

enum _ListTab { toWatch, watched }

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  _ListTab _tab = _ListTab.toWatch;

  Future<void> _onScanPressed(BuildContext context) async {
    if (!context.read<HomeCubit>().state.canScan) {
      await _openScreen(context, AppRoutes.paywall);
      return;
    }

    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      // Gemini works on smaller images anyway; less to upload is faster.
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (image == null || !context.mounted) return;

    final bytes = await image.readAsBytes();
    if (!context.mounted) return;

    await _openScreen(
      context,
      AppRoutes.scan,
      extra: ScanRequest(
        image: bytes,
        mimeType: image.mimeType ?? _mimeTypeFromPath(image.path),
      ),
    );
  }

  void _onTonightPressed(BuildContext context, HomeState state) {
    if (!state.isPremium) {
      _openScreen(context, AppRoutes.paywall);
    } else if (state.toWatch.isEmpty) {
      _showError(context, AppErrorType.emptyWatchlist);
    } else {
      _openScreen(context, AppRoutes.recommendation);
    }
  }

  void _showError(BuildContext context, AppErrorType error) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.message)));
  }

  /// Opens a screen on top of home and refreshes home when the user returns,
  /// because a scan or a purchase may have changed the remaining scans.
  Future<void> _openScreen(
    BuildContext context,
    String route, {
    Object? extra,
  }) async {
    await context.push(route, extra: extra);
    if (context.mounted) context.read<HomeCubit>().refresh();
  }

  List<Widget> _buildList(BuildContext context, HomeState state) {
    final items = _tab == _ListTab.toWatch ? state.toWatch : state.watched;
    if (items.isEmpty) {
      final message = _tab == _ListTab.toWatch
          ? LocaleKeys.home_empty_to_watch.tr()
          : LocaleKeys.home_empty_watched.tr();
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ];
    }
    return [
      for (final item in items)
        WatchlistTile(
          item: item,
          onTap: () =>
              _openScreen(context, AppRoutes.detail, extra: item.title),
          onRemove: () => context.read<HomeCubit>().remove(item),
        ),
    ];
  }

  String _quotaText(HomeState state) {
    if (state.isPremium) return LocaleKeys.home_premium_active.tr();
    return LocaleKeys.home_free_scans_left.plural(state.remainingFreeScans);
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            HomeHeader(
              name: homeState.name,
              onProfile: () => _openScreen(context, AppRoutes.profile),
            ),
            const SizedBox(height: 28),
            ScanCard(
              quotaText: _quotaText(homeState),
              onScan: () => _onScanPressed(context),
            ),
            const SizedBox(height: 12),
            TonightCard(
              isLocked: !homeState.isPremium,
              onPressed: () => _onTonightPressed(context, homeState),
            ),
            const SizedBox(height: 28),
            SegmentedButton<_ListTab>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _ListTab.toWatch,
                  label: Text(
                    _tabLabel(
                      LocaleKeys.home_tab_to_watch.tr(),
                      homeState.toWatch.length,
                    ),
                  ),
                ),
                ButtonSegment(
                  value: _ListTab.watched,
                  label: Text(
                    _tabLabel(
                      LocaleKeys.home_tab_watched.tr(),
                      homeState.watched.length,
                    ),
                  ),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (selection) {
                setState(() => _tab = selection.first);
              },
            ),
            const SizedBox(height: 16),
            ..._buildList(context, homeState),
          ],
        ),
      ),
    );
  }
}

String _tabLabel(String label, int count) =>
    count == 0 ? label : '$label · $count';

String _mimeTypeFromPath(String path) {
  final lowerPath = path.toLowerCase();
  if (lowerPath.endsWith('.png')) return 'image/png';
  if (lowerPath.endsWith('.webp')) return 'image/webp';
  if (lowerPath.endsWith('.heic')) return 'image/heic';
  return 'image/jpeg';
}
