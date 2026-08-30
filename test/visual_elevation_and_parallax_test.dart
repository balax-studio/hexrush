import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/flame/components/hex_tile_component.dart';
import 'package:hex_rush/presentation/flame/renderers/voxel_isometric_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('2.5D Voxel Visual Elevation Tests', () {
    test('drawIsoCube specular highlight ve çift katmanlı penumbra gölge çizer', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      VoxelIsometricRenderer.drawIsoCube(
        canvas,
        const Offset(0, 0),
        w: 20.0,
        d: 20.0,
        h: 15.0,
        topColor: const Color(0xFF64748B),
        leftColor: const Color(0xFF475569),
        rightColor: const Color(0xFF334155),
        drawShadow: true,
        shadowOpacity: 0.35,
        specularHighlight: true,
      );

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });

    test('drawTerracedCliffSteps çok katmanlı teras basamaklarını hatasız çizer', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      VoxelIsometricRenderer.drawTerracedCliffSteps(
        canvas,
        const Offset(50, 50),
        scale: 1.0,
      );

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });

    test('drawWaterBankReflections su yansıması dalga projeksiyonunu çizer', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      VoxelIsometricRenderer.drawWaterBankReflections(
        canvas,
        const Offset(100, 100),
        width: 48.0,
        height: 24.0,
        silhouetteColor: const Color(0xFF0F172A),
        time: 1.5,
        opacity: 0.2,
      );

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });

    test('drawEnvironmentalClutter tüm üretim binaları için mikro detayları çizer', () {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      const buildings = [
        BuildingType.windmill,
        BuildingType.quarry,
        BuildingType.lumberjack,
        BuildingType.castle,
      ];

      for (final b in buildings) {
        VoxelIsometricRenderer.drawEnvironmentalClutter(
          canvas,
          const Offset(0, 0),
          type: b,
          scale: 1.0,
          animTime: 2.0,
        );
      }

      final pic = recorder.endRecording();
      expect(pic, isNotNull);
      pic.dispose();
    });

    test('HexTileComponent yükseklik hesaplaması biyomlara göre doğru döner', () {
      expect(HexTileComponent.getBiomeElevation(TileBiome.mountain), 44.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.volcano), 38.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.kurganValley), 32.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.celestialCrater), 28.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.tundra), 24.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.forest), 20.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.meadow), 14.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.desert), 10.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.crystalChasm), 6.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.wetland), 4.0);
      expect(HexTileComponent.getBiomeElevation(TileBiome.sea), 0.0);
    });
  });
}
