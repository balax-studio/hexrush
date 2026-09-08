import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 3D Voxel İzometrik Derinlik Sıralı Canlı Render Motoru (Depth-Sorted Voxel Fauna Engine)
/// Her voksel prizması izometrik kamera derinliğine (Z-order) göre arkadan öne doğru çizilir.
class VoxelFaunaRenderer {
  static const double isoAngle = 30.0 * (math.pi / 180.0);
  static final double cosIso = math.cos(isoAngle);
  static final double sinIso = math.sin(isoAngle);

  // Zero-GC Reusable static Paint & Path pools
  static final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _cubeShadowPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _cubePenumbraPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _cubeSpecularPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final Path _cubeShadowPath = Path();
  static final Path _cubePenumbraPath = Path();
  static final Path _cubeSpecularPath = Path();
  static final Path _cubeLeftPath = Path();
  static final Path _cubeRightPath = Path();
  static final Path _cubeTopPath = Path();

  // ZERO-GC DERİNLİK SIRALAMA MOTORU (PAINTER'S ALGORITHM BUFFER)
  static final List<_VoxelPrimitive> _pool = List.generate(64, (_) => _VoxelPrimitive());
  static int _count = 0;

  static void _clear() {
    _count = 0;
  }

  /// 3D Lokal Koordinatlardan (lx, ly, lz) Derinlik Sıralı Voksel Ekler
  /// lx: Boyuna eksen (Kuyruk: -lx, Baş: +lx)
  /// ly: Enine eksen (Uzak taraf: -ly, Yakın taraf: +ly)
  /// lz: Dikey yükseklik (Zemin: 0, Yukarı: +lz)
  static void _addVoxel({
    required double lx,
    required double ly,
    required double lz,
    required double w,
    required double d,
    required double h,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
    required Offset origin,
    required double scale,
    bool drawShadow = false,
    double shadowOpacity = 0.28,
    bool flipX = false,
  }) {
    if (_count >= _pool.length) return;
    final prim = _pool[_count++];

    // flipX durumunda matematiksel olarak izometrik eksen takası yapılır:
    // ScreenX = (ly - lx) * cos = -(lx - ly) * cos (X aynalanır)
    // ScreenY = (ly + lx) * sin = (lx + ly) * sin (Y bozulmaz)
    final double effLx = flipX ? ly : lx;
    final double effLy = flipX ? lx : ly;
    final double effW = flipX ? d : w;
    final double effD = flipX ? w : d;

    final double sx = origin.dx + (effLx - effLy) * cosIso * scale;
    final double sy = origin.dy + (effLx + effLy) * sinIso * scale - lz * scale;

    // İzometrik Derinlik: (effLx + effLy) kameraya mesafeyi belirler;
    // lz yalnızca aynı tabandaki katmanların üst üste binme önceliğini çözer.
    final double depth = (effLx + effLy) * 1000.0 + (lz * 0.5);

    prim
      ..screenX = sx
      ..screenY = sy
      ..w = effW * scale
      ..d = effD * scale
      ..h = h * scale
      ..depth = depth
      ..topColor = topColor
      ..leftColor = flipX ? rightColor : leftColor
      ..rightColor = flipX ? leftColor : rightColor
      ..drawShadow = drawShadow
      ..shadowOpacity = shadowOpacity;
  }

  /// Bufferdaki tüm vokselleri derinliklerine göre arkadan öne sıralayıp çizer
  static void _flush(Canvas canvas) {
    for (int i = 1; i < _count; i++) {
      int j = i;
      while (j > 0 && _pool[j - 1].depth > _pool[j].depth) {
        _swapPrimitive(j - 1, j);
        j--;
      }
    }

    for (int i = 0; i < _count; i++) {
      final p = _pool[i];
      drawIsoCube(
        canvas,
        Offset(p.screenX, p.screenY),
        w: p.w,
        d: p.d,
        h: p.h,
        topColor: p.topColor,
        leftColor: p.leftColor,
        rightColor: p.rightColor,
        drawShadow: p.drawShadow,
        shadowOpacity: p.shadowOpacity,
      );
    }
  }

  static void _swapPrimitive(int i, int j) {
    final a = _pool[i];
    final b = _pool[j];

    final tx = a.screenX; a.screenX = b.screenX; b.screenX = tx;
    final ty = a.screenY; a.screenY = b.screenY; b.screenY = ty;
    final tw = a.w; a.w = b.w; b.w = tw;
    final td = a.d; a.d = b.d; b.d = td;
    final th = a.h; a.h = b.h; b.h = th;
    final tdepth = a.depth; a.depth = b.depth; b.depth = tdepth;
    final ttop = a.topColor; a.topColor = b.topColor; b.topColor = ttop;
    final tleft = a.leftColor; a.leftColor = b.leftColor; b.leftColor = tleft;
    final tright = a.rightColor; a.rightColor = b.rightColor; b.rightColor = tright;
    final tshad = a.drawShadow; a.drawShadow = b.drawShadow; b.drawShadow = tshad;
    final topac = a.shadowOpacity; a.shadowOpacity = b.shadowOpacity; b.shadowOpacity = topac;
  }

