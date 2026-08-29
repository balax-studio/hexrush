import 'dart:ui';

/// Kamera görünür alan kırpma (Frustum / Viewport Culling) yöneticisi
/// Ekranda görünmeyen nesnelerin çizim maliyetini sıfıra indirmek için
/// Zero-GC havuzlarıyla çalışır.
class ViewportCullingManager {
  static final ViewportCullingManager instance = ViewportCullingManager._();
  ViewportCullingManager._();

  // Aktif görünür dünya koordinat alanı (Kamera görüşü)
  double _minX = -10000;
  double _minY = -10000;
  double _maxX = 10000;
  double _maxY = 10000;
  bool _enabled = true;

  bool get isEnabled => _enabled;
  set isEnabled(bool value) => _enabled = value;

  /// Kamera sınırlarını günceller (Güvenlik payı / margin ekleyerek)
  void updateVisibleBounds(Rect visibleRect, {double margin = 72.0}) {
    _minX = visibleRect.left - margin;
    _minY = visibleRect.top - margin;
    _maxX = visibleRect.right + margin;
    _maxY = visibleRect.bottom + margin;
  }

  /// Verilen merkez koordinatın ve yarıçapın ekran sınırları içinde olup olmadığını doğrular
  bool isVisible(Offset center, {double radius = 56.0}) {
    if (!_enabled) return true;
    final double x = center.dx;
    final double y = center.dy;

    if (x + radius < _minX) return false;
    if (x - radius > _maxX) return false;
    if (y + radius < _minY) return false;
    if (y - radius > _maxY) return false;

    return true;
  }

  /// Verilen dikdörtgen alanın ekranda olup olmadığını doğrular
  bool isRectVisible(double left, double top, double right, double bottom) {
    if (!_enabled) return true;
    if (right < _minX) return false;
    if (left > _maxX) return false;
    if (bottom < _minY) return false;
    if (top > _maxY) return false;

    return true;
  }

  /// Testler için sınırsız görünürlük moduna alır
  void resetForTesting() {
    _minX = -100000;
    _minY = -100000;
    _maxX = 100000;
    _maxY = 100000;
    _enabled = true;
  }
}
