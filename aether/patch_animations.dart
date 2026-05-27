import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var code = file.readAsStringSync();

  // 1. Add animate controller in state
  if (!code.contains('AnimationController _gradientController')) {
    code = code.replaceFirst('AnimationController _revealController;', 'AnimationController _revealController;\n  late AnimationController _gradientController;');
    code = code.replaceFirst('    _revealController = AnimationController(', '    _gradientController = AnimationController(\n      vsync: this,\n      duration: const Duration(seconds: 8),\n    )..repeat(reverse: true);\n    _revealController = AnimationController(');
    code = code.replaceFirst('_revealController.dispose();', '_gradientController.dispose();\n    _revealController.dispose();');
  }

  file.writeAsStringSync(code);
}
