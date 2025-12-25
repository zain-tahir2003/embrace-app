import 'dart:convert';
import 'package:flutter/material.dart';
import '../controllers/journal_controller.dart';

class RecycleBinScreen extends StatefulWidget {
  const RecycleBinScreen({super.key});

  @override
  State<RecycleBinScreen> createState() => _RecycleBinScreenState();
}

class _RecycleBinScreenState extends State<RecycleBinScreen> {
  final JournalController _controller = JournalController();

  @override
  void initState() {
    super.initState();
    _controller.loadDeletedJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Bin'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final deletedList = _controller.deletedJournals;

          if (deletedList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Recycle Bin is empty",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: deletedList.length,
            itemBuilder: (context, index) {
              final entry = deletedList[index];
              return Card(
                color: Colors.grey[200],
                child: ListTile(
                  leading: (entry.imageBase64 != null &&
                          entry.imageBase64!.isNotEmpty)
                      ? Opacity(
                          opacity: 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(entry.imageBase64!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : const Icon(Icons.book, color: Colors.grey),
                  title: Text(
                    entry.title,
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    ),
                  ),
                  subtitle: Text(entry.content, maxLines: 1),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () async {
                          await _controller.restoreJournal(entry);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Entry Restored')),
                          );
                        },
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () async {
                          await _controller.deletePermanently(entry.id!);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Deleted Permanently')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
