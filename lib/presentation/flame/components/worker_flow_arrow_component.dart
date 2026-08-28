import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../../core/hex/hex_coordinates.dart';
import '../../../core/hex/hex_math.dart';
import '../../../domain/models/building_model.dart';
import '../hex_map_game.dart';
import 'hex_tile_component.dart';

/// Bir üretim binasından işçi kulübesine doğru giden akış verisi
class WorkerFlowConnection {
  final HexAxial fromCoord;
  final BuildingType buildingType;
  final Vector2 startPixel;
  final Vector2 endPixel;
  final double length;
  final Vector2 dir;
  final Vector2 normal;

  WorkerFlowConnection({
    required this.fromCoord,
    required this.buildingType,
    required this.startPixel,
    required this.endPixel,
  })  : length = (endPixel - startPixel).length,
        dir = (endPixel - startPixel).normalized(),
        normal = Vector2(-(endPixel - startPixel).normalized().y, (endPixel - startPixel).normalized().x);
}

/// Seçili işçi kulübesine malzeme gönderen üretim binalarından gelen ince yeşil lojistik akış okları
class WorkerFlowArrowComponent extends PositionComponent {
  HexAxial? _workerCoord;
  final List<WorkerFlowConnection> _flows = [];

  double _animTimer = 0.0;

  // Zero-GC Cached Static Drawing Tools
  static final Paint _shadowLinePaint = Paint()
    ..color = const Color(0x99020617)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.6
    ..strokeCap = StrokeCap.round;

  static final Paint _mainGreenLinePaint = Paint()
    ..color = const Color(0xFF10B981) // Emerald green
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round;

  static final Paint _arrowHeadPaint = Paint()
    ..color = const Color(0xFF10B981)
    ..style = PaintingStyle.fill;

  static final Paint _arrowHeadBorderPaint = Paint()
    ..color = const Color(0xFF064E3B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final Paint _pulseDotPaint = Paint()
    ..color = const Color(0xFF6EE7B7) // Bright mint green
    ..style = PaintingStyle.fill;

  static final Paint _pulseGlowPaint = Paint()
    ..color = const Color(0x8034D399)
    ..style = PaintingStyle.fill;

  static final Path _arrowPath = Path();

  WorkerFlowArrowComponent()
      : super(
          priority: 2800, // Karoların ve binaların üzerinde
        );

  /// Akış verilerini günceller
  void updateFlows({
    required HexAxial? workerCoord,
    required List<MapEntry<HexAxial, BuildingType>> contributors,
    required double Function(HexAxial coord) getTileElevation,
  }) {
    if (workerCoord == null || contributors.isEmpty) {
      _workerCoord = null;
      _flows.clear();
      return;
    }

    _workerCoord = workerCoord;
    _flows.clear();

    final workerPixelRaw = HexMath.hexToPixel(workerCoord, hexSize: HexTileComponent.hexRadius);
    final double workerElev = getTileElevation(workerCoord);
    final workerCenter = Vector2(workerPixelRaw.dx, workerPixelRaw.dy - workerElev);

    for (final entry in contributors) {
      final producerCoord = entry.key;
      final producerPixelRaw = HexMath.hexToPixel(producerCoord, hexSize: HexTileComponent.hexRadius);
      final double producerElev = getTileElevation(producerCoord);
      final producerCenter = Vector2(producerPixelRaw.dx, producerPixelRaw.dy - producerElev);

      _flows.add(
        WorkerFlowConnection(
          fromCoord: producerCoord,
          buildingType: entry.value,
          startPixel: producerCenter,
          endPixel: workerCenter,
        ),
      );
    }
  }

  void clearFlows() {
    _workerCoord = null;
    _flows.clear();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flows.isNotEmpty) {
      _animTimer += dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_flows.isEmpty || _workerCoord == null) return;

    final game = findGame();
    Rect? bounds;
    if (game is HexMapGame) {
      bounds = game.visibleWorldBounds;
    }

    for (int i = 0; i < _flows.length; i++) {
      final flow = _flows[i];
      if (flow.length < 10.0) continue;

      // Viewport Culling
      if (bounds != null) {
        final minX = math.min(flow.startPixel.x, flow.endPixel.x) - 40;
        final maxX = math.max(flow.startPixel.x, flow.endPixel.x) + 40;
        final minY = math.min(flow.startPixel.y, flow.endPixel.y) - 40;
        final maxY = math.max(flow.startPixel.y, flow.endPixel.y) + 40;

        if (maxX < bounds.left || minX > bounds.right || maxY < bounds.top || minY > bounds.bottom) {
          continue;
        }
      }

      // Başlangıç ve bitiş noktalarını binaların merkezinden biraz ofsetle
      final double startOffsetDist = 14.0;
      final double endOffsetDist = 18.0;

      final pStart = flow.startPixel + flow.dir * startOffsetDist;
      final pEnd = flow.endPixel - flow.dir * endOffsetDist;
      final double segLength = (pEnd - pStart).length;
      if (segLength <= 5.0) continue;

      final pStartOffset = Offset(pStart.x, pStart.y);
      final pEndOffset = Offset(pEnd.x, pEnd.y);

      // 1. Koyu arka plan gölge çizgisi (Yüksek kontrast için)
      canvas.drawLine(pStartOffset, pEndOffset, _shadowLinePaint);

      // 2. Ana ince yeşil çizgi
      canvas.drawLine(pStartOffset, pEndOffset, _mainGreenLinePaint);

      // 3. Hedefte (işçi kulübesine varış noktasında) zarif yeşil ok ucu
      final arrowTip = pEnd;
      final arrowBase = pEnd - flow.dir * 10.0;
      final arrowLeft = arrowBase + flow.normal * 5.0;
      final arrowRight = arrowBase - flow.normal * 5.0;

      _arrowPath
        ..reset()
        ..moveTo(arrowTip.x, arrowTip.y)
        ..lineTo(arrowLeft.x, arrowLeft.y)
        ..lineTo(arrowRight.x, arrowRight.y)
        ..close();

      canvas.drawPath(_arrowPath, _arrowHeadPaint);
      canvas.drawPath(_arrowPath, _arrowHeadBorderPaint);

      // 4. Hat üzerinde deterministik olarak akan yeşil enerji parçacıkları (Kinetik Lojistik Akışı)
      final double speed = 0.55; // Saniyede yarım tur
      final double phase = (_animTimer * speed + (i * 0.23)) % 1.0;
      final Vector2 pulsePos = pStart + (pEnd - pStart) * phase;
      final Offset pulseOffset = Offset(pulsePos.x, pulsePos.y);

      canvas.drawCircle(pulseOffset, 4.2, _pulseGlowPaint);
      canvas.drawCircle(pulseOffset, 2.2, _pulseDotPaint);
    }
  }
}
