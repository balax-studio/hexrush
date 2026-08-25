import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Colors, Color;
import '../../core/hex/hex_coordinates.dart';
import '../../core/hex/hex_math.dart';
import '../../domain/models/building_model.dart';
import '../../domain/models/game_state.dart';
import 'components/floating_resource_number_component.dart';
import 'components/floating_voxel_cloud_component.dart';
import 'components/flying_voxel_bird_component.dart';
import 'components/hex_tile_component.dart';
import 'components/snow_particle_emitter.dart';
import 'components/tile_conquer_poof_emitter.dart';
import 'components/worker_agent_component.dart';

class HexMapGame extends FlameGame {
  final void Function(HexAxial) onTileSelected;
  late final World gameWorld;
  late final CameraComponent gameCamera;

  final Map<HexAxial, HexTileComponent> _tileComponents = {};
  final List<WorkerAgentComponent> _workerComponents = [];
  final List<FloatingVoxelCloudComponent> _cloudComponents = [];
  late final SnowParticleEmitter _snowEmitter;
  late final FlyingVoxelBirdComponent _flyingBirds;

  GameState? _lastState;
  double _currentZoom = 1.0;
  double _dayNightClock = 0.0;
  bool _isNight = false;

  // Kamera sürtünmesi / sönümleme (Smooth Pan Inertia)
  Vector2 _panVelocity = Vector2.zero();

  HexMapGame({required this.onTileSelected});

  double get currentZoom => _currentZoom;
  Vector2 get cameraPosition => gameCamera.viewfinder.position;
  bool get isNight => _isNight;

