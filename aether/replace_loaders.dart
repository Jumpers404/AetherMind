import 'dart:io';

void main() {
  final libDir = Directory('lib');
  for (var entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('auth_flow_loader.dart')) {
      String content = entity.readAsStringSync();
      if (content.contains('CircularProgressIndicator')) {
        while(true) {
          int startIdx = content.indexOf('CircularProgressIndicator');
          if (startIdx == -1) break;
          
          int parenDepth = 0;
          int endIdx = -1;
          bool foundOpen = false;
          
          for (int i = startIdx; i < content.length; i++) {
            if (content[i] == '(') {
              parenDepth++;
              foundOpen = true;
            } else if (content[i] == ')') {
              parenDepth--;
              if (parenDepth == 0 && foundOpen) {
                endIdx = i;
                break;
              }
            }
          }
          
          if (endIdx != -1) {
            String toReplace = content.substring(startIdx, endIdx + 1);
            content = content.replaceFirst(toReplace, 'SnakeLoadingIndicator()');
          } else {
            break; // malformed or something?
          }
        }
        
        // Remove const
        content = content.replaceAll('const SnakeLoadingIndicator()', 'SnakeLoadingIndicator()');
        content = content.replaceAll('child: SnakeLoadingIndicator()', 'child: const SnakeLoadingIndicator()');
        
        // Add imports
        if (!content.contains('auth_flow_loader.dart')) {
          int idx = content.indexOf("import 'package:flutter/material.dart';");
          if (idx != -1) {
            content = content.replaceFirst(
                "import 'package:flutter/material.dart';",
                "import 'package:flutter/material.dart';\nimport 'package:aether/widgets/auth_flow_loader.dart';");
          } else {
            int lastImport = content.lastIndexOf(RegExp(r"^import '.*';$", multiLine: true));
            if (lastImport != -1) {
                int endOfLine = content.indexOf('\n', lastImport);
                content = content.substring(0, endOfLine) + "\nimport 'package:aether/widgets/auth_flow_loader.dart';" + content.substring(endOfLine);
            } else {
                content = "import 'package:aether/widgets/auth_flow_loader.dart';\n" + content;
            }
          }
        }
        
        entity.writeAsStringSync(content);
        print('Updated ${entity.path}');
      }
    }
  }
}
