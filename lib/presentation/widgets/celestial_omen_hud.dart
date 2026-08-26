import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/celestial_omen_model.dart';
import '../providers/game_state_notifier.dart';

class CelestialOmenHud extends ConsumerWidget {
  const CelestialOmenHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final omen = ref.watch(gameStateProvider.select((s) => s.celestialOmen));

    IconData getAnimalIcon(CelestialAnimal animal) {
      switch (animal) {
        case CelestialAnimal.rat:
          return Icons.grain;
        case CelestialAnimal.ox:
          return Icons.agriculture;
        case CelestialAnimal.tiger:
          return Icons.park;
        case CelestialAnimal.rabbit:
          return Icons.speed;
        case CelestialAnimal.dragon:
          return Icons.auto_awesome;
        case CelestialAnimal.snake:
          return Icons.healing;
        case CelestialAnimal.horse:
          return Icons.directions_run;
        case CelestialAnimal.sheep:
          return Icons.nature;
        case CelestialAnimal.monkey:
          return Icons.build;
        case CelestialAnimal.rooster:
          return Icons.wb_sunny;
        case CelestialAnimal.dog:
          return Icons.shield;
        case CelestialAnimal.pig:
          return Icons.landscape;
      }
    }

    return Tooltip(
      message: '${omen.title}: ${omen.description}',
      preferBelow: true,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border.all(color: const Color(0xFFD97706), width: 1.5),
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [
            BoxShadow(color: Color(0xFF020617), offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(getAnimalIcon(omen.animal), color: const Color(0xFFF59E0B), size: 14),
            const SizedBox(width: 5),
            Text(
              omen.title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
