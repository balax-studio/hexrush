import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/steppe_lore_tree_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class SteppeLoreTreeDialog extends ConsumerStatefulWidget {
  const SteppeLoreTreeDialog({super.key});

  @override
  ConsumerState<SteppeLoreTreeDialog> createState() => _SteppeLoreTreeDialogState();
}

class _SteppeLoreTreeDialogState extends ConsumerState<SteppeLoreTreeDialog> {
  SteppeLoreBranch _selectedBranch = SteppeLoreBranch.logistics;

  @override
  Widget build(BuildContext context) {
    final palette = ref.watch(gameStateProvider.select((s) => s.settings.activeThemePalette));
    final theme = NeoBrutalistTheme.getTheme(palette);
    final state = ref.watch(gameStateProvider);
    final wisdom = state.resources.wisdom;
    final unlockedIds = state.progression.unlockedLoreIds;

    final branchNodes = SteppeLoreNode.defaultLoreTree
        .where((n) => n.branch == _selectedBranch)
        .toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF06B6D4), width: 2),
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
                  const GameVectorIcon(type: GameIconType.wisdom, size: 20, color: Color(0xFF06B6D4)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'ORHUN BİTİG TAŞLARI & TÖRE AĞACI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF083344),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: const Color(0xFF06B6D4), width: 1),
                    ),
                    child: Text(
                      'BİTİG: ${wisdom.toInt()}',
                      style: const TextStyle(
                        color: Color(0xFF67E8F9),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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

            // Branch Tabs
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0xFF0B132B),
              child: Row(
                children: [
                  _buildBranchTab(SteppeLoreBranch.logistics, 'Lojistik', theme),
                  const SizedBox(width: 4),
                  _buildBranchTab(SteppeLoreBranch.weatherCraft, 'Isınma', theme),
                  const SizedBox(width: 4),
                  _buildBranchTab(SteppeLoreBranch.soilMastery, 'Toprak', theme),
                  const SizedBox(width: 4),
                  _buildBranchTab(SteppeLoreBranch.metallurgy, 'Döküm', theme),
                ],
              ),
            ),

            // Lore Nodes
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: branchNodes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final node = branchNodes[index];
                  final bool isUnlocked = unlockedIds.contains(node.id);
                  final bool canAfford = wisdom >= node.costWisdom;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUnlocked ? const Color(0xFF083344) : theme.surface,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: isUnlocked ? const Color(0xFF06B6D4) : theme.border,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isUnlocked ? const Color(0xFF06B6D4) : theme.surfaceLight,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'T${node.tier}',
                            style: TextStyle(
                              color: isUnlocked ? Colors.black : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                node.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                node.description,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 9.5,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (isUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF065F46),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Text(
                              'AÇILDI',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          )
                        else
                          TactileNeoButton(
                            onTap: canAfford
                                ? () => ref.read(gameStateProvider.notifier).unlockSteppeLore(node.id)
                                : null,
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            backgroundColor: canAfford ? const Color(0xFF06B6D4) : theme.surfaceLight,
                            borderColor: canAfford ? const Color(0xFF0891B2) : theme.slateBorder,
                            child: Text(
                              '${node.costWisdom.toInt()} BİTİG',
                              style: TextStyle(
                                color: canAfford ? Colors.black : Colors.grey.shade500,
                                fontSize: 9,
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
          ],
        ),
      ),
    );
  }

  Widget _buildBranchTab(SteppeLoreBranch branch, String label, NeoBrutalistThemeData theme) {
    final bool isSelected = _selectedBranch == branch;
    return Expanded(
      child: TactileNeoButton(
        onTap: () => setState(() => _selectedBranch = branch),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        backgroundColor: isSelected ? const Color(0xFF06B6D4) : theme.surface,
        borderColor: isSelected ? const Color(0xFF0891B2) : theme.border,
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
