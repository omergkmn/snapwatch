import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/media_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import '../detail/detail_screen.dart';
import 'scan_cubit.dart';
import 'scan_request.dart';
import 'scan_state.dart';
import 'widgets/scanning_view.dart';

/// Shows the scanning progress and, in the same place, the result once the
/// AI answers. Keeping both in one route means home refreshes only once,
/// when the user comes back from the result.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key, required this.request});

  final ScanRequest request;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ScanCubit(
            context.read<MediaRepository>(),
            context.read<SubscriptionRepository>(),
          )..scan(
            image: request.image,
            mimeType: request.mimeType,
            languageCode: context.locale.languageCode,
          ),
      child: BlocBuilder<ScanCubit, ScanState>(
        builder: (context, state) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: switch (state) {
            ScanSuccess(:final title) => DetailScreen(title: title),
            ScanFailure(:final error) => ScanningView(
              image: request.image,
              error: error,
            ),
            ScanIdle() ||
            ScanInProgress() => ScanningView(image: request.image),
          },
        ),
      ),
    );
  }
}
