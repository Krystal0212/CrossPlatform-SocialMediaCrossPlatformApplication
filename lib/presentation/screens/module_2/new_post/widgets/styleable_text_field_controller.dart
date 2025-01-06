
import 'package:socialapp/utils/import.dart';

class StyleableTextFieldController extends TextEditingController {
  StyleableTextFieldController( {
     this.defaultStyle,
    required this.styles,
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap();

  final TextPartStyleDefinitions styles;
  final TextStyle? defaultStyle;
  final Pattern combinedPattern;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition =
        styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        _addTextSpan(
          textSpanChildren,
          textPart,
          style?.merge(styleDefinition.style),
        );

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text, defaultStyle ?? style);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpan(
      List<InlineSpan> textSpanChildren,
      String? textToBeStyled,
      TextStyle? style,
      ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: style,
      ),
    );
  }
}

class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.style,
  });

  final String pattern;
  final TextStyle style;
}

class TextPartStyleDefinitions {
  TextPartStyleDefinitions({required this.definitionList});

  final List<TextPartStyleDefinition> definitionList;

  RegExp createCombinedPatternBasedOnStyleMap() {
    final String combinedPatternString = definitionList
        .map<String>(
          (TextPartStyleDefinition textPartStyleDefinition) =>
      textPartStyleDefinition.pattern,
    )
        .join('|');

    return RegExp(
      combinedPatternString,
      multiLine: true,
      caseSensitive: false,
    );
  }

  TextPartStyleDefinition? getStyleOfTextPart(
      String textPart,
      String text,
      ) {
    return List<TextPartStyleDefinition?>.from(definitionList).firstWhere(
          (TextPartStyleDefinition? styleDefinition) {
        if (styleDefinition == null) return false;

        bool hasMatch = false;

        RegExp(styleDefinition.pattern, caseSensitive: false)
            .allMatches(text)
            .forEach(
              (RegExpMatch currentMatch) {
            if (hasMatch) return;

            if (currentMatch.group(0) == textPart) {
              hasMatch = true;
            }
          },
        );

        return hasMatch;
      },
      orElse: () => null,
    );
  }
}