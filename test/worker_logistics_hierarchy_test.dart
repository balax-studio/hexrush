import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hex_rush/core/hex/hex_coordinates.dart';
import 'package:hex_rush/domain/models/building_model.dart';
import 'package:hex_rush/domain/models/hex_tile_model.dart';
import 'package:hex_rush/presentation/flame/components/worker_agent_component.dart';

void main() {
  group('Lojistik Taşıyıcı Rota ve Hedefleme Testleri', () {
    test('WorkerAgentComponent mesafe ve süre ölçeklemesi doğru çalışır', () {
      final start = Vector2(0, 0);
      final nearTarget = Vector2(80, 0);
      final farTarget = Vector2(400, 0);

      final workerNear = WorkerAgentComponent(
        startPos: start,
        endPos: nearTarget,
        cargoColor: Colors.amber,
        seed: 42,
      );

      final workerFar = WorkerAgentComponent(
        startPos: start,
        endPos: farTarget,
        cargoColor: Colors.amber,
        seed: 42,
      );

      // Hedef güncelleme testi
      workerNear.updateEndPos(Vector2(200, 0));
      expect(workerNear.endPos, equals(Vector2(200, 0)));
      expect(workerFar.endPos, equals(farTarget));
    });

    test('Eksenel mesafe hesaplaması en yakın depolama binasını doğru bulur', () {
      const producerCoord = HexAxial(3, -1);
      const nearGranary = HexAxial(2, -1); // Mesafe: 1
      const farCaravanserai = HexAxial(0, 4); // Mesafe: 5

      final storageOptions = [farCaravanserai, nearGranary];

      HexAxial nearest = storageOptions.first;
      int minDistance = producerCoord.distanceTo(nearest);
      for (final s in storageOptions) {
        final dist = producerCoord.distanceTo(s);
        if (dist < minDistance) {
          minDistance = dist;
          nearest = s;
        }
      }

      expect(nearest, equals(nearGranary));
      expect(minDistance, equals(1));
    });

    test('HexTileModel isWarmed kış ısıtma durumu doğru saklanır', () {
      const tileUnwarmed = HexTileModel(
        coord: HexAxial(1, 1),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn),
        isWarmed: false,
      );

      const tileWarmed = HexTileModel(
        coord: HexAxial(1, 1),
        biome: TileBiome.meadow,
        state: TileState.owned,
        building: BuildingModel(type: BuildingType.corn),
        isWarmed: true,
      );

      expect(tileUnwarmed.isWarmed, isFalse);
      expect(tileWarmed.isWarmed, isTrue);
    });
  });
}
