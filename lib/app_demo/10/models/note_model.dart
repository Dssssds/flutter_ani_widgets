import 'package:flutter/material.dart';

enum NoteType { text, checklist, image }

class Note {
  final String id;
  final String title;
  final String content;
  final NoteType type;
  final Color color;
  final String group; // New field
  final List<String>? items; // For checklist
  final String? imagePath; // For image notes
  final bool isWide; // For spanning 2 columns

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.color,
    required this.group,
    this.items,
    this.imagePath,
    this.isWide = false,
  });
}

// Mock Data
final List<Note> mockNotes = [
  const Note(
    id: '1',
    title: 'Purpose of life',
    content:
        'We have probably all getting caught up in our own thought at some point while citing.\n\nList of assets that must be reported to the government whether in the form of cash...',
    type: NoteType.text,
    color: Color(0xFFFDF6E3), // Beige
    group: 'Important',
  ),
  const Note(
    id: '2',
    title: 'Plan for the today',
    content: '',
    type: NoteType.checklist,
    color: Color(0xFFFFF8E1), // Pale Yellow
    items: ['Work', 'Meeting'],
    group: 'Work',
  ),
  const Note(
    id: '3',
    title: 'Book covers',
    content:
        'In publishing and graphic design and graphic design, totem pram is oder test...',
    type: NoteType.image,
    color: Color(0xFFF8BBD0), // Pale Pink
    imagePath: 'assets/images/data/a.png', // Placeholder
    group: 'Reading',
  ),
  const Note(
    id: '4',
    title: 'Buy honey 100%...',
    content:
        'Wifi indoor: to reset the wifi password on time to don\'t get confusion after-weeks.',
    type: NoteType.text,
    color: Color(0xFFE8EAF6), // Pale Blue/Periwinkle
    group: 'Life',
  ),
  const Note(
    id: '5',
    title: 'Content Plan for...',
    content:
        'The most important aspect in the meaning that builds the mean and regard of life...',
    type: NoteType.text,
    color: Color(0xFFE0F7FA), // Mint/Cyan
    group: 'Work',
  ),
  const Note(
    id: '6',
    title: 'Password gelato cafe near the station',
    content:
        'List of assets that must be reported to the government. whether in the form of government.',
    type: NoteType.image,
    color: Color(0xFFE8EAF6), // Pale Blue
    imagePath: 'assets/images/rule/swordsman.png', // Placeholder
    isWide: true,
    group: 'Life',
  ),
];
