import 'package:flutter/material.dart';

class Fact {
  final String id;
  final String text;
  final String category;
  final String tone;
  final Color background;
  final Color textColor;
  final String audioUrl;

  const Fact({
    required this.id,
    required this.text,
    required this.category,
    required this.tone,
    required this.background,
    required this.textColor,
    required this.audioUrl,
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
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/10/03/audio_43b2f9a4f6.mp3?filename=ambient-piano-ambient-11597.mp3',
  ),
  const Fact(
    id: 'f2',
    text:
        'Overthinking is sometimes your mind trying to protect you from uncertainty.',
    category: 'Anxiety',
    tone: 'Empathetic',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/15/audio_15dd87b5f3.mp3?filename=calm-meditation-10405.mp3',
  ),
  const Fact(
    id: 'f3',
    text:
        'You don\'t always need answers. Sometimes clarity comes after stillness.',
    category: 'Self-growth',
    tone: 'Calm',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_7697d0b088.mp3?filename=ambient-11057.mp3',
  ),
  const Fact(
    id: 'f4',
    text:
        'Emotional exhaustion often looks like laziness. Be kind to yourself when you need rest.',
    category: 'Emotions',
    tone: 'Gentle',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/02/23/audio_4f1ad62dc0.mp3?filename=forest-lullaby-110624.mp3',
  ),
  const Fact(
    id: 'f5',
    text:
        'Habits aren\'t just what you do. They are how your brain optimizes energy. Be patient when changing them.',
    category: 'Habits',
    tone: 'Educational',
    background: Color(0xFF111111),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2023/03/28/audio_1c8a3bb4a4.mp3?filename=calm-ambient-145057.mp3',
  ),
  const Fact(
    id: 'f6',
    text:
        'Tears contain stress hormones. Crying literally flushes stress out of your body.',
    category: 'Emotions',
    tone: 'Relief',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/08/01/audio_7c7b1c08fa.mp3?filename=ambient-112768.mp3',
  ),
  const Fact(
    id: 'f7',
    text:
        'Your mind naturally highlights the negative as a survival mechanism. It\'s not a flaw, it\'s ancient programming.',
    category: 'Mind',
    tone: 'Validating',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/11/audio_93a4f4b7b4.mp3?filename=deep-ambient-10167.mp3',
  ),
  const Fact(
    id: 'f8',
    text:
        'Procrastination is often an emotion-regulation problem, not a time-management problem.',
    category: 'Habits',
    tone: 'Insightful',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/09/12/audio_9b8d2a7a13.mp3?filename=ambient-113985.mp3',
  ),
  const Fact(
    id: 'f9',
    text:
        'Healing isn\'t a straight line. Sometimes you have to revisit an old feeling to finally let it go.',
    category: 'Self-growth',
    tone: 'Hopeful',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/09/29/audio_59b04f8b5d.mp3?filename=calm-ambient-9250.mp3',
  ),
  const Fact(
    id: 'f10',
    text:
        'Anxiety is your body\'s alarm system. Sometimes it gets stuck in the "on" position even when you are safe.',
    category: 'Anxiety',
    tone: 'Empathetic',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/03/15/audio_1c2c0c6b0e.mp3?filename=calm-11056.mp3',
  ),
  const Fact(
    id: 'f11',
    text:
        'Holding onto anger is like drinking poison and expecting the other person to die.',
    category: 'Emotions',
    tone: 'Reflective',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/10/31/audio_eeacbe0c6c.mp3?filename=deep-ambient-124508.mp3',
  ),
  const Fact(
    id: 'f12',
    text:
        'Your self-worth is not tied to your productivity. You are allowed to just exist.',
    category: 'Self-growth',
    tone: 'Gentle',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/01/20/audio_6a5c4e1c0c.mp3?filename=ambient-11013.mp3',
  ),
  const Fact(
    id: 'f13',
    text:
        'The feeling of "belonging" is a core human need, hardwired into our biology for survival.',
    category: 'Mind',
    tone: 'Educational',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/16/audio_9f9c8fd3d4.mp3?filename=meditation-10587.mp3',
  ),
  const Fact(
    id: 'f14',
    text:
        'Small daily habits compound over time. You are building the architecture of your future mind today.',
    category: 'Habits',
    tone: 'Inspiring',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/10/13/audio_9d1b0b7d59.mp3?filename=relaxing-ambient-9708.mp3',
  ),
  const Fact(
    id: 'f15',
    text:
        'Listening to slow, rhythmic music can physically lower your heart rate and ease anxiety.',
    category: 'Anxiety',
    tone: 'Actionable',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/15/audio_0e65c4d4d8.mp3?filename=calm-meditation-10366.mp3',
  ),
  const Fact(
    id: 'f16',
    text:
        'A brief walk can reset your nervous system faster than forcing yourself to push through fatigue.',
    category: 'Habits',
    tone: 'Practical',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/10/25/audio_4c7c1aefc1.mp3?filename=soft-ambient-122831.mp3',
  ),
  const Fact(
    id: 'f17',
    text:
        'Your brain learns safety through repetition. Small calm moments matter more than big breakthroughs.',
    category: 'Mind',
    tone: 'Grounding',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/03/10/audio_8c8eb3420c.mp3?filename=ambient-11015.mp3',
  ),
  const Fact(
    id: 'f18',
    text:
        'Self-compassion activates the same soothing systems in the brain that you feel when someone cares for you.',
    category: 'Self-growth',
    tone: 'Gentle',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/02/07/audio_63678af0db.mp3?filename=quiet-time-110436.mp3',
  ),
  const Fact(
    id: 'f19',
    text:
        'Your body reads your breath as a signal. Longer exhales can tell your nervous system it is safe.',
    category: 'Anxiety',
    tone: 'Actionable',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/10/16/audio_d3d6fce53b.mp3?filename=ambient-120973.mp3',
  ),
  const Fact(
    id: 'f20',
    text:
        'Boundaries are not walls. They are doors with clear rules for entry.',
    category: 'Self-growth',
    tone: 'Empowering',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/11/07/audio_40a3a86f3d.mp3?filename=ambient-125379.mp3',
  ),
  const Fact(
    id: 'f21',
    text:
        'When you name a feeling, your brain reduces its intensity. Labeling is a form of calm.',
    category: 'Emotions',
    tone: 'Grounding',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/02/audio_4f2a835c52.mp3?filename=meditation-10036.mp3',
  ),
  const Fact(
    id: 'f22',
    text:
        'Gentle consistency beats intensity. Your nervous system learns through repetition.',
    category: 'Habits',
    tone: 'Inspiring',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/08/02/audio_9f1e3b6ad6.mp3?filename=ambient-112780.mp3',
  ),
  const Fact(
    id: 'f23',
    text:
        'Your body keeps the score, but it also remembers safety. Small wins are evidence.',
    category: 'Self-growth',
    tone: 'Hopeful',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/03/audio_54423c2d8d.mp3?filename=ambient-10049.mp3',
  ),
  const Fact(
    id: 'f24',
    text:
        'Rest is not a reward; it is part of the work. Recovery builds resilience.',
    category: 'Emotions',
    tone: 'Gentle',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2022/02/04/audio_8a61d0ed8a.mp3?filename=relaxing-110307.mp3',
  ),
  const Fact(
    id: 'f25',
    text:
        'Anxiety narrows time. A slow breath is a way to widen it again.',
    category: 'Anxiety',
    tone: 'Actionable',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: 'https://cdn.pixabay.com/download/audio/2021/11/15/audio_6b474e82a4.mp3?filename=relaxing-meditation-10380.mp3',
  ),
  const Fact(
    id: 'f26',
    text:
        'A calm morning routine can act like a compass for your nervous system all day.',
    category: 'Habits',
    tone: 'Practical',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: '',
  ),
  const Fact(
    id: 'f27',
    text:
        'When you slow down your speech, your body receives the signal to slow down too.',
    category: 'Emotions',
    tone: 'Grounding',
    background: Color(0xFF173B36),
    textColor: Color(0xFFFFFFFF),
    audioUrl: '',
  ),
  const Fact(
    id: 'f28',
    text:
        'You do not need to earn rest. You can choose it.',
    category: 'Self-growth',
    tone: 'Gentle',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF1E1E1E),
    audioUrl: '',
  ),
  const Fact(
    id: 'f29',
    text:
        'Stress makes the future feel urgent. One steady breath brings you back to now.',
    category: 'Anxiety',
    tone: 'Actionable',
    background: Color(0xFF0E0E0E),
    textColor: Color(0xFFFFFFFF),
    audioUrl: '',
  ),
  const Fact(
    id: 'f30',
    text:
        'Self-kindness is a learned skill. Practice it like any other habit.',
    category: 'Self-growth',
    tone: 'Encouraging',
    background: Color(0xFFFFFFFF),
    textColor: Color(0xFF2F9E6F),
    audioUrl: '',
  ),
];