  @override
  Future<void> onLoad() async {
    gameWorld = World();
    add(gameWorld);

    gameCamera = CameraComponent(world: gameWorld);
    gameCamera.viewfinder.position = Vector2(0, 0);
    gameCamera.viewfinder.anchor = Anchor.center;
    add(gameCamera);

    // 3D Voxel Yüzen Bulutlar
    _initFloatingClouds();

    // 3D Voxel Uçan Kuş Sürüsü
    _flyingBirds = FlyingVoxelBirdComponent(
      startPos: Vector2(0, 0),
      flightSpeed: 30.0,
      flightRadius: 260.0,
    );
    gameWorld.add(_flyingBirds);

    _snowEmitter = SnowParticleEmitter();
    gameWorld.add(_snowEmitter);

    if (_lastState != null) {
      _buildWorldFromState(_lastState!);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Dinamik Gün/Gece Döngüsü (120 saniyede bir tam gün/gece turu)
    _dayNightClock += dt;
    final double cycle = (_dayNightClock % 120.0) / 120.0;
    final bool newIsNight = cycle > 0.65; // %65'ten sonrası gece

    if (newIsNight != _isNight) {
      _isNight = newIsNight;
      // Tüm karolara gece durumunu ilet
      for (final comp in _tileComponents.values) {
        comp.isNight = _isNight;
      }
    }

    // Pürüzsüz kamera sürükleme sönümlemesi (Pan Inertia)
    if (_panVelocity.length2 > 1.0) {
      gameCamera.viewfinder.position += _panVelocity * dt;
      _panVelocity *= 0.90; // Sönümleme katsayısı
    } else {
      _panVelocity = Vector2.zero();
    }
  }

  void _initFloatingClouds() {
    final clouds = [
      FloatingVoxelCloudComponent(initialPosition: Vector2(-180, -140), speed: 10.0, cloudScale: 1.1),
      FloatingVoxelCloudComponent(initialPosition: Vector2(40, -180), speed: 14.0, cloudScale: 0.85),
      FloatingVoxelCloudComponent(initialPosition: Vector2(-60, 120), speed: 8.0, cloudScale: 1.0),
    ];
    for (final c in clouds) {
      _cloudComponents.add(c);
      gameWorld.add(c);
    }
  }

  void handleTapAtScreenPosition(Offset localPos, Size screenSize) {
    final double screenCenterX = screenSize.width / 2;
    final double screenCenterY = screenSize.height / 2;

    final double worldX =
        (localPos.dx - screenCenterX) / _currentZoom + gameCamera.viewfinder.position.x;
    final double worldY =
        (localPos.dy - screenCenterY) / _currentZoom + gameCamera.viewfinder.position.y;

    final tappedCoord = HexMath.pixelToHex(
      Offset(worldX, worldY),
      hexSize: HexTileComponent.hexRadius,
    );

    if (_lastState != null && _lastState!.tiles.containsKey(tappedCoord)) {
      final tile = _lastState!.tiles[tappedCoord]!;

      // Dokunulan karoyu zıplat (Bounce)
      if (_tileComponents.containsKey(tappedCoord)) {
        _tileComponents[tappedCoord]!.triggerTapBounce();
      }

      // Juicy Floating Number Efekti
      final tilePixel = HexMath.hexToPixel(tappedCoord, hexSize: HexTileComponent.hexRadius);
      final tileVec = Vector2(tilePixel.dx, tilePixel.dy - 20);

      if (tile.hasBuilding) {
        final b = tile.building!;
        if (b.type == BuildingType.castle) {
          gameWorld.add(
            FloatingResourceNumberComponent(
              position: tileVec,
              text: '+1 GIDA',
              bgColor: const Color(0xFF10B981),
              textColor: Colors.black,
            ),
          );
        } else if (b.accumulatedResource > 0) {
          gameWorld.add(
            FloatingResourceNumberComponent(
              position: tileVec,
              text: '+${b.accumulatedResource.toInt()}',
              bgColor: const Color(0xFF10B981),
              textColor: Colors.black,
            ),
          );
        }
      } else if (!tile.isOwned && !tile.isFog) {
        // Fetih / İnşaat Puf Partikülü
        gameWorld.add(TileConquerPoofEmitter(centerPosition: tileVec));
      }

      onTileSelected(tappedCoord);
    }
  }

  void panCamera(Offset delta) {
    final panDelta = Vector2(-delta.dx, -delta.dy) / _currentZoom;
    gameCamera.viewfinder.position += panDelta;
    _panVelocity = panDelta * 8.0; // Harekete atalet momentumu ekle
  }

  void zoomCamera(double delta) {
    _currentZoom = (_currentZoom + delta).clamp(0.45, 2.2);
    gameCamera.viewfinder.zoom = _currentZoom;
  }

  void syncGameState(GameState state) {
    _lastState = state;
    if (!isLoaded) return;

    _updateTiles(state);
    _updateWorkers(state);
    _updateWeather(state);
  }

  void _buildWorldFromState(GameState state) {
    for (final comp in _tileComponents.values) {
      comp.removeFromParent();
    }
    _tileComponents.clear();

    _updateTiles(state);
    _updateWorkers(state);
    _updateWeather(state);
  }

  void _updateTiles(GameState state) {
    final sortedEntries = state.tiles.entries.toList()
      ..sort((a, b) {
        final posA = HexMath.hexToPixel(a.key, hexSize: HexTileComponent.hexRadius);
        final posB = HexMath.hexToPixel(b.key, hexSize: HexTileComponent.hexRadius);
        return posA.dy.compareTo(posB.dy);
      });

    for (final entry in sortedEntries) {
      final coord = entry.key;
      final tile = entry.value;
      final bool isSel = state.selectedCoord == coord;

      if (_tileComponents.containsKey(coord)) {
        _tileComponents[coord]!.updateData(
          newTileModel: tile,
          newIsSelected: isSel,
          newSeason: state.season.current,
          newIsZud: state.season.isZud,
          newIsNight: _isNight,
        );
      } else {
        final comp = HexTileComponent(
          coord: coord,
          tileModel: tile,
          isSelected: isSel,
          season: state.season.current,
          isZud: state.season.isZud,
          isNight: _isNight,
        );
        final pixelPos = HexMath.hexToPixel(coord, hexSize: HexTileComponent.hexRadius);
        comp.priority = (pixelPos.dy + 1000).toInt();

        _tileComponents[coord] = comp;
        gameWorld.add(comp);
      }
    }
  }

  void _updateWorkers(GameState state) {
    for (final w in _workerComponents) {
      w.removeFromParent();
    }
    _workerComponents.clear();

    final castlePos = HexMath.hexToPixel(const HexAxial(0, 0), hexSize: HexTileComponent.hexRadius);
    final castleVec = Vector2(castlePos.dx, castlePos.dy);

    for (final entry in state.tiles.entries) {
      final tile = entry.value;
      if (tile.isOwned && tile.hasBuilding && tile.building!.type != BuildingType.castle) {
        final tilePos = HexMath.hexToPixel(entry.key, hexSize: HexTileComponent.hexRadius);
        final tileVec = Vector2(tilePos.dx, tilePos.dy);

        Color cargoColor = const Color(0xFFFBBF24);
        if (tile.building!.type == BuildingType.corn) cargoColor = const Color(0xFFFBBF24);
        if (tile.building!.type == BuildingType.lumberjack) cargoColor = const Color(0xFFB45309);
        if (tile.building!.type == BuildingType.sawmill) cargoColor = const Color(0xFFD97706);
        if (tile.building!.type == BuildingType.windmill) cargoColor = const Color(0xFFFEF08A);
        if (tile.building!.type == BuildingType.bakery) cargoColor = const Color(0xFFF59E0B);
        if (tile.building!.type == BuildingType.furniture) cargoColor = const Color(0xFF78350F);
        if (tile.building!.type == BuildingType.mine) cargoColor = const Color(0xFF94A3B8);
        if (tile.building!.type == BuildingType.fisherman || tile.building!.type == BuildingType.fishermanHut) {
          cargoColor = const Color(0xFF38BDF8);
        }

        final int workerSeed = (entry.key.q * 31 + entry.key.r * 17).abs();
        final worker = WorkerAgentComponent(
          startPos: tileVec,
          endPos: castleVec,
          cargoColor: cargoColor,
          seed: workerSeed,
        );
        _workerComponents.add(worker);
        gameWorld.add(worker);
      }
    }
  }

  void _updateWeather(GameState state) {
    final bool isWinter = state.season.current == 'WINTER';
    _snowEmitter.isActive = isWinter;
    _snowEmitter.isZud = state.season.isZud;
  }
}