  /// Geometrik olarak kusursuz hizalanmış 3D İzometrik Voksel Prizması Çizer
  static void drawIsoCube(
    Canvas canvas,
    Offset baseCenter, {
    required double w,
    required double d,
    required double h,
    required Color topColor,
    required Color leftColor,
    required Color rightColor,
    bool drawShadow = false,
    double shadowOpacity = 0.28,
    bool specularHighlight = true,
  }) {
    final double halfW = w * 0.5;
    final double halfD = d * 0.5;

    final double wx = halfW * cosIso;
    final double wy = halfW * sinIso;
    final double dx = -halfD * cosIso;
    final double dy = halfD * sinIso;

    final double bx = baseCenter.dx;
    final double by = baseCenter.dy;

    // w != d durumlarında kaymayı önleyen gerçek taban köşeleri
    final double bFrontX = bx + wx + dx;
    final double bFrontY = by + wy + dy;
    final double bRightX = bx + wx - dx;
    final double bRightY = by + wy - dy;
    final double bLeftX = bx - wx + dx;
    final double bLeftY = by - wy + dy;
    final double bBackX = bx - wx - dx;
    final double bBackY = by - wy - dy;

    final double tFrontY = bFrontY - h;
    final double tRightY = bRightY - h;
    final double tLeftY = bLeftY - h;
    final double tBackY = bBackY - h;

    // Zemin Gölgesi
    if (drawShadow) {
      final double sOffset = math.min(16.0, h * 0.42);

      _cubePenumbraPaint.color = Colors.black.withValues(alpha: shadowOpacity * 0.35);
      _cubePenumbraPath
        ..reset()
        ..moveTo(bFrontX + 1.0, bFrontY + 2.0)
        ..lineTo(bRightX + 5.0 + sOffset * cosIso, bRightY + 2.0 - sOffset * 0.5 * sinIso)
        ..lineTo(bBackX + 5.0 + sOffset * cosIso, bBackY + 2.0 - sOffset * 0.5 * sinIso)
        ..lineTo(bLeftX - 3.0, bLeftY + 2.0)
        ..close();
      canvas.drawPath(_cubePenumbraPath, _cubePenumbraPaint);

      _cubeShadowPaint.color = Colors.black.withValues(alpha: shadowOpacity);
      _cubeShadowPath
        ..reset()
        ..moveTo(bFrontX, bFrontY + 1.5)
        ..lineTo(bRightX + 3.0 + sOffset * 0.7 * cosIso, bRightY + 1.5 - sOffset * 0.35 * sinIso)
        ..lineTo(bBackX + 3.0 + sOffset * 0.7 * cosIso, bBackY + 1.5 - sOffset * 0.35 * sinIso)
        ..lineTo(bLeftX - 2.0, bLeftY + 1.5)
        ..close();
      canvas.drawPath(_cubeShadowPath, _cubeShadowPaint);
    }

    // 1. Sol Yüzey
    _cubeLeftPath
      ..reset()
      ..moveTo(bLeftX, bLeftY)
      ..lineTo(bFrontX, bFrontY)
      ..lineTo(bFrontX, tFrontY)
      ..lineTo(bLeftX, tLeftY)
      ..close();
    _sharedFillPaint.color = leftColor;
    canvas.drawPath(_cubeLeftPath, _sharedFillPaint);

    // 2. Sağ Yüzey
    _cubeRightPath
      ..reset()
      ..moveTo(bFrontX, bFrontY)
      ..lineTo(bRightX, bRightY)
      ..lineTo(bRightX, tRightY)
      ..lineTo(bFrontX, tFrontY)
      ..close();
    _sharedFillPaint.color = rightColor;
    canvas.drawPath(_cubeRightPath, _sharedFillPaint);

    // 3. Üst Yüzey
    _cubeTopPath
      ..reset()
      ..moveTo(bFrontX, tFrontY)
      ..lineTo(bRightX, tRightY)
      ..lineTo(bBackX, tBackY)
      ..lineTo(bLeftX, tLeftY)
      ..close();
    _sharedFillPaint.color = topColor;
    canvas.drawPath(_cubeTopPath, _sharedFillPaint);

    // 4. Kenar Işığı
    if (specularHighlight && w >= 2.0 && h >= 1.5) {
      _cubeSpecularPaint
        ..color = Colors.white.withValues(alpha: 0.28)
        ..strokeWidth = 1.0;
      _cubeSpecularPath
        ..reset()
        ..moveTo(bLeftX, tLeftY)
        ..lineTo(bBackX, tBackY)
        ..lineTo(bRightX, tRightY);
      canvas.drawPath(_cubeSpecularPath, _cubeSpecularPaint);

      _cubeSpecularPaint.color = Colors.black.withValues(alpha: 0.20);
      canvas.drawLine(Offset(bLeftX, bLeftY), Offset(bFrontX, bFrontY), _cubeSpecularPaint);
      canvas.drawLine(Offset(bFrontX, bFrontY), Offset(bRightX, bRightY), _cubeSpecularPaint);
    }
  }

