import 'package:flutter/material.dart';

import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image for Image Type Notes
          if (note.type == NoteType.image && note.imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(note.imagePath!, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
          ],

          // Title
          Text(
            note.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Content based on Type
          if (note.type == NoteType.checklist && note.items != null)
            ...note.items!.map((item) => _buildChecklistItem(item)),

          if (note.type == NoteType.text)
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),

          if (note.type == NoteType.image && note.content.isNotEmpty)
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.transparent,
            ), // Unchecked
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
