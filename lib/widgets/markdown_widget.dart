import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';
import 'package:flutter_highlighter/themes/atom-one-light.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import '../core/constants/app_colors.dart';

class CustomMarkdownWidget extends StatelessWidget {
  final String content;
  final bool isUser;

  const CustomMarkdownWidget({
    super.key,
    required this.content,
    this.isUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (isUser) {
      return SelectableText(
        content,
        style: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 15,
          height: 1.5,
        ),
      );
    }

    return MarkdownBody(
      data: content,
      selectable: true,
      onTapLink: (text, href, title) async {
        if (href != null) {
          final uri = Uri.parse(href);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      builders: {
        'code': CodeBlockBuilder(isDark: isDark),
      },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        h1: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        h2: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        h3: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        blockquote: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: isDark ? AppColors.darkInput : AppColors.lightInput,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: AppColors.primary,
              width: 3,
            ),
          ),
        ),
        code: TextStyle(
          backgroundColor: isDark ? AppColors.darkInput : AppColors.lightInput,
          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
          fontFamily: 'monospace',
          fontSize: 13,
        ),
      ),
    );
  }
}

class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDark;

  CodeBlockBuilder({required this.isDark});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = 'plaintext';
    if (element.attributes.containsKey('class')) {
      final lg = element.attributes['class'];
      if (lg != null && lg.startsWith('language-')) {
        language = lg.replaceFirst('language-', '');
      }
    }

    final codeContent = element.textContent.trim();

    // If inline code block without newlines, render default inline code style
    if (!element.textContent.contains('\n') && language == 'plaintext') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkInput : AppColors.lightInput,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          codeContent,
          style: TextStyle(
            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            fontFamily: 'monospace',
            fontSize: 13,
          ),
        ),
      );
    }

    return CodeBlockView(
      code: codeContent,
      language: language,
      isDark: isDark,
    );
  }
}

class CodeBlockView extends StatefulWidget {
  final String code;
  final String language;
  final bool isDark;

  const CodeBlockView({
    super.key,
    required this.code,
    required this.language,
    required this.isDark,
  });

  @override
  State<CodeBlockView> createState() => _CodeBlockViewState();
}

class _CodeBlockViewState extends State<CodeBlockView> {
  bool _isCopied = false;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.code));
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMap = widget.isDark ? atomOneDarkTheme : atomOneLightTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.codeBackgroundDark : AppColors.codeBackgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar with language title & copy code button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF2D2D37) : const Color(0xFFE5E5E7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.language.toUpperCase(),
                  style: TextStyle(
                    color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  onTap: _copyCode,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          _isCopied ? Icons.check : Icons.copy_rounded,
                          size: 14,
                          color: _isCopied ? AppColors.primary : (widget.isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isCopied ? 'Copied!' : 'Copy code',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isCopied ? AppColors.primary : (widget.isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Code syntax highlighting container
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(12),
            child: HighlightView(
              widget.code,
              language: widget.language,
              theme: themeMap,
              padding: const EdgeInsets.all(0),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
