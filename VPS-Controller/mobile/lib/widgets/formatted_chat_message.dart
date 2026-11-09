import 'package:flutter/material.dart';

class FormattedChatMessage extends StatelessWidget {
  const FormattedChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.textColor,
  });

  final String text;
  final bool isUser;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    if (isUser) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14.5,
          height: 1.35,
        ),
      );
    }

    final codeBlockRegex = RegExp(r'```(?:[a-zA-Z0-9_\-]+)?\n([\s\S]*?)```');
    final matches = codeBlockRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      return _buildInlineFormattedText(text, textColor);
    }

    final children = <Widget>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        final regularText = text.substring(lastEnd, match.start).trim();
        if (regularText.isNotEmpty) {
          children.add(_buildInlineFormattedText(regularText, textColor));
          children.add(const SizedBox(height: 8));
        }
      }

      final codeContent = match.group(1)?.trimRight() ?? '';
      children.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF14171C),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: SelectableText(
            codeContent,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              color: Color(0xFF68D391),
              height: 1.4,
            ),
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd).trim();
      if (remaining.isNotEmpty) {
        children.add(const SizedBox(height: 8));
        children.add(_buildInlineFormattedText(remaining, textColor));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildInlineFormattedText(String input, Color color) {
    final spans = <InlineSpan>[];
    final parts = input.split('**');

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;
      final isBold = i % 2 == 1;

      // Detecta inline code `código`
      if (!isBold && part.contains('`')) {
        final codeParts = part.split('`');
        for (int c = 0; c < codeParts.length; c++) {
          final cp = codeParts[c];
          if (cp.isEmpty) continue;
          final isInlineCode = c % 2 == 1;
          if (isInlineCode) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cp,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF90CDF4),
                    ),
                  ),
                ),
              ),
            );
          } else {
            spans.add(TextSpan(text: cp));
          }
        }
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: color,
          fontSize: 14.5,
          height: 1.35,
        ),
        children: spans,
      ),
    );
  }
}
