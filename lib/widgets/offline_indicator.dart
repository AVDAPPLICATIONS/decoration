import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    
    if (isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
        ],
      ),
    );
  }
}
