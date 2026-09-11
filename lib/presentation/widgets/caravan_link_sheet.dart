import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/localization/game_localization.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class CaravanLinkSheet extends ConsumerWidget {
  final HexAxial startCoord;

  const CaravanLinkSheet({
    super.key,
    required this.startCoord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final lang = state.settings.language;
    final startTile = state.tiles[startCoord];

    if (startTile == null) {
      return const SizedBox.shrink();
    }

    // Aday Varış Karoları (Sahip olunan, 8 hex menzildeki diğer karolar)
    final candidateTiles = state.tiles.values.where((t) {
      if (!t.isOwned || t.coord == startCoord) return false;
      final int dist = startCoord.distanceTo(t.coord);
      return dist <= 8;
    }).toList();

    final title = GameLocalization.get('establish_caravan_route', lang: lang);
    final originText = GameLocalization.get('origin', lang: lang);
    final costText = lang == 'tr'
        ? 'Maliyet: 30 Kalas, 20 Ekmek | Bonus: +%25 Takas Rezonansı'
        : 'Cost: 30 Planks, 20 Bread | Bonus: +25% Trade Resonance';
    final emptyMsg = lang == 'tr'
        ? '8 Hex menzilinde kervan bağlanabilecek başka bir fethedilmiş arazi bulunamadı.'
        : 'No other conquered lands found within 8 hex range.';
    final distanceText = lang == 'tr' ? 'Mesafe' : 'Distance';
    final connectedText = GameLocalization.get('connected', lang: lang);
    final connectBtn = GameLocalization.get('connect', lang: lang);
    final closeBtn = GameLocalization.get('close', lang: lang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(
          top: BorderSide(color: Color(0xFFD97706), width: 2),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_calls, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$originText: ${startTile.biome.name.toUpperCase()} (${startCoord.q}, ${startCoord.r})\n$costText',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),
            if (candidateTiles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  emptyMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidateTiles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final target = candidateTiles[index];
                    final int dist = startCoord.distanceTo(target.coord);
                    final bool alreadyConnected = state.caravanRoutes.any((r) =>
                        (r.startCoord == startCoord && r.endCoord == target.coord) ||
                        (r.startCoord == target.coord && r.endCoord == startCoord));

                    final bool canAfford = state.resources.plank >= 30.0 && state.resources.bread >= 20.0;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        border: Border.all(
                          color: alreadyConnected ? const Color(0xFF10B981) : const Color(0xFF334155),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${target.biome.name.toUpperCase()} (${target.coord.q}, ${target.coord.r})',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$distanceText: $dist Hex ${target.hasBuilding ? "- ${target.building!.type.name.toUpperCase()}" : ""}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (alreadyConnected)
                            Text(
                              connectedText,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            )
                          else
                            TactileNeoButton(
                              onTap: canAfford
                                  ? () {
                                      ref.read(gameStateProvider.notifier).addCaravanRoute(startCoord, target.coord);
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              isEnabled: canAfford,
                              backgroundColor: const Color(0xFFF59E0B),
                              borderColor: Colors.black,
                              shadowOffset: 2.0,
                              height: 30,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              child: Text(
                                connectBtn,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            TactileNeoButton(
              onTap: () => Navigator.of(context).pop(),
              backgroundColor: const Color(0xFF1E293B),
              borderColor: const Color(0xFF334155),
              shadowOffset: 2.0,
              height: 36,
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              child: Text(
                closeBtn,
                style: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
