/// 素材路径集中管理，页面不直接拼 assets 字符串。
abstract final class App16Assets {
  static const _root = 'assets/images/16';

  static String icon(String name) => '$_root/icons/$name.svg';
  static String sticker(String name) => '$_root/stickers/$name.svg';
  static String photo(String name) => '$_root/photos/$name.webp';
  static const paperGrain = '$_root/textures/paper-grain.png';

  /// Seed files use the handoff paths (`assets/stickers/...`); saved drafts may
  /// still carry them, so normalize at the boundary instead of rewriting data.
  static String resolve(String src) {
    if (src.startsWith('assets/stickers/')) {
      return '$_root/stickers/${src.substring('assets/stickers/'.length)}';
    }
    if (src.startsWith('assets/photos/')) {
      return '$_root/photos/${src.substring('assets/photos/'.length)}';
    }
    if (src.startsWith('assets/textures/')) {
      return '$_root/textures/${src.substring('assets/textures/'.length)}';
    }
    if (src.startsWith('assets/icons/')) {
      return '$_root/icons/${src.substring('assets/icons/'.length)}';
    }
    return src;
  }

  static bool isAsset(String src) => src.startsWith('assets/');
}
