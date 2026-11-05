import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// Server-side admin HTML is expected to be pre-sanitized; this pass is
/// **defense-in-depth** for mobile rendering (strip scripts, unknown tags,
/// unsafe URLs, then normalize upload paths for the mobile API).
abstract final class TemplateHtmlSanitizer {
  static const Set<String> _allowedTags = {
    'p',
    'br',
    'strong',
    'b',
    'em',
    'i',
    'u',
    's',
    'h1',
    'h2',
    'h3',
    'h4',
    'ul',
    'ol',
    'li',
    'a',
    'span',
    'blockquote',
    'table',
    'thead',
    'tbody',
    'tfoot',
    'tr',
    'th',
    'td',
    'caption',
    'colgroup',
    'col',
    'div',
    'img',
    'hr',
  };

  static const Set<String> _dangerousTags = {
    'script',
    'style',
    'iframe',
    'object',
    'embed',
    'link',
    'meta',
    'base',
    'form',
    'input',
    'button',
    'textarea',
    'select',
    'option',
  };

  /// Classes preserved on [p], [blockquote], [div] for alert styling.
  static const Set<String> _allowedAlertClasses = {
    'pd-alert-info',
    'pd-alert-warning',
    'pd-alert-danger',
    'pd-alert-success',
  };

  /// Returns empty string when there is no safe displayable content.
  static String sanitize(String? raw, {required String apiBaseUrl}) {
    if (raw == null) return '';
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final base = _normalizeBase(apiBaseUrl);

    if (!trimmed.contains('<')) {
      return '<p>${_escapePlain(trimmed)}</p>';
    }

    final doc = html_parser.parse('<div class="pd-san-root">$trimmed</div>');
    final root = doc.body?.querySelector('div.pd-san-root');
    if (root == null) return '';
    _visitElement(root, base);
    return root.innerHtml.trim();
  }

  static String _normalizeBase(String apiBaseUrl) {
    var b = apiBaseUrl.trim();
    while (b.endsWith('/')) {
      b = b.substring(0, b.length - 1);
    }
    return b;
  }

  static String _escapePlain(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;');
  }

  static void _visitElement(dom.Element el, String base) {
    final name = el.localName?.toLowerCase() ?? '';

    if (_dangerousTags.contains(name)) {
      el.remove();
      return;
    }

    for (final c in List<dom.Node>.from(el.nodes)) {
      if (c is dom.Element) {
        _visitElement(c, base);
      }
    }

    if (!_allowedTags.contains(name)) {
      _unwrap(el);
      return;
    }

    _sanitizeAttributes(el, name, base);
  }

  static void _unwrap(dom.Element el) {
    final parent = el.parent;
    if (parent == null) {
      el.remove();
      return;
    }
    final insert = List<dom.Node>.from(el.nodes);
    final idx = parent.nodes.indexOf(el);
    if (idx < 0) {
      el.remove();
      return;
    }
    parent.nodes.insertAll(idx, insert);
    el.remove();
  }

  static void _sanitizeAttributes(dom.Element el, String tag, String base) {
    final attrs = el.attributes;
    final keys = List<String>.from(attrs.keys);

    for (final k in keys) {
      final lk = k.toLowerCase();
      if (lk.startsWith('on')) {
        attrs.remove(k);
        continue;
      }
      if (lk == 'style' || lk == 'id') {
        attrs.remove(k);
        continue;
      }
    }

    switch (tag) {
      case 'a':
        _keepOnly(el, {'href', 'title', 'target', 'rel'});
        _sanitizeHref(el.attributes['href'], el, 'href');
        final h = el.attributes['href']?.trim();
        if (h == null || h.isEmpty) {
          _unwrap(el);
          return;
        }
        if (!h.startsWith('#')) {
          if (el.attributes.containsKey('target')) {
            el.attributes['target'] = '_blank';
          }
          el.attributes['rel'] = 'noopener noreferrer';
          _rewriteHrefToAbsolute(el, base);
        }
      case 'img':
        _keepOnly(el, {'src', 'alt', 'width', 'height', 'loading'});
        _sanitizeHref(el.attributes['src'], el, 'src');
        _rewriteSrcToAbsolute(el, base);
        if (!el.attributes.containsKey('src')) {
          el.remove();
          return;
        }
      case 'blockquote':
      case 'p':
        _filterClass(el);
        _keepOnly(el, {'class'});
      case 'div':
        _filterClass(el);
        if (el.attributes['class'] == null ||
            el.attributes['class']!.trim().isEmpty) {
          _unwrap(el);
          return;
        }
        _keepOnly(el, {'class'});
      case 'span':
        _filterClass(el);
        _keepOnly(el, {'class'});
        if (el.attributes['class'] == null ||
            el.attributes['class']!.trim().isEmpty) {
          _unwrap(el);
          return;
        }
      case 'td':
      case 'th':
        _keepOnly(el, {'colspan', 'rowspan', 'align'});
        _sanitizeColspan(el);
      case 'col':
        _keepOnly(el, {'span', 'width'});
      default:
        attrs.clear();
    }
  }

