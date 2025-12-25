import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/journal_entry.dart';
import '../../../../core/utils/mood_analyzer.dart';

class JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  const JournalCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        (entry.imageBase64 != null && entry.imageBase64!.isNotEmpty)
            ? MemoryImage(base64Decode(entry.imageBase64!))
            : null;

    final label = MoodAnalyzer.getLabel(entry.mood ?? '📝');
    final moodColor = Color(MoodAnalyzer.getColor(label));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // FIX: withOpacity -> withValues
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageProvider != null)
              Hero(
                tag: 'journal_img_${entry.id}',
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          // FIX: withOpacity -> withValues
                          color: moodColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.mood ?? '📝',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz,
                            size: 20, color: Colors.grey),
                        onSelected: (value) {
                          if (value == 'delete') onDelete();
                          if (value == 'fav') onFavoriteToggle();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'fav',
                            child: Row(children: [
                              Icon(
                                  entry.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: entry.isFavorite
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(entry.isFavorite ? "Unsave" : "Save"),
                            ]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text("Delete",
                                  style: TextStyle(color: Colors.red)),
                            ]),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
