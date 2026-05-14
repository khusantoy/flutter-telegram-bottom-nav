import 'package:flutter/material.dart';

class ChatsTab extends StatelessWidget {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final rowBg =
        isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
    final dividerColor =
        isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 16, bottom: 120),
        itemCount: 20,
        separatorBuilder: (_, _) => Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 76,
          color: dividerColor,
        ),
        itemBuilder: (context, i) {
          return Container(
            color: rowBg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.primaries[i % Colors.primaries.length]
                      .shade400,
                  child: Text(
                    String.fromCharCode(65 + (i % 26)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat ${i + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last message preview goes here…',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
