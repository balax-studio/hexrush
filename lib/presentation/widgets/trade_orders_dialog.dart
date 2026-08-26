import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/trade_order_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class TradeOrdersDialog extends ConsumerWidget {
  const TradeOrdersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(palette);
    final state = ref.watch(gameStateProvider);
    final orders = state.progression.activeTradeOrders;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 580),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.primaryGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.surfaceLight,
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  const GameVectorIcon(type: GameIconType.crown, size: 20, color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'İPEK YOLU ELÇİ SİPARİŞLERİ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    height: 28,
                    width: 28,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    backgroundColor: theme.surfaceLight,
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Orders List
            Expanded(
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        'Şu anda bekleyen elçi buyruğu bulunmuyor.',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(context, ref, theme, state, order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    NeoBrutalistThemeData theme,
    dynamic state,
    TradeOrderModel order,
  ) {
    final currentRes = state.resources;
    bool canAffordAll = true;

    final List<Widget> reqWidgets = [];
    for (final req in order.requiredResources.entries) {
      final double current = switch (req.key.toLowerCase()) {
        'food' => currentRes.food,
        'wood' => currentRes.wood,
        'flour' => currentRes.flour,
        'plank' => currentRes.plank,
        'bread' => currentRes.bread,
        'furniture' => currentRes.furniture,
        'stone' => currentRes.stone,
        'iron' => currentRes.iron,
        'fish' => currentRes.fish,
        'kumis' => currentRes.kumis,
        'felt' => currentRes.felt,
        'damascus_steel' || 'damascussteel' => currentRes.damascusSteel,
        _ => 0.0,
      };

      final bool hasEnough = current >= req.value;
      if (!hasEnough) canAffordAll = false;

      reqWidgets.add(
        Container(
          margin: const EdgeInsets.only(right: 6, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: hasEnough ? const Color(0xFF064E3B) : const Color(0xFF450A0A),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: hasEnough ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              width: 1,
            ),
          ),
          child: Text(
            '${req.key.toUpperCase()}: ${current.toInt()}/${req.value.toInt()}',
            style: TextStyle(
              color: hasEnough ? const Color(0xFF6EE7B7) : const Color(0xFFFCA5A5),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: order.isFulfilled ? const Color(0xFF0F172A) : theme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: order.isFulfilled ? theme.slateBorder : theme.border,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.title,
                  style: TextStyle(
                    color: order.isFulfilled ? Colors.grey.shade500 : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: theme.primaryGold, width: 1),
                ),
                child: Row(
                  children: [
                    const GameVectorIcon(type: GameIconType.crown, size: 10, color: Color(0xFFFFD700)),
                    const SizedBox(width: 4),
                    Text(
                      '+${order.rewardCrowns} TAÇ',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Elçi: ${order.requesterName} • Ödül: ${order.rewardSpeedMultiplier}x Altın Çağ Hızı (${order.buffDurationSeconds ~/ 60} dk)',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(children: reqWidgets),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: order.isFulfilled
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'TESLİM EDİLDİ',
                      style: TextStyle(
                        color: Color(0xFF6EE7B7),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : TactileNeoButton(
                    onTap: canAffordAll
                        ? () => ref.read(gameStateProvider.notifier).fulfillTradeOrder(order.id)
                        : null,
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    backgroundColor: canAffordAll ? theme.primaryGold : theme.surfaceLight,
                    borderColor: canAffordAll ? const Color(0xFFB45309) : theme.slateBorder,
                    child: Text(
                      'BUYRUĞU TESLİM ET',
                      style: TextStyle(
                        color: canAffordAll ? Colors.black : Colors.grey.shade500,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
