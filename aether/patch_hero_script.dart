import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  final text = file.readAsStringSync();

  final oldHeroStart = text.indexOf('  Widget _buildHeroGlassCard() {');
  final oldHeroEnd = text.indexOf('  Widget _buildMiniSocialStat(');

  if (oldHeroStart != -1 && oldHeroEnd != -1) {
    final oldHeroFull = text.substring(oldHeroStart, oldHeroEnd);
    final newHero = File('hero_card.dart').readAsStringSync();
    
    final newText = text.replaceFirst(oldHeroFull, newHero);
    file.writeAsStringSync(newText);
    print('Replaced hero safely');
  } else {
    print('Could not find bounds');
  }
}