  static void _sanitizeColspan(dom.Element el) {
    for (final key in ['colspan', 'rowspan']) {
      final v = el.attributes[key];
      if (v == null) continue;
      final n = int.tryParse(v.trim());
      if (n == null || n < 1 || n > 50) {
        el.attributes.remove(key);
      } else {
        el.attributes[key] = '$n';
      }
    }
  }

  static void _filterClass(dom.Element el) {
    final raw = el.attributes['class']?.trim();
    if (raw == null || raw.isEmpty) {
      el.attributes.remove('class');
      return;
    }
    final kept = raw
        .split(RegExp(r'\s+'))
        .where(_allowedAlertClasses.contains)
        .join(' ')
        .trim();
    if (kept.isEmpty) {
      el.attributes.remove('class');
    } else {
      el.attributes['class'] = kept;
    }
  }

  static void _keepOnly(dom.Element el, Set<String> allowedAttrNamesLower) {
    final attrs = el.attributes;
    final keys = List<String>.from(attrs.keys);
    for (final k in keys) {
      if (!allowedAttrNamesLower.contains(k.toLowerCase())) {
        attrs.remove(k);
      }
    }
  }

  static void _sanitizeHref(String? href, dom.Element el, String attrName) {
    if (href == null || href.trim().isEmpty) {
      el.attributes.remove(attrName);
      return;
    }
    final t = href.trim();
    final low = t.toLowerCase();
    if (low.startsWith('javascript:') ||
        low.startsWith('data:') ||
        low.startsWith('vbscript:')) {
      el.attributes.remove(attrName);
      return;
    }
    if (t.startsWith('#')) {
      return;
    }
    if (low.startsWith('http://') || low.startsWith('https://')) {
      return;
    }
    if (t.startsWith('/')) {
      return;
    }
    el.attributes.remove(attrName);
  }

  static void _rewriteSrcToAbsolute(dom.Element img, String base) {
    final src = img.attributes['src'];
    if (src == null || src.isEmpty) return;
    var s = src.trim();
    if (s.contains('/api/admin/uploads/')) {
      s = s.replaceAll('/api/admin/uploads/', '/api/mobile/uploads/');
    }
    if (s.startsWith('http://') || s.startsWith('https://')) {
      if (s.startsWith('$base/') || s == base) {
        return;
      }
      img.attributes['src'] = s;
      return;
    }
    if (s.startsWith('/')) {
      img.attributes['src'] = '$base$s';
    }
  }

  static void _rewriteHrefToAbsolute(dom.Element a, String base) {
    final href = a.attributes['href'];
    if (href == null || href.isEmpty) return;
    var s = href.trim();
    if (s.startsWith('#')) {
      return;
    }
    if (s.contains('/api/admin/uploads/')) {
      s = s.replaceAll('/api/admin/uploads/', '/api/mobile/uploads/');
    }
    if (s.startsWith('http://') || s.startsWith('https://')) {
      a.attributes['href'] = s;
      return;
    }
    if (s.startsWith('/')) {
      a.attributes['href'] = '$base$s';
    }
  }
}
