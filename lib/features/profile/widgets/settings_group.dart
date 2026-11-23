import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// A titled card that stacks rows with thin dividers, like system settings.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(title!, style: Theme.of(context).textTheme.bodySmall),
            ),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final (index, child) in children.indexed) ...[
                  if (index > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      color: AppColors.border,
                    ),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
