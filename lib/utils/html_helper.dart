import 'package:flutter/material.dart';

/// HTML处理工具类
class HtmlHelper {
  /// 将HTML转换为纯文本
  static String htmlToPlainText(String html) {
    String text = html;

    // 移除脚本和样式
    text = RegExp(r'<script[^>]*>[\s\S]*?</script>', caseSensitive: false)
        .replaceAll(text, '');
    text = RegExp(r'<style[^>]*>[\s\S]*?</style>', caseSensitive: false)
        .replaceAll(text, '');

    // 替换常见HTML标签为换行
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n\n');
    text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');

    // 移除所有剩余HTML标签
    text = RegExp(r'<[^>]+>').replaceAll(text, '');

    // 解码HTML实体
    text = _decodeHtmlEntities(text);

    // 清理多余空白
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.trim();

    return text;
  }

  /// 将纯文本转换为简单HTML
  static String plainTextToHtml(String text) {
    String html = _escapeHtml(text);

    // 将换行转换为段落
    final paragraphs = html.split('\n');
    html = paragraphs
        .where((p) => p.trim().isNotEmpty)
        .map((p) => '<p>$p</p>')
        .join('\n');

    return html;
  }

  /// HTML实体解码
  static String _decodeHtmlEntities(String text) {
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    text = text.replaceAll('&nbsp;', ' ');
    return text;
  }

  /// HTML转义
  static String _escapeHtml(String text) {
    text = text.replaceAll('&', '&amp;');
    text = text.replaceAll('<', '&lt;');
    text = text.replaceAll('>', '&gt;');
    text = text.replaceAll('"', '&quot;');
    text = text.replaceAll("'", '&#39;');
    return text;
  }

  /// 从HTML中提取纯文本摘要
  static String extractSummary(String html, {int maxLength = 200}) {
    final text = htmlToPlainText(html);
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// 计算纯文本字数（仅计算中文字符和英文单词）
  static int countWords(String html) {
    final text = htmlToPlainText(html);
    if (text.isEmpty) return 0;

    int count = 0;

    // 计算中文字符
    final chineseChars = RegExp(r'[\u4e00-\u9fff]');
    count += chineseChars.allMatches(text).length;

    // 计算英文单词（移除中文字符后）
    final withoutChinese = text.replaceAll(RegExp(r'[\u4e00-\u9fff]'), ' ');
    final englishWords = withoutChinese.split(RegExp(r'\s+'));
    count += englishWords.where((w) => w.isNotEmpty).length;

    return count;
  }

  /// 高亮搜索关键词
  static String highlightKeyword(String text, String keyword) {
    if (keyword.isEmpty) return text;
    final escaped = RegExp.escape(keyword);
    return text.replaceAllMapped(
      RegExp(escaped, caseSensitive: false),
      (match) => '<mark>${match.group(0)}</mark>',
    );
  }
}
