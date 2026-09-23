import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../core/utils/number_formatter.dart';
import '../../domain/models/trade_order_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class TradeOrdersDialog extends ConsumerWidget {
  const TradeOrdersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final lang = ref.watch(gameStateProvider.select((s) => s.settings.language));
    final theme = NeoBrutalistTheme.getTheme(palette);
    final state = ref.watch(gameStateProvider);
    final orders = state.progression.activeTradeOrders;
    final dailyCount = state.progression.dailyTradeOrdersCompletedCount;
    final dailyMultiplier = math.pow(10.0, dailyCount).toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
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
                  const GameVectorIcon(type: GameIconType.tradeOrders, size: 20, color: Color(0xFFFDE047)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          GameLocalization.get('trade_orders_title', lang: lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (dailyCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${GameLocalization.get('daily_trade_multiplier', lang: lang)}: ${NumberFormatter.format(dailyMultiplier)}x (Seviye $dailyCount)',
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
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
                        GameLocalization.get('no_envoy_orders', lang: lang),
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: orders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildOrderCard(context, ref, theme, state, order, lang);
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
    String lang,
  ) {
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final bool isLocked = order.isLocked(nowMs);
    final int remainingSec = order.getRemainingSeconds(nowMs);
    final int remMin = remainingSec ~/ 60;
    final int remSecPart = remainingSec % 60;
    final String timerStr = '${remMin.toString().padLeft(2, '0')}:${remSecPart.toString().padLeft(2, '0')}';

    final currentRes = state.resources;
    bool canAffordAll = true;

    final List<Widget> reqWidgets = [];
    for (final req in order.requiredResources.entries) {
      final double current = (switch (req.key.toLowerCase()) {
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
        'obsidian' => currentRes.obsidian,
        'mithril' => currentRes.mithril,
        _ => 0.0,
      } as num).toDouble();

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
            '${req.key.toUpperCase()}: ${NumberFormatter.format(current)} / ${NumberFormatter.format(req.value)}',
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
        color: isLocked ? const Color(0xFF0B0F19) : theme.surface,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isLocked ? const Color(0xFF334155) : theme.border,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık ve Ödül Çipi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.title,
                  style: TextStyle(
                    color: isLocked ? Colors.grey.shade500 : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isLocked ? const Color(0xFF1E293B) : const Color(0xFF451A03),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: isLocked ? theme.slateBorder : const Color(0xFFF59E0B),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${order.rewardSpeedMultiplier.toStringAsFixed(2)}x HIZ • ${order.buffDurationSeconds ~/ 60} DK',
                  style: TextStyle(
                    color: isLocked ? Colors.grey.shade400 : const Color(0xFFFDE047),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Elçi: ${order.requesterName}',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 8),

          if (isLocked) ...[
            // Kilitli / Kervan Yolda Durumu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: const Color(0xFF334155), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_top, size: 14, color: Color(0xFFFDE047)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${GameLocalization.get('caravan_in_transit', lang: lang)} • ${GameLocalization.get('new_envoy_timer', lang: lang)} $timerStr',
                      style: const TextStyle(
                        color: Color(0xFFFDE047),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // İstenen Kaynaklar Listesi
            Wrap(children: reqWidgets),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TactileNeoButton(
                onTap: canAffordAll
                    ? () => ref.read(gameStateProvider.notifier).fulfillTradeOrder(order.id)
                    : null,
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                backgroundColor: canAffordAll ? theme.primaryGold : theme.surfaceLight,
                borderColor: canAffordAll ? const Color(0xFFB45309) : theme.slateBorder,
                child: Text(
                  GameLocalization.get('deliver_order_btn', lang: lang),
                  style: TextStyle(
                    color: canAffordAll ? Colors.black : Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
