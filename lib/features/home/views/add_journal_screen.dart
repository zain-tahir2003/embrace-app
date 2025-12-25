import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/journal_controller.dart';
import '../models/journal_entry.dart';

class AddJournalScreen extends StatefulWidget {
  final JournalEntry? entry;
  final JournalController controller;

  const AddJournalScreen({
    super.key,
    this.entry,
    required this.controller,
  });

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  Uint8List? _imageBytes;
  String? _base64Image;

  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?.title ?? '');
    _contentController =
        TextEditingController(text: widget.entry?.content ?? '');

    if (widget.entry?.imageBase64 != null) {
      _base64Image = widget.entry!.imageBase64;
      try {
        _imageBytes = base64Decode(_base64Image!);
      } catch (e) {
        // Ignored: Image data is corrupted or invalid, so we just don't show it.
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a title!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.entry == null) {
        await widget.controller.addJournal(
            _titleController.text, _contentController.text, _base64Image);
      } else {
        await widget.controller.updateJournal(widget.entry!.id!,
            _titleController.text, _contentController.text, _base64Image);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // PROFESSIONAL UI DESIGN
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isSaving
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
                : FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text("Save"),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE AREA WITH HERO ANIMATION
            GestureDetector(
              onTap: _pickImage,
              child: Hero(
                // Logic: If editing, use ID tag. If new, use 'new_img' tag.
                tag: widget.entry?.id != null
                    ? 'journal_img_${widget.entry!.id}'
                    : 'new_img',
                child: Container(
                  height: 250, // Taller for better editing experience
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    image: _imageBytes != null
                        ? DecorationImage(
                            image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 32, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            // Material wrapper prevents text style issues during Hero flight
                            Material(
                              color: Colors.transparent,
                              child: Text("Add Cover Image",
                                  style: TextStyle(color: Colors.grey[500])),
                            )
                          ],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TITLE INPUT
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title your memory...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 12),

            // DATE DISPLAY
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  "Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // CONTENT INPUT
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                hintText: 'How are you feeling right now?',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 16, height: 1.5),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
