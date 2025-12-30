import 'package:flutter/material.dart';

enum NoteType { text, checklist, image }

class Note {
  final String id;
  final String title;
  final String content;
  final String? mdContent; // Markdown content for editor
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
    this.mdContent,
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
    mdContent: '''# Purpose of life

## Introduction

We have probably all getting caught up in our own thought at some point while citing.

## Key Points

- **Self-reflection** is essential for personal growth
- Understanding our thoughts helps us navigate life better
- Awareness leads to better decision-making

## Financial Considerations

List of assets that must be reported to the government whether in the form of:
- Cash holdings
- Property investments
- Stock portfolios
- Business interests

> "The unexamined life is not worth living." - Socrates

## Next Steps

1. Practice daily meditation
2. Keep a thought journal
3. Review financial records quarterly
''',
    type: NoteType.text,
    color: Color(0xFFFDF6E3), // Beige
    group: 'Important',
  ),
  const Note(
    id: '2',
    title: 'Plan for the today',
    content: '',
    mdContent: '''# Today's Plan

## Morning Tasks
- [ ] Work on project proposal
- [ ] Meeting with team at 10 AM

## Afternoon
- [ ] Review code changes
- [ ] Prepare presentation slides

## Evening
- [ ] Send status update email
- [ ] Plan tomorrow's tasks
''',
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
    mdContent: '''# Book Covers

## Design Principles

In publishing and graphic design, the book cover is the first impression.

### Typography
- **Font selection** matters greatly
- Size and spacing create hierarchy
- Color contrast improves readability

### Visual Elements
1. Eye-catching imagery
2. Balanced composition
3. Clear branding

## Current Trends

Modern book covers often feature:
- Minimalist designs
- Bold typography
- Vibrant color palettes
- Abstract illustrations

> A great cover sells the book before it's opened.
''',
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
    mdContent: '''# Home Reminders

## Shopping List
- Buy 100% organic honey from local store
- Get fresh bread from bakery
- Stock up on coffee beans

## WiFi Management

### Password Reset Schedule
**Important**: Reset the WiFi password regularly to maintain security.

- Current password expires: End of month
- New password format: `Home_[Month][Year]_[Random]`
- Update all devices after reset

### Connected Devices
1. Laptops (3)
2. Smartphones (4)
3. Smart TV
4. IoT devices (5)

## Weekly Maintenance
- [ ] Check router firmware updates
- [ ] Review connected devices list
- [ ] Test connection speed
''',
    type: NoteType.text,
    color: Color(0xFFE8EAF6), // Pale Blue/Periwinkle
    group: 'Life',
  ),
  const Note(
    id: '5',
    title: 'Content Plan for...',
    content:
        'The most important aspect in the meaning that builds the mean and regard of life...',
    mdContent: '''# Content Plan for Q1

## Overview

The most important aspect in the meaning that builds the mean and regard of life is consistency and authenticity.

## Content Pillars

### 1. Educational Content
- **How-to guides**: 2 per week
- **Tutorials**: 1 per week
- **Case studies**: 2 per month

### 2. Engagement Content
- Behind-the-scenes stories
- Team member spotlights
- Community highlights

### 3. Thought Leadership
- Industry trends analysis
- Opinion pieces
- Expert interviews

## Publishing Schedule

| Day | Content Type | Platform |
|-----|-------------|----------|
| Mon | Tutorial | Blog |
| Wed | Quick tip | Social |
| Fri | Case study | Newsletter |

## KPIs to Track
1. Engagement rate
2. Conversion rate
3. Audience growth
4. Content shares

> Quality over quantity - every piece should provide value.
''',
    type: NoteType.text,
    color: Color(0xFFE0F7FA), // Mint/Cyan
    group: 'Work',
  ),
  const Note(
    id: '6',
    title: 'Password gelato cafe near the station',
    content:
        'List of assets that must be reported to the government. whether in the form of government.',
    mdContent: '''# Favorite Places

## Gelato Cafe Near Station

### Location Details
- **Address**: 123 Station Road
- **Distance**: 5 min walk from station
- **Opening hours**: 10:00 - 22:00

### Menu Highlights
1. **Classic Flavors**
   - Vanilla bean
   - Dark chocolate
   - Strawberry fresh

2. **Special Flavors**
   - Matcha green tea
   - Salted caramel
   - Pistachio cream

### WiFi Information
- Network: `CafeGelato_Guest`
- Password: `Sweet2024!`
- Speed: Fast enough for work

## Important Documents

### Asset Declaration
List of assets that must be reported to the government:
- Real estate properties
- Investment accounts
- Business ownership stakes
- Foreign bank accounts

**Deadline**: Annual reporting required by March 31st

> Remember to bring laptop for work sessions!
''',
    type: NoteType.image,
    color: Color(0xFFE8EAF6), // Pale Blue
    imagePath: 'assets/images/rule/swordsman.png', // Placeholder
    isWide: true,
    group: 'Life',
  ),
];
