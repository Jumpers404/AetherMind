import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var text = file.readAsStringSync();

  text = text.replaceAll('withValues(alpha: 0.5))', 'withValues(alpha: 0.5)');
  text = text.replaceAll('withValues(alpha: 0.8))', 'withValues(alpha: 0.8)');
  text = text.replaceAll('withValues(alpha: 0.32))', 'withValues(alpha: 0.32)');
  text = text.replaceAll('withValues(alpha: 0.4))', 'withValues(alpha: 0.4)');
  text = text.replaceAll('withValues(alpha: 0.15))', 'withValues(alpha: 0.15)');
  text = text.replaceAll('withValues(alpha: 0.08))', 'withValues(alpha: 0.08)');
  text = text.replaceAll('withValues(alpha: 0.3))', 'withValues(alpha: 0.3)');
  text = text.replaceAll('withValues(alpha: 0.1))', 'withValues(alpha: 0.1)');
  
  file.writeAsStringSync(text);
  print('Fixed opacity');
}
