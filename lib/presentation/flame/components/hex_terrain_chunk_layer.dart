import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// HexRush Statik Zemin Çizim Önbelleği (Offscreen Picture Chunk Layer)
/// Değişmeyen zemin ve 3D izometrik duvarları tek bir ui.Picture içinde saklayarak
/// kare başına yüzlerce Path çizimini 1 tek GPU çağrısına indirir.
class HexTerrainChunkLayer {
  ui.Picture? _cachedPicture;
  bool _isDirty = true;

  bool get isDirty => _isDirty;
  bool get hasCache => _cachedPicture != null;

  /// Katmanı yeniden çizim için işaretler (Karo fethedildiğinde veya bina dikildiğinde)
  void invalidate() {
    _isDirty = true;
    _cachedPicture?.dispose();
    _cachedPicture = null;
  }

  /// Statik çizim fonksiyonunu çalıştırıp çıktıyı ui.Picture olarak fırınlar
  void bake(void Function(Canvas canvas) renderCallback) {
    _cachedPicture?.dispose();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    renderCallback(canvas);

    _cachedPicture = recorder.endRecording();
    _isDirty = false;
  }

  /// Fırınlanmış resmi ekrana çizer; eğer kirliyse veya yoksa verilen callback'i çağırır
  void render(Canvas canvas, void Function(Canvas canvas) fallbackCallback) {
    if (_isDirty || _cachedPicture == null) {
      bake(fallbackCallback);
    }
    if (_cachedPicture != null) {
      canvas.drawPicture(_cachedPicture!);
    } else {
      fallbackCallback(canvas);
    }
  }

  /// Belleği serbest bırakır
  void dispose() {
    _cachedPicture?.dispose();
    _cachedPicture = null;
    _isDirty = true;
  }
}
