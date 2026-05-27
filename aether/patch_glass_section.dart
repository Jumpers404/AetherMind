import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var code = file.readAsStringSync();

  final startStr = '  Widget _buildGlassSection({';
  final endStr = '    return innerContainer;\n  }';
  final startIndex = code.indexOf(startStr);
  final endIndex = code.indexOf(endStr, startIndex) + endStr.length;
  
  if (startIndex == -1 || endIndex == -1) {
    print('Could not find _buildGlassSection block');
    return;
  }
  
  final replacement = '''
  Widget _buildGlassSection({required String title, required Widget child, VoidCallback? onEdit, bool isHero = false}) {
    if (isHero) {
      return AnimatedBuilder(
        animation: _gradientController,
        builder: (context, _) {
          final alignmentX = -1.0 + (_gradientController.value * 2.0);
          
          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.32),
                  gradient: LinearGradient(
                    begin: Alignment(alignmentX, -1),
                    end: Alignment(-alignmentX, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      const Color(0xFFEAF7F2).withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3C44).withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSleekTitle(title),
                  if (onEdit != null)
                    GestureDetector(
                      onTap: onEdit,
                      child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF4DA692)),
                    ),
                ],
              ),
            if (title.isNotEmpty) const SizedBox(height: 16),
            child,
          ],
        ),
      );
    }
  }
''';

  code = code.substring(0, startIndex) + replacement.trim() + code.substring(endIndex);
  file.writeAsStringSync(code);
  print('Replaced _buildGlassSection');
}