  // ===========================================================================
  // 1. BOZKIR YILKI ATI
  // ===========================================================================
  static void drawHorse(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
    double startleProgress = 0.0,
  }) {
    final double t = animTime + ((seed * 2.83) % 20.0);
    final int coatVariant = seed % 4;

    double bobZ = math.sin(t * 1.2) * 0.35;
    double headTilt = math.sin(t * 1.4) * 0.3;
    final double headYaw = math.sin(t * 1.0) * 0.4;
    final double tailWave = math.sin(t * 2.5) * 0.8;
    final double maneWave = math.sin(t * 2.0) * 0.4;

    if (startleProgress > 0.0) {
      final double jump = math.sin(startleProgress * math.pi) * 3.0;
      bobZ += jump;
      headTilt = -1.5;
    }

    Color coatTop, coatMid, coatDark;
    Color maneTop, maneDark;
    const Color muzzleColor = Color(0xFF1E293B);

    switch (coatVariant) {
      case 0:
        coatTop = const Color(0xFFD97706);
        coatMid = const Color(0xFF92400E);
        coatDark = const Color(0xFF451A03);
        maneTop = const Color(0xFF1E293B);
        maneDark = const Color(0xFF020617);
        break;
      case 1:
        coatTop = const Color(0xFF334155);
        coatMid = const Color(0xFF1E293B);
        coatDark = const Color(0xFF020617);
        maneTop = const Color(0xFF0F172A);
        maneDark = const Color(0xFF000000);
        break;
      case 2:
        coatTop = const Color(0xFFFFFFFF);
        coatMid = const Color(0xFFCBD5E1);
        coatDark = const Color(0xFF64748B);
        maneTop = const Color(0xFFF1F5F9);
        maneDark = const Color(0xFF94A3B8);
        break;
      case 3:
      default:
        coatTop = const Color(0xFFF59E0B);
        coatMid = const Color(0xFFB45309);
        coatDark = const Color(0xFF78350F);
        maneTop = const Color(0xFFFEF08A);
        maneDark = const Color(0xFFD97706);
        break;
    }

    _clear();

    // Uzak Bacaklar (lz: 0..7.5)
    _addVoxel(lx: -4.5, ly: -2.6, lz: 0.0, w: 2.6, d: 2.6, h: 7.5, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.5, ly: -2.6, lz: 0.0, w: 2.6, d: 2.6, h: 7.5, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    // Kuyruk (Gövdeye kilitli)
    _addVoxel(lx: -8.0, ly: tailWave, lz: 5.5 + bobZ, w: 2.8, d: 2.8, h: 8.5, topColor: maneTop, leftColor: maneDark, rightColor: maneDark, origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 7.0..15.5 - Bacaklarla 0.5 bindirme)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 7.0 + bobZ, w: 15.5, d: 8.5, h: 8.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.35, flipX: flipX);

    // Yakın Bacaklar
    _addVoxel(lx: -4.5, ly: 2.6, lz: 0.0, w: 2.6, d: 2.6, h: 7.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.5, ly: 2.6, lz: 0.0, w: 2.6, d: 2.6, h: 7.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    // Boyun (lz: 12.0..20.0 - Gövdeye gömülü)
    _addVoxel(lx: 5.5, ly: headYaw, lz: 12.0 + bobZ + headTilt, w: 5.5, d: 5.5, h: 8.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.5, ly: maneWave, lz: 13.5 + bobZ + headTilt, w: 2.4, d: 4.0, h: 8.0, topColor: maneTop, leftColor: maneDark, rightColor: maneDark, origin: pos, scale: scale, flipX: flipX);

    // Baş & Burun
    final double headZ = 16.5 + bobZ + headTilt;
    _addVoxel(lx: 8.0, ly: headYaw, lz: headZ, w: 5.2, d: 5.0, h: 5.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 11.2, ly: headYaw, lz: headZ - 0.8, w: 3.6, d: 3.6, h: 3.5, topColor: muzzleColor, leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    // Kulaklar
    _addVoxel(lx: 7.2, ly: headYaw - 1.4, lz: headZ + 4.8, w: 1.4, d: 1.4, h: 2.6, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 7.2, ly: headYaw + 1.4, lz: headZ + 4.8, w: 1.4, d: 1.4, h: 2.6, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 2. KOYUN & KUZU
  // ===========================================================================
  static void drawSheep(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final int coat = ((seed * 7) ~/ 3) % 4;
    final double t = animTime + ((seed * 2.37) % 20.0);

    final double headTilt = (t % 7.0 < 4.8) ? -1.8 : 0.0;
    final double headYaw = (t % 7.0 >= 4.8) ? math.sin(t * 2.0) * 0.6 : 0.0;
    final double tailWag = math.sin(t * 6.0) * 0.8;

    Color woolTop, woolMid, woolDark;
    switch (coat) {
      case 1:
        woolTop = const Color(0xFF475569);
        woolMid = const Color(0xFF1E293B);
        woolDark = const Color(0xFF020617);
        break;
      case 2:
        woolTop = const Color(0xFFF59E0B);
        woolMid = const Color(0xFFB45309);
        woolDark = const Color(0xFF78350F);
        break;
      case 0:
      case 3:
      default:
        woolTop = const Color(0xFFFFFFFF);
        woolMid = const Color(0xFFE2E8F0);
        woolDark = const Color(0xFF94A3B8);
        break;
    }

    _clear();

    // Uzak Bacaklar (lz: 0..4.5)
    _addVoxel(lx: -3.5, ly: -2.8, lz: 0.0, w: 2.0, d: 2.0, h: 4.5, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.5, ly: -2.8, lz: 0.0, w: 2.0, d: 2.0, h: 4.5, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    // Kuyruk
    _addVoxel(lx: -6.0, ly: tailWag, lz: 4.5, w: 2.5, d: 2.5, h: 3.0, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, flipX: flipX);

    // Gövde Yünü (lz: 4.0..12.5 - Bacakların tam üzerine oturur)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 4.0, w: 12.5, d: 10.5, h: 8.5, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.28, flipX: flipX);

    // Yakın Bacaklar
    _addVoxel(lx: -3.5, ly: 2.8, lz: 0.0, w: 2.0, d: 2.0, h: 4.5, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.5, ly: 2.8, lz: 0.0, w: 2.0, d: 2.0, h: 4.5, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    // Baş & Burun (Gövdeye 0.8 birim gömülü)
    final double headZ = 6.5 + headTilt;
    _addVoxel(lx: 5.8, ly: headYaw, lz: headZ, w: 5.0, d: 5.0, h: 5.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 8.5, ly: headYaw, lz: headZ - 0.4, w: 2.5, d: 2.5, h: 2.2, topColor: const Color(0xFFFDA4AF), leftColor: const Color(0xFFFB7185), rightColor: const Color(0xFFE11D48), origin: pos, scale: scale, flipX: flipX);

    // Kulaklar
    _addVoxel(lx: 5.2, ly: headYaw - 2.4, lz: headZ + 3.8, w: 1.5, d: 2.2, h: 1.5, topColor: const Color(0xFF475569), leftColor: const Color(0xFF334155), rightColor: const Color(0xFF1E293B), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 5.2, ly: headYaw + 2.4, lz: headZ + 3.8, w: 1.5, d: 2.2, h: 1.5, topColor: const Color(0xFF475569), leftColor: const Color(0xFF334155), rightColor: const Color(0xFF1E293B), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 2B. BOZKIR KOÇU (KIVRIK BOYNUZLU)
  // ===========================================================================
  static void drawRam(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final int coat = ((seed * 7) ~/ 3) % 4;
    final double t = animTime + ((seed * 2.37) % 20.0);

    final double headTilt = (t % 7.0 < 4.8) ? -1.4 : 0.0;
    final double headYaw = (t % 7.0 >= 4.8) ? math.sin(t * 2.0) * 0.5 : 0.0;
    final double tailWag = math.sin(t * 5.0) * 0.6;

    Color woolTop, woolMid, woolDark;
    switch (coat) {
      case 1:
        woolTop = const Color(0xFF475569);
        woolMid = const Color(0xFF1E293B);
        woolDark = const Color(0xFF020617);
        break;
      case 2:
        woolTop = const Color(0xFFF59E0B);
        woolMid = const Color(0xFFB45309);
        woolDark = const Color(0xFF78350F);
        break;
      case 0:
      case 3:
      default:
        woolTop = const Color(0xFFFFFFFF);
        woolMid = const Color(0xFFE2E8F0);
        woolDark = const Color(0xFF94A3B8);
        break;
    }

    const Color hornTop = Color(0xFFD97706);
    const Color hornMid = Color(0xFFB45309);
    const Color hornDark = Color(0xFF78350F);

    _clear();

    // Uzak Bacaklar (lz: 0..5.0)
    _addVoxel(lx: -3.8, ly: -3.0, lz: 0.0, w: 2.2, d: 2.2, h: 5.0, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8, ly: -3.0, lz: 0.0, w: 2.2, d: 2.2, h: 5.0, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    // Kuyruk
    _addVoxel(lx: -6.5, ly: tailWag, lz: 4.8, w: 2.6, d: 2.6, h: 3.2, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, flipX: flipX);

    // Masif Gövde Yünü (lz: 4.5..13.5)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 4.5, w: 13.5, d: 11.2, h: 9.0, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.32, flipX: flipX);

    // Yakın Bacaklar
    _addVoxel(lx: -3.8, ly: 3.0, lz: 0.0, w: 2.2, d: 2.2, h: 5.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8, ly: 3.0, lz: 0.0, w: 2.2, d: 2.2, h: 5.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    // Baş & Burun
    final double headZ = 7.0 + headTilt;
    _addVoxel(lx: 6.2, ly: headYaw, lz: headZ, w: 5.4, d: 5.2, h: 5.2, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 9.0, ly: headYaw, lz: headZ - 0.4, w: 2.6, d: 2.6, h: 2.4, topColor: const Color(0xFFFDA4AF), leftColor: const Color(0xFFFB7185), rightColor: const Color(0xFFE11D48), origin: pos, scale: scale, flipX: flipX);

    // Kıvrık Koç Boynuzları (Curled Horns)
    // Sol boynuz kökü ve kıvrımı
    _addVoxel(lx: 5.2, ly: headYaw - 2.8, lz: headZ + 4.2, w: 2.2, d: 2.2, h: 2.6, topColor: hornTop, leftColor: hornMid, rightColor: hornDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.4, ly: headYaw - 3.4, lz: headZ + 2.0, w: 2.0, d: 2.0, h: 2.4, topColor: hornTop, leftColor: hornMid, rightColor: hornDark, origin: pos, scale: scale, flipX: flipX);
    // Sağ boynuz kökü ve kıvrımı
    _addVoxel(lx: 5.2, ly: headYaw + 2.8, lz: headZ + 4.2, w: 2.2, d: 2.2, h: 2.6, topColor: hornTop, leftColor: hornMid, rightColor: hornDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.4, ly: headYaw + 3.4, lz: headZ + 2.0, w: 2.0, d: 2.0, h: 2.4, topColor: hornTop, leftColor: hornMid, rightColor: hornDark, origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 2C. BOZKIR KUZUSU (YAVRU)
  // ===========================================================================
  static void drawLamb(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final int coat = ((seed * 5) ~/ 2) % 4;
    final double t = animTime + ((seed * 2.51) % 20.0);

    final double hopZ = (math.sin(t * 3.5).abs()) * 0.45;
    final double headTilt = math.sin(t * 2.2) * 0.3;
    final double tailWag = math.sin(t * 8.0) * 0.9;

    Color woolTop, woolMid, woolDark;
    switch (coat) {
      case 1:
        woolTop = const Color(0xFF64748B);
        woolMid = const Color(0xFF475569);
        woolDark = const Color(0xFF334155);
        break;
      case 2:
        woolTop = const Color(0xFFFEF3C7);
        woolMid = const Color(0xFFFDE68A);
        woolDark = const Color(0xFFF59E0B);
        break;
      case 0:
      case 3:
      default:
        woolTop = const Color(0xFFFFFFFF);
        woolMid = const Color(0xFFF1F5F9);
        woolDark = const Color(0xFFCBD5E1);
        break;
    }

    _clear();

    // Uzak Narin Bacaklar (lz: 0..3.6)
    _addVoxel(lx: -2.8, ly: -2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.6, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 2.8, ly: -2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.6, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    // Minik Kuyruk
    _addVoxel(lx: -4.8, ly: tailWag, lz: 3.6 + hopZ, w: 1.8, d: 1.8, h: 2.2, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, flipX: flipX);

    // Minyon Gövde Yünü (lz: 3.2..9.6)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 3.2 + hopZ, w: 9.6, d: 7.8, h: 6.4, topColor: woolTop, leftColor: woolMid, rightColor: woolDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.22, flipX: flipX);

    // Yakın Narin Bacaklar
    _addVoxel(lx: -2.8, ly: 2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.6, topColor: const Color(0xFF475569), leftColor: const Color(0xFF334155), rightColor: const Color(0xFF1E293B), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 2.8, ly: 2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.6, topColor: const Color(0xFF475569), leftColor: const Color(0xFF334155), rightColor: const Color(0xFF1E293B), origin: pos, scale: scale, flipX: flipX);

    // Baş & Pembe Burun
    final double headZ = 5.2 + hopZ + headTilt;
    _addVoxel(lx: 4.4, ly: 0.0, lz: headZ, w: 4.0, d: 4.0, h: 4.0, topColor: const Color(0xFF475569), leftColor: const Color(0xFF334155), rightColor: const Color(0xFF1E293B), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 6.6, ly: 0.0, lz: headZ - 0.2, w: 2.0, d: 2.0, h: 1.8, topColor: const Color(0xFFFDA4AF), leftColor: const Color(0xFFFB7185), rightColor: const Color(0xFFE11D48), origin: pos, scale: scale, flipX: flipX);

    // Sevimli Kulaklar
    _addVoxel(lx: 3.8, ly: -1.8, lz: headZ + 3.0, w: 1.2, d: 1.6, h: 1.2, topColor: const Color(0xFFFDA4AF), leftColor: const Color(0xFFFB7185), rightColor: const Color(0xFFE11D48), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8, ly: 1.8, lz: headZ + 3.0, w: 1.2, d: 1.6, h: 1.2, topColor: const Color(0xFFFDA4AF), leftColor: const Color(0xFFFB7185), rightColor: const Color(0xFFE11D48), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 3. BOZKIR KURDU
  // ===========================================================================
  static void drawSteppeWolf(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 3.11) % 20.0);
    final double stalkBob = math.sin(t * 3.2) * 0.35;
    final double tailWave = math.sin(t * 4.2) * 1.2;

    const Color wolfTop = Color(0xFF64748B);
    const Color wolfMid = Color(0xFF475569);
    const Color wolfDark = Color(0xFF1E293B);

    _clear();

    // Uzak Bacaklar (lz: 0..5.5)
    _addVoxel(lx: -4.0, ly: -2.2, lz: 0.0, w: 2.0, d: 2.0, h: 5.5, topColor: wolfMid, leftColor: wolfDark, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.0, ly: -2.2, lz: 0.0, w: 2.0, d: 2.0, h: 5.5, topColor: wolfMid, leftColor: wolfDark, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);

    // Kuyruk
    _addVoxel(lx: -7.5, ly: tailWave, lz: 4.0 + stalkBob, w: 2.8, d: 2.8, h: 7.0, topColor: wolfMid, leftColor: wolfDark, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 5.0..12.0)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 5.0 + stalkBob, w: 14.0, d: 7.5, h: 7.0, topColor: wolfTop, leftColor: wolfMid, rightColor: wolfDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.35, flipX: flipX);

    // Yakın Bacaklar
    _addVoxel(lx: -4.0, ly: 2.2, lz: 0.0, w: 2.0, d: 2.0, h: 5.5, topColor: wolfTop, leftColor: wolfMid, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.0, ly: 2.2, lz: 0.0, w: 2.0, d: 2.0, h: 5.5, topColor: wolfTop, leftColor: wolfMid, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);

    // Baş & Ağız
    final double headZ = 7.5 + stalkBob;
    _addVoxel(lx: 7.0, ly: 0.0, lz: headZ, w: 5.2, d: 4.8, h: 4.5, topColor: const Color(0xFF94A3B8), leftColor: wolfMid, rightColor: wolfDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 10.0, ly: 0.0, lz: headZ - 0.6, w: 3.2, d: 3.2, h: 2.8, topColor: const Color(0xFF0F172A), leftColor: const Color(0xFF020617), rightColor: const Color(0xFF000000), origin: pos, scale: scale, flipX: flipX);

    // Kulaklar
    _addVoxel(lx: 6.2, ly: -1.4, lz: headZ + 4.2, w: 1.4, d: 1.4, h: 2.8, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 6.2, ly: 1.4, lz: headZ + 4.2, w: 1.4, d: 1.4, h: 2.8, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 4. DAĞ YABAN KEÇİSİ
  // ===========================================================================
  static void drawMountainIbex(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 2.19) % 20.0);
    final double bobZ = math.sin(t * 1.4) * 0.3;

    const Color coatTop = Color(0xFF94A3B8);
    const Color coatMid = Color(0xFF64748B);
    const Color coatDark = Color(0xFF475569);

    _clear();

    _addVoxel(lx: -3.5, ly: -2.2, lz: 0.0, w: 2.0, d: 2.0, h: 6.0, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.5, ly: -2.2, lz: 0.0, w: 2.0, d: 2.0, h: 6.0, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: 0.0, ly: 0.0, lz: 5.5 + bobZ, w: 11.0, d: 7.0, h: 6.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.30, flipX: flipX);

    _addVoxel(lx: -3.5, ly: 2.2, lz: 0.0, w: 2.0, d: 2.0, h: 6.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.5, ly: 2.2, lz: 0.0, w: 2.0, d: 2.0, h: 6.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    final double headZ = 9.5 + bobZ;
    _addVoxel(lx: 5.2, ly: 0.0, lz: headZ, w: 4.6, d: 4.6, h: 4.6, topColor: const Color(0xFFCBD5E1), leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 6.2, ly: 0.0, lz: headZ - 2.8, w: 1.6, d: 1.6, h: 3.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: 3.8, ly: -1.4, lz: headZ + 4.2, w: 2.0, d: 2.0, h: 7.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8, ly: 1.4, lz: headZ + 4.2, w: 2.0, d: 2.0, h: 7.0, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 5. KUTUP TİLKİSİ
  // ===========================================================================
  static void drawArcticFox(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 2.71) % 20.0);
    final double bobZ = math.sin(t * 2.0) * 0.3;
    final double tailSway = math.sin(t * 3.5) * 1.5;

    const Color furTop = Color(0xFFFFFFFF);
    const Color furMid = Color(0xFFF1F5F9);
    const Color furDark = Color(0xFFE2E8F0);

    _clear();

    _addVoxel(lx: -3.0, ly: -2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.8, topColor: furMid, leftColor: furDark, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.0, ly: -2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.8, topColor: furMid, leftColor: furDark, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -5.8, ly: tailSway, lz: 3.0 + bobZ, w: 4.5, d: 4.5, h: 4.5, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: 0.0, ly: 0.0, lz: 3.5 + bobZ, w: 9.5, d: 6.2, h: 5.5, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.22, flipX: flipX);

    _addVoxel(lx: -3.0, ly: 2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.8, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.0, ly: 2.0, lz: 0.0, w: 1.6, d: 1.6, h: 3.8, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    final double headZ = 6.5 + bobZ;
    _addVoxel(lx: 5.2, ly: 0.0, lz: headZ, w: 4.2, d: 4.2, h: 4.0, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.5, ly: -1.4, lz: headZ + 3.6, w: 1.4, d: 1.4, h: 2.4, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.5, ly: 1.4, lz: headZ + 3.6, w: 1.4, d: 1.4, h: 2.4, topColor: const Color(0xFF334155), leftColor: const Color(0xFF1E293B), rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 6. ÇÖL DEVESİ (BACTRIAN CAMEL)
  // ===========================================================================
  static void drawCamel(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 3.41) % 20.0);
    final double bobZ = math.sin(t * 1.6) * 0.4;
    final double headSway = math.sin(t * 1.8) * 0.6;

    const Color bodyTop = Color(0xFFF59E0B);
    const Color bodyMid = Color(0xFFB45309);
    const Color bodyDark = Color(0xFF78350F);

    _clear();

    _addVoxel(lx: -5.0, ly: -3.5, lz: 0.0, w: 2.6, d: 2.6, h: 8.5, topColor: bodyMid, leftColor: bodyDark, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 5.0, ly: -3.5, lz: 0.0, w: 2.6, d: 2.6, h: 8.5, topColor: bodyMid, leftColor: bodyDark, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 8.0..16.5)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 8.0 + bobZ, w: 16.5, d: 10.0, h: 8.5, topColor: bodyTop, leftColor: bodyMid, rightColor: bodyDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.35, flipX: flipX);

    // Çift Hörgüç
    _addVoxel(lx: -3.5, ly: 0.0, lz: 16.0 + bobZ, w: 5.0, d: 6.0, h: 6.0, topColor: const Color(0xFFFDE047), leftColor: const Color(0xFFD97706), rightColor: const Color(0xFF92400E), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.0, ly: 0.0, lz: 16.0 + bobZ, w: 5.0, d: 6.0, h: 6.0, topColor: const Color(0xFFFDE047), leftColor: const Color(0xFFD97706), rightColor: const Color(0xFF92400E), origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -5.0, ly: 3.5, lz: 0.0, w: 2.6, d: 2.6, h: 8.5, topColor: bodyTop, leftColor: bodyMid, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 5.0, ly: 3.5, lz: 0.0, w: 2.6, d: 2.6, h: 8.5, topColor: bodyTop, leftColor: bodyMid, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);

    // Boyun & Baş
    _addVoxel(lx: 8.0, ly: headSway, lz: 13.0 + bobZ, w: 4.8, d: 4.8, h: 7.5, topColor: const Color(0xFFF59E0B), leftColor: bodyMid, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 10.8, ly: headSway, lz: 18.0 + bobZ, w: 5.0, d: 4.2, h: 4.2, topColor: const Color(0xFFFBBF24), leftColor: bodyMid, rightColor: bodyDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 13.5, ly: headSway, lz: 17.5 + bobZ, w: 3.2, d: 3.2, h: 2.8, topColor: const Color(0xFF451A03), leftColor: const Color(0xFF331402), rightColor: const Color(0xFF220D01), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  static void drawCaravanCamel(
    Canvas canvas,
    Offset center, {
    required double animTime,
    double walkCycle = 0.0,
    bool flipX = false,
  }) {
    final double bob = (math.sin(walkCycle * math.pi * 4).abs()) * 1.5;
    final double legSwing = math.sin(walkCycle * math.pi * 4) * 2.0;

    _clear();

    _addVoxel(lx: -3.0 - legSwing, ly: -2.5, lz: 0.0, w: 1.8, d: 1.8, h: 5.8, topColor: const Color(0xFF92400E), leftColor: const Color(0xFF78350F), rightColor: const Color(0xFF78350F), origin: center, scale: 1.0, flipX: flipX);
    _addVoxel(lx: 3.0 + legSwing, ly: -2.5, lz: 0.0, w: 1.8, d: 1.8, h: 5.8, topColor: const Color(0xFF92400E), leftColor: const Color(0xFF78350F), rightColor: const Color(0xFF78350F), origin: center, scale: 1.0, flipX: flipX);

    _addVoxel(lx: 0.0, ly: 0.0, lz: 5.5 + bob, w: 8.5, d: 5.5, h: 5.5, topColor: const Color(0xFFD97706), leftColor: const Color(0xFFB45309), rightColor: const Color(0xFF92400E), origin: center, scale: 1.0, drawShadow: true, shadowOpacity: 0.32, flipX: flipX);
    _addVoxel(lx: 0.0, ly: 0.0, lz: 9.5 + bob, w: 5.0, d: 7.0, h: 3.2, topColor: const Color(0xFF991B1B), leftColor: const Color(0xFF7F1D1D), rightColor: const Color(0xFF450A0A), origin: center, scale: 1.0, flipX: flipX);

    _addVoxel(lx: -3.0 + legSwing, ly: 2.5, lz: 0.0, w: 1.8, d: 1.8, h: 5.8, topColor: const Color(0xFFB45309), leftColor: const Color(0xFF92400E), rightColor: const Color(0xFF78350F), origin: center, scale: 1.0, flipX: flipX);
    _addVoxel(lx: 3.0 - legSwing, ly: 2.5, lz: 0.0, w: 1.8, d: 1.8, h: 5.8, topColor: const Color(0xFFB45309), leftColor: const Color(0xFF92400E), rightColor: const Color(0xFF78350F), origin: center, scale: 1.0, flipX: flipX);

    _addVoxel(lx: 4.5, ly: 0.0, lz: 9.0 + bob, w: 2.6, d: 2.6, h: 5.5, topColor: const Color(0xFFD97706), leftColor: const Color(0xFFB45309), rightColor: const Color(0xFF92400E), origin: center, scale: 1.0, flipX: flipX);
    _addVoxel(lx: 6.2, ly: 0.0, lz: 13.0 + bob, w: 3.0, d: 2.4, h: 2.2, topColor: const Color(0xFFF59E0B), leftColor: const Color(0xFFD97706), rightColor: const Color(0xFF92400E), origin: center, scale: 1.0, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 7. BOZKIR AYISI (GRIZZLY & POLAR)
  // ===========================================================================
  static void drawSteppeBear(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
    double startleProgress = 0.0,
  }) {
    final double t = animTime + ((seed * 2.67) % 20.0);
    double bobZ = math.sin(t * 1.5) * 0.35;
    double headTilt = math.sin(t * 1.2) * 0.3;
    final double headYaw = math.sin(t * 0.9) * 0.4;
    final double legStep = math.sin(t * 2.2) * 1.2;

    if (startleProgress > 0.0) {
      final double roar = math.sin(startleProgress * math.pi) * 2.5;
      bobZ += roar;
      headTilt = -1.5;
    }

    final int coat = seed % 3;
    Color furTop, furMid, furDark;
    const Color muzzleColor = Color(0xFF1E293B);

    switch (coat) {
      case 1:
        furTop = const Color(0xFFFFFFFF);
        furMid = const Color(0xFFE2E8F0);
        furDark = const Color(0xFF94A3B8);
        break;
      case 2:
        furTop = const Color(0xFF334155);
        furMid = const Color(0xFF1E293B);
        furDark = const Color(0xFF0F172A);
        break;
      case 0:
      default:
        furTop = const Color(0xFF92400E);
        furMid = const Color(0xFF78350F);
        furDark = const Color(0xFF451A03);
        break;
    }

    _clear();

    _addVoxel(lx: -4.2 - legStep, ly: -3.2, lz: 0.0, w: 3.2, d: 3.2, h: 5.8, topColor: furMid, leftColor: furDark, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.2 + legStep, ly: -3.2, lz: 0.0, w: 3.2, d: 3.2, h: 5.8, topColor: furMid, leftColor: furDark, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -7.5, ly: 0.0, lz: 6.8 + bobZ, w: 2.2, d: 2.2, h: 2.5, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    // Masif Gövde (lz: 5.0..14.5)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 5.0 + bobZ, w: 15.5, d: 11.5, h: 9.5, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.38, flipX: flipX);
    // Sırt Kamburu
    _addVoxel(lx: 2.0, ly: 0.0, lz: 13.5 + bobZ, w: 7.0, d: 9.0, h: 3.5, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -4.2 + legStep, ly: 3.2, lz: 0.0, w: 3.2, d: 3.2, h: 5.8, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.2 - legStep, ly: 3.2, lz: 0.0, w: 3.2, d: 3.2, h: 5.8, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    final double headZ = 9.0 + bobZ + headTilt;
    _addVoxel(lx: 8.0, ly: headYaw, lz: headZ, w: 6.2, d: 6.2, h: 6.0, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 11.2, ly: headYaw, lz: headZ - 0.6, w: 4.2, d: 4.0, h: 3.8, topColor: muzzleColor, leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: 6.8, ly: headYaw - 2.2, lz: headZ + 5.2, w: 1.8, d: 1.8, h: 2.0, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 6.8, ly: headYaw + 2.2, lz: headZ + 5.2, w: 1.8, d: 1.8, h: 2.0, topColor: furTop, leftColor: furMid, rightColor: furDark, origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 8. YABAN DOMUZU
  // ===========================================================================
  static void drawWildBoar(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 2.87) % 20.0);
    final double bobZ = math.sin(t * 2.0) * 0.3;
    final double rootGround = (t % 5.0 < 3.2) ? -1.5 : 0.0;
    final double legStep = math.sin(t * 3.5) * 1.0;

    final int coat = seed % 2;
    final Color bristleTop = coat == 0 ? const Color(0xFF334155) : const Color(0xFF7C2D12);
    final Color bristleMid = coat == 0 ? const Color(0xFF1E293B) : const Color(0xFF451A03);
    final Color bristleDark = coat == 0 ? const Color(0xFF0F172A) : const Color(0xFF270E02);

    _clear();

    _addVoxel(lx: -3.8 - legStep, ly: -2.4, lz: 0.0, w: 2.2, d: 2.2, h: 4.8, topColor: bristleMid, leftColor: bristleDark, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8 + legStep, ly: -2.4, lz: 0.0, w: 2.2, d: 2.2, h: 4.8, topColor: bristleMid, leftColor: bristleDark, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -6.8, ly: 0.0, lz: 6.0 + bobZ, w: 1.5, d: 1.5, h: 3.0, topColor: bristleTop, leftColor: bristleMid, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 4.2..12.2)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 4.2 + bobZ, w: 13.0, d: 8.8, h: 8.0, topColor: bristleTop, leftColor: bristleMid, rightColor: bristleDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.32, flipX: flipX);

    _addVoxel(lx: -3.8 + legStep, ly: 2.4, lz: 0.0, w: 2.2, d: 2.2, h: 4.8, topColor: bristleTop, leftColor: bristleMid, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.8 - legStep, ly: 2.4, lz: 0.0, w: 2.2, d: 2.2, h: 4.8, topColor: bristleTop, leftColor: bristleMid, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);

    final double headZ = 5.8 + bobZ + rootGround;
    _addVoxel(lx: 6.8, ly: 0.0, lz: headZ, w: 5.2, d: 5.5, h: 5.2, topColor: bristleTop, leftColor: bristleMid, rightColor: bristleDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 9.8, ly: 0.0, lz: headZ - 0.6, w: 3.0, d: 3.2, h: 3.0, topColor: const Color(0xFFBE185D), leftColor: const Color(0xFF9D174D), rightColor: const Color(0xFF831843), origin: pos, scale: scale, flipX: flipX);

    // Azı Dişleri
    _addVoxel(lx: 9.0, ly: -1.8, lz: headZ, w: 1.0, d: 1.0, h: 2.5, topColor: Colors.white, leftColor: const Color(0xFFFEF08A), rightColor: const Color(0xFFE2E8F0), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 9.0, ly: 1.8, lz: headZ, w: 1.0, d: 1.0, h: 2.5, topColor: Colors.white, leftColor: const Color(0xFFFEF08A), rightColor: const Color(0xFFE2E8F0), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 9. BOZKIR GEYİĞİ
  // ===========================================================================
  static void drawSteppeDeer(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 2.43) % 20.0);
    final double bobZ = math.sin(t * 1.3) * 0.3;
    final double headTilt = math.sin(t * 1.1) * 0.3;
    final double headYaw = math.sin(t * 0.8) * 0.4;

    final int coat = seed % 3;
    Color coatTop, coatMid, coatDark;
    Color antlerColor = const Color(0xFFFDE68A);

    switch (coat) {
      case 1:
        coatTop = const Color(0xFFF59E0B);
        coatMid = const Color(0xFFD97706);
        coatDark = const Color(0xFF92400E);
        break;
      case 2:
        coatTop = const Color(0xFFF1F5F9);
        coatMid = const Color(0xFFCBD5E1);
        coatDark = const Color(0xFF64748B);
        antlerColor = const Color(0xFF94A3B8);
        break;
      case 0:
      default:
        coatTop = const Color(0xFFB45309);
        coatMid = const Color(0xFF92400E);
        coatDark = const Color(0xFF78350F);
        break;
    }

    _clear();

    _addVoxel(lx: -4.0, ly: -2.4, lz: 0.0, w: 1.8, d: 1.8, h: 8.0, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.0, ly: -2.4, lz: 0.0, w: 1.8, d: 1.8, h: 8.0, topColor: coatMid, leftColor: coatDark, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -7.0, ly: 0.0, lz: 8.5 + bobZ, w: 2.0, d: 2.0, h: 3.0, topColor: Colors.white, leftColor: const Color(0xFFE2E8F0), rightColor: const Color(0xFFCBD5E1), origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 7.5..15.0)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 7.5 + bobZ, w: 13.5, d: 7.2, h: 7.5, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.28, flipX: flipX);

    _addVoxel(lx: -4.0, ly: 2.4, lz: 0.0, w: 1.8, d: 1.8, h: 8.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.0, ly: 2.4, lz: 0.0, w: 1.8, d: 1.8, h: 8.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    // Boyun & Baş
    final double neckZ = 12.0 + bobZ + headTilt;
    _addVoxel(lx: 5.0, ly: headYaw, lz: neckZ, w: 4.2, d: 4.0, h: 8.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);

    final double headZ = neckZ + 5.5;
    _addVoxel(lx: 7.2, ly: headYaw, lz: headZ, w: 4.4, d: 4.0, h: 4.0, topColor: coatTop, leftColor: coatMid, rightColor: coatDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 9.8, ly: headYaw, lz: headZ - 0.5, w: 2.6, d: 2.4, h: 2.4, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    // Çatallı Boynuzlar
    _addVoxel(lx: 5.8, ly: headYaw - 2.0, lz: headZ + 4.2, w: 1.5, d: 1.5, h: 6.0, topColor: antlerColor, leftColor: const Color(0xFFD97706), rightColor: const Color(0xFFB45309), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 5.8, ly: headYaw + 2.0, lz: headZ + 4.2, w: 1.5, d: 1.5, h: 6.0, topColor: antlerColor, leftColor: const Color(0xFFD97706), rightColor: const Color(0xFFB45309), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  // ===========================================================================
  // 10. KIZIL TİLKİ
  // ===========================================================================
  static void drawRedFox(
    Canvas canvas,
    Offset pos, {
    double animTime = 0.0,
    double scale = 1.0,
    int seed = 0,
    bool flipX = false,
  }) {
    final double t = animTime + ((seed * 3.17) % 20.0);
    final double bobZ = math.sin(t * 2.2) * 0.3;
    final double tailSway = math.sin(t * 4.0) * 1.6;

    const Color foxRed = Color(0xFFEA580C);
    const Color foxMid = Color(0xFFC2410C);
    const Color foxDark = Color(0xFF9A3412);
    const Color whiteFur = Color(0xFFFFFFFF);
    const Color darkPaw = Color(0xFF1E293B);

    _clear();

    _addVoxel(lx: -3.2, ly: -2.0, lz: 0.0, w: 1.5, d: 1.5, h: 4.5, topColor: darkPaw, leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.2, ly: -2.0, lz: 0.0, w: 1.5, d: 1.5, h: 4.5, topColor: darkPaw, leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    // Kabarık Kuyruk & Beyaz Uç
    _addVoxel(lx: -6.0, ly: tailSway, lz: 3.5 + bobZ, w: 5.0, d: 4.5, h: 4.5, topColor: foxRed, leftColor: foxMid, rightColor: foxDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: -8.8, ly: tailSway * 1.2, lz: 4.8 + bobZ, w: 2.8, d: 2.8, h: 2.8, topColor: whiteFur, leftColor: const Color(0xFFE2E8F0), rightColor: const Color(0xFFCBD5E1), origin: pos, scale: scale, flipX: flipX);

    // Gövde (lz: 4.0..9.8)
    _addVoxel(lx: 0.0, ly: 0.0, lz: 4.0 + bobZ, w: 10.5, d: 6.0, h: 5.8, topColor: foxRed, leftColor: foxMid, rightColor: foxDark, origin: pos, scale: scale, drawShadow: true, shadowOpacity: 0.25, flipX: flipX);
    _addVoxel(lx: 3.2, ly: 0.0, lz: 4.0 + bobZ, w: 3.2, d: 4.8, h: 4.0, topColor: whiteFur, leftColor: const Color(0xFFE2E8F0), rightColor: const Color(0xFFCBD5E1), origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: -3.2, ly: 2.0, lz: 0.0, w: 1.5, d: 1.5, h: 4.5, topColor: foxRed, leftColor: darkPaw, rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 3.2, ly: 2.0, lz: 0.0, w: 1.5, d: 1.5, h: 4.5, topColor: foxRed, leftColor: darkPaw, rightColor: const Color(0xFF0F172A), origin: pos, scale: scale, flipX: flipX);

    final double headZ = 7.0 + bobZ;
    _addVoxel(lx: 5.5, ly: 0.0, lz: headZ, w: 4.5, d: 4.5, h: 4.0, topColor: foxRed, leftColor: foxMid, rightColor: foxDark, origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 8.0, ly: 0.0, lz: headZ - 0.8, w: 2.4, d: 2.2, h: 2.0, topColor: const Color(0xFF020617), leftColor: Colors.black, rightColor: Colors.black, origin: pos, scale: scale, flipX: flipX);

    _addVoxel(lx: 4.8, ly: -1.5, lz: headZ + 3.8, w: 1.5, d: 1.5, h: 3.0, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);
    _addVoxel(lx: 4.8, ly: 1.5, lz: headZ + 3.8, w: 1.5, d: 1.5, h: 3.0, topColor: const Color(0xFF1E293B), leftColor: const Color(0xFF0F172A), rightColor: const Color(0xFF020617), origin: pos, scale: scale, flipX: flipX);

    _flush(canvas);
  }

  static void drawSkyBird(
    Canvas canvas,
    Offset pos, {
    required double wingAnim,
    double scale = 1.0,
    Color bodyColor = const Color(0xFFFFFFFF),
    Color wingColor = const Color(0xFFF8FAFC),
    Color wingTipColor = const Color(0xFF94A3B8),
    bool drawShadow = true,
  }) {}
}

class _VoxelPrimitive {
  double screenX = 0;
  double screenY = 0;
  double w = 0;
  double d = 0;
  double h = 0;
  double depth = 0;
  Color topColor = Colors.white;
  Color leftColor = Colors.white;
  Color rightColor = Colors.white;
  bool drawShadow = false;
  double shadowOpacity = 0.28;
}