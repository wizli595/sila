import 'package:flutter/material.dart';
import 'sila_thread.dart';

/// Branded loading state — the ambient thread drawing itself.
class ThreadLoading extends StatelessWidget {
  final String? label;

  const ThreadLoading({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 120,
            width: 280,
            child: SilaThread.ambient(thickness: 2),
          ),
          if (label != null)
            Text(label!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
