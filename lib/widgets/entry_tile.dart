import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_theme.dart';
import '../models/swipe_entry.dart';

class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, this.onDelete});

  final SwipeEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final isMeal = entry.type == EntryType.mealSwipe;
    final title = isMeal
        ? '${entry.location!.label} swipe'
        : 'Flex dollars · \$${entry.amount!.toStringAsFixed(2)}';
    final time = DateFormat('EEE, MMM d · h:mm a').format(entry.timestamp);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.crimson.withValues(alpha: 0.12),
        foregroundColor: AppColors.crimson,
        child: Icon(isMeal ? Icons.restaurant : Icons.attach_money),
      ),
      title: Text(title),
      subtitle: Text(time),
      trailing: onDelete == null
          ? null
          : IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Delete entry',
              onPressed: onDelete,
            ),
    );
  }
}
