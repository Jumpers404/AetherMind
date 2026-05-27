import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var text = file.readAsStringSync();

  final glassOriginal = """
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 20),
          child,
        ],
      ),
""";
  final glassNew = """
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
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
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
""";
  text = text.replaceFirst(glassOriginal, glassNew);
  file.writeAsStringSync(text);
  print('Patched glass header');
}
