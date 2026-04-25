import 'package:flutter/material.dart';

class Fact {
  final String id;
  final String text;
  final String category;
  final String tone;
  final Color background;

  const Fact({
    required this.id,
    required this.text,
    required this.category,
    required this.tone,
    required this.background,
  });
}

// Sample thoughtful dataset matching the requested tone
final List<Fact> sampleFacts = [
  const Fact(
    id: 'f1',
    text:
        'Your brain often replays moments not to hurt you, but to understand what mattered.',
    category: 'Mind',
    tone: 'Reflective',
    background: Color(0xFFE8F5E9), // Soft green
  ),
  const Fact(
    id: 'f2',
    text:
        'Overthinking is sometimes your mind trying to protect you from uncertainty.',
    category: 'Anxiety',
    tone: 'Empathetic',
    background: Color(0xFFE3F2FD), // Soft blue
  ),
  const Fact(
    id: 'f3',
    text:
        'You don\'t always need answers. Sometimes clarity comes after stillness.',
    category: 'Self-growth',
    tone: 'Calm',
    background: Color(0xFFF3E5F5), // Soft purple
  ),
  const Fact(
    id: 'f4',
    text:
        'Emotional exhaustion often looks like laziness. Be kind to yourself when you need rest.',
    category: 'Emotions',
    tone: 'Gentle',
    background: Color(0xFFFFF3E0), // Soft orange
  ),
  const Fact(
    id: 'f5',
    text:
        'Habits aren\'t just what you do. They are how your brain optimizes energy. Be patient when changing them.',
    category: 'Habits',
    tone: 'Educational',
    background: Color(0xFFFBE9E7), // Soft coral
  ),
  const Fact(
    id: 'f6',
    text:
        'Tears contain stress hormones. Crying literally flushes stress out of your body.',
    category: 'Emotions',
    tone: 'Relief',
    background: Color(0xFFE0F7FA), // Soft cyan
  ),
  const Fact(
    id: 'f7',
    text:
        'Your mind naturally highlights the negative as a survival mechanism. It\'s not a flaw, it\'s ancient programming.',
    category: 'Mind',
    tone: 'Validating',
    background: Color(0xFFFFF8E1), // Soft yellow
  ),
  const Fact(
    id: 'f8',
    text:
        'Procrastination is often an emotion-regulation problem, not a time-management problem.',
    category: 'Habits',
    tone: 'Insightful',
    background: Color(0xFFECEFF1), // Soft blue-grey
  ),
  const Fact(
    id: 'f9',
    text:
        'Healing isn\'t a straight line. Sometimes you have to revisit an old feeling to finally let it go.',
    category: 'Self-growth',
    tone: 'Hopeful',
    background: Color(0xFFE8EAF6), // Soft indigo
  ),
  const Fact(
    id: 'f10',
    text:
        'Anxiety is your body\'s alarm system. Sometimes it gets stuck in the "on" position even when you are safe.',
    category: 'Anxiety',
    tone: 'Empathetic',
    background: Color(0xFFFFEBEE), // Soft red (very light)
  ),
  const Fact(
    id: 'f11',
    text:
        'Holding onto anger is like drinking poison and expecting the other person to die.',
    category: 'Emotions',
    tone: 'Reflective',
    background: Color(0xFFFFF3E0), // Soft orange
  ),
  const Fact(
    id: 'f12',
    text:
        'Your self-worth is not tied to your productivity. You are allowed to just exist.',
    category: 'Self-growth',
    tone: 'Gentle',
    background: Color(0xFFF1F8E9), // Soft light green
  ),
  const Fact(
    id: 'f13',
    text:
        'The feeling of "belonging" is a core human need, hardwired into our biology for survival.',
    category: 'Mind',
    tone: 'Educational',
    background: Color(0xFFE0F2F1), // Soft teal
  ),
  const Fact(
    id: 'f14',
    text:
        'Small daily habits compound over time. You are building the architecture of your future mind today.',
    category: 'Habits',
    tone: 'Inspiring',
    background: Color(0xFFFFFDE7), // Soft light yellow
  ),
  const Fact(
    id: 'f15',
    text:
        'Listening to slow, rhythmic music can physically lower your heart rate and ease anxiety.',
    category: 'Anxiety',
    tone: 'Actionable',
    background: Color(0xFFE1F5FE), // Soft light blue
  ),
];
