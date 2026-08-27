import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/hex/hex_coordinates.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/celestial_omen_model.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/hex_tile_model.dart';
import '../providers/game_state_notifier.dart';
import 'offline_gains_dialog.dart';
import 'tactile_neo_button.dart';

class DebugMenuDialog extends ConsumerWidget {
  const DebugMenuDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          border: Border.all(color: const Color(0xFFA855F7), width: 2.5),
          boxShadow: theme.hardShadow(offset: 4.0),
        ),
        child: Column(
          children: [
            // Başlık Barı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF581C87),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3),
                  topRight: Radius.circular(3),
                ),
                border: Border(
                  bottom: BorderSide(color: theme.slateBorder, width: 2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.developer_mode, color: Color(0xFFE9D5FF), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'GELİŞTİRİCİ DENETİM KONSOLU',
                    style: TextStyle(
                      color: Color(0xFFF3E8FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const Spacer(),
                  TactileNeoButton(
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor: theme.surfaceLight,
                    borderColor: theme.border,
                    shadowColor: theme.shadowColor,
                    shadowOffset: 1.5,
                    height: 26,
                    width: 26,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.center,
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),

            // İçerik Listesi
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. ÇEVRİMDIŞI (AFK) KAZANÇ TESTLERİ
                    _buildSectionHeader('ÇEVRİMDIŞI (AFK) KAZANÇ SİMÜLASYONU', Icons.history_toggle_off, const Color(0xFF38BDF8)),
                    const SizedBox(height: 6),
                    const Text(
                      'Haritadaki mevcut yapı ve işçilerinize göre seçilen süredeki çevrimdışı kazancı anında hesaplar ve diyalog penceresini açar.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '15 DK AFK',
                            color: const Color(0xFF0369A1),
                            borderColor: const Color(0xFF38BDF8),
                            onTap: () => _simulateOfflineGains(context, ref, 15 * 60),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '1 SAAT AFK',
                            color: const Color(0xFF0284C7),
                            borderColor: const Color(0xFF38BDF8),
                            onTap: () => _simulateOfflineGains(context, ref, 3600),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '8 SAAT AFK',
                            color: const Color(0xFF0C4A6E),
                            borderColor: const Color(0xFF38BDF8),
                            onTap: () => _simulateOfflineGains(context, ref, 8 * 3600),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 2. KAYNAK VE BEREKET EKLEME
                    _buildSectionHeader('KAYNAK VE EKONOMİ HİLELERİ', Icons.account_balance_wallet, const Color(0xFF10B981)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '+10K TEMEL KAYNAKLAR',
                            color: const Color(0xFF065F46),
                            borderColor: const Color(0xFF34D399),
                            onTap: () {
                              notifier.state = notifier.state.copyWith(
                                resources: notifier.state.resources.copyWith(
                                  food: notifier.state.resources.food + 10000,
                                  wood: notifier.state.resources.wood + 10000,
                                  stone: notifier.state.resources.stone + 10000,
                                  iron: notifier.state.resources.iron + 10000,
                                ),
                              );
                              notifier.saveGame();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '+5K İŞLENMİŞ ÜRÜNLER',
                            color: const Color(0xFF047857),
                            borderColor: const Color(0xFF34D399),
                            onTap: () {
                              notifier.state = notifier.state.copyWith(
                                resources: notifier.state.resources.copyWith(
                                  flour: notifier.state.resources.flour + 5000,
                                  plank: notifier.state.resources.plank + 5000,
                                  bread: notifier.state.resources.bread + 5000,
                                  furniture: notifier.state.resources.furniture + 5000,
                                  fish: notifier.state.resources.fish + 5000,
                                ),
                              );
                              notifier.saveGame();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '+2K NADİR & +500 BİLGELİK',
                            color: const Color(0xFF0F766E),
                            borderColor: const Color(0xFF2DD4BF),
                            onTap: () {
                              notifier.state = notifier.state.copyWith(
                                resources: notifier.state.resources.copyWith(
                                  kumis: notifier.state.resources.kumis + 2000,
                                  felt: notifier.state.resources.felt + 2000,
                                  damascusSteel: notifier.state.resources.damascusSteel + 2000,
                                  wisdom: notifier.state.resources.wisdom + 500,
                                ),
                              );
                              notifier.saveGame();
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: '+500 TAÇ',
                            color: const Color(0xFF78350F),
                            borderColor: const Color(0xFFFBBF24),
                            onTap: () {
                              notifier.state = notifier.state.copyWith(
                                resources: notifier.state.resources.copyWith(
                                  crowns: notifier.state.resources.crowns + 500,
                                ),
                              );
                              notifier.saveGame();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 3. MEVSİM VE GÖK KEHANETİ KONTROLÜ
                    _buildSectionHeader('MEVSİM VE GÖK OLAYLARI', Icons.wb_sunny, const Color(0xFFF59E0B)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSeasonButton(context, notifier, 'BAHAR', 'SPRING', false, const Color(0xFF166534)),
                        const SizedBox(width: 4),
                        _buildSeasonButton(context, notifier, 'YAZ', 'SUMMER', false, const Color(0xFF854D0E)),
                        const SizedBox(width: 4),
                        _buildSeasonButton(context, notifier, 'GÜZ', 'AUTUMN', false, const Color(0xFF9A3412)),
                        const SizedBox(width: 4),
                        _buildSeasonButton(context, notifier, 'KIŞ', 'WINTER', false, const Color(0xFF1E40AF)),
                        const SizedBox(width: 4),
                        _buildSeasonButton(context, notifier, 'ZUD', 'WINTER', true, const Color(0xFF4C1D95)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildActionButton(
                      context: context,
                      label: 'GÖK KEHANETİ TETİKLE (ŞAMAN LÜTFU)',
                      color: const Color(0xFF312E81),
                      borderColor: const Color(0xFF818CF8),
                      onTap: () {
                        final nextYear = gameState.yearIndex + 1;
                        notifier.state = notifier.state.copyWith(
                          yearIndex: nextYear,
                          celestialOmen: CelestialOmen.fromYearIndex(nextYear),
                        );
                        notifier.saveGame();
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4. KİLOMETRE TAŞI & SEVİYE AYARLAMA
                    _buildSectionHeader('BİNA KİLOMETRE TAŞI TESTLERİ', Icons.military_tech, const Color(0xFFEAB308)),
                    const SizedBox(height: 6),
                    const Text(
                      'Seçili karodaki binayı kilometre taşı öncesi seviyeye sabitler (2X Gelir butonunu test etmek için).',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    if (gameState.selectedCoord != null &&
                        gameState.tiles[gameState.selectedCoord!]?.building != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              label: 'SEVİYE 9 YAP (➜ 10)',
                              color: const Color(0xFF713F12),
                              borderColor: const Color(0xFFFDE047),
                              onTap: () => _setSelectedTileBuildingLevel(ref, 9),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              label: 'SEVİYE 24 YAP (➜ 25)',
                              color: const Color(0xFF713F12),
                              borderColor: const Color(0xFFFDE047),
                              onTap: () => _setSelectedTileBuildingLevel(ref, 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              label: 'SEVİYE 49 YAP (➜ 50)',
                              color: const Color(0xFF713F12),
                              borderColor: const Color(0xFFFDE047),
                              onTap: () => _setSelectedTileBuildingLevel(ref, 49),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              label: 'SEVİYE 99 YAP (➜ 100)',
                              color: const Color(0xFF713F12),
                              borderColor: const Color(0xFFFDE047),
                              onTap: () => _setSelectedTileBuildingLevel(ref, 99),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.surfaceLight,
                          borderRadius: NeoBrutalistTheme.sharpRadius,
                          border: Border.all(color: theme.slateBorder, width: 1),
                        ),
                        child: const Center(
                          child: Text(
                            'Kilometre taşı butonunu denemek için önce haritada binalı bir karo seçin.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 5. HARİTA VE SİS YÖNETİMİ
                    _buildSectionHeader('HARİTA VE SİS YÖNETİMİ', Icons.map, const Color(0xFFEC4899)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: 'TÜM SİSLERİ AÇ',
                            color: const Color(0xFF831843),
                            borderColor: const Color(0xFFF472B6),
                            onTap: () {
                              final updated = <HexAxial, HexTileModel>{};
                              gameState.tiles.forEach((k, v) {
                                updated[k] = v.copyWith(
                                  state: v.state == TileState.fog ? TileState.discovered : v.state,
                                );
                              });
                              notifier.state = notifier.state.copyWith(tiles: updated);
                              notifier.saveGame();
                              notifier.showToast('Haritadaki tüm sisler açıldı.');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: 'SİSLERİ GERİ KAPAT',
                            color: const Color(0xFF4A044E),
                            borderColor: const Color(0xFFE879F9),
                            onTap: () {
                              final updated = <HexAxial, HexTileModel>{};
                              const center = HexAxial(0, 0);
                              gameState.tiles.forEach((k, v) {
                                final bool isCenterArea = center.distanceTo(k) <= 1;
                                final bool isCastleOrOwnedBuilding = v.building != null && v.isOwned;
                                if (isCenterArea || isCastleOrOwnedBuilding) {
                                  updated[k] = v;
                                } else {
                                  updated[k] = v.copyWith(state: TileState.fog);
                                }
                              });
                              notifier.state = notifier.state.copyWith(tiles: updated);
                              notifier.saveGame();
                              notifier.showToast('Dış sisler yeniden kapatıldı.');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: 'TÜM BÖLGELERİ SAHİPLEN',
                            color: const Color(0xFF701A75),
                            borderColor: const Color(0xFFE879F9),
                            onTap: () {
                              final updated = <HexAxial, HexTileModel>{};
                              gameState.tiles.forEach((k, v) {
                                updated[k] = v.copyWith(state: TileState.owned);
                              });
                              notifier.state = notifier.state.copyWith(
                                tiles: updated,
                                progression: notifier.state.progression.copyWith(
                                  ownedCount: updated.values.where((t) => t.isOwned).length,
                                ),
                              );
                              notifier.saveGame();
                              notifier.showToast('Tüm karolar sahiplenildi.');
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 6. KAYIT VE DURUM SIFIRLAMA
                    _buildSectionHeader('KAYIT VE MOTOR YÖNETİMİ', Icons.save, const Color(0xFFEF4444)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: 'DİSKE ZORLA KAYDET',
                            color: const Color(0xFF1E293B),
                            borderColor: const Color(0xFF64748B),
                            onTap: () async {
                              await notifier.saveGame();
                              notifier.showToast('Oyun verisi SharedPreferences içine kaydedildi.');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            label: 'KAYDI YENİDEN YÜKLE',
                            color: const Color(0xFF1E293B),
                            borderColor: const Color(0xFF64748B),
                            onTap: () async {
                              await notifier.initialize();
                              notifier.showToast('Kayıtlı veri diskten tekrar yüklendi.');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return TactileNeoButton(
      onTap: onTap,
      backgroundColor: color,
      borderColor: borderColor,
      shadowColor: const Color(0xFF020617),
      shadowOffset: 2.0,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      soundType: TactileSoundType.tap,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 9.5,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSeasonButton(
    BuildContext context,
    GameStateNotifier notifier,
    String label,
    String seasonKey,
    bool isZud,
    Color bg,
  ) {
    return Expanded(
      child: TactileNeoButton(
        onTap: () {
          notifier.state = notifier.state.copyWith(
            season: notifier.state.season.copyWith(
              current: seasonKey,
              isZud: isZud,
              timer: 60.0,
            ),
          );
          notifier.saveGame();
        },
        backgroundColor: bg,
        borderColor: Colors.white24,
        shadowColor: const Color(0xFF020617),
        shadowOffset: 1.5,
        height: 28,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        soundType: TactileSoundType.tap,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 9,
            ),
          ),
        ),
      ),
    );
  }

  void _simulateOfflineGains(BuildContext context, WidgetRef ref, int seconds) {
    final gameState = ref.read(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    final globalMult = EconomyCalculator.getGlobalMultiplier(
      castleLevel: gameState.progression.castleLevel,
      crowns: gameState.resources.crowns,
      toreTalents: gameState.toreTalents,
      titles: gameState.titles,
    );

    final offline = EconomyCalculator.calculateOfflineGains(
      tiles: gameState.tiles.values.toList(),
      elapsedSeconds: seconds.toDouble(),
      globalMultiplier: globalMult,
    );

    if (!offline.hasGains) {
      notifier.showToast('Haritada çalışan üretim binası bulunmuyor (Tüm kazançlar 0).');
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => OfflineGainsDialog(gains: offline),
    );
  }

  void _setSelectedTileBuildingLevel(WidgetRef ref, int level) {
    final state = ref.read(gameStateProvider);
    final coord = state.selectedCoord;
    if (coord == null) return;
    final tile = state.tiles[coord];
    if (tile == null || tile.building == null) return;

    final updatedTiles = Map<HexAxial, HexTileModel>.from(state.tiles);
    updatedTiles[coord] = tile.copyWith(
      building: tile.building!.copyWith(level: level),
    );

    ref.read(gameStateProvider.notifier).state = state.copyWith(tiles: updatedTiles);
    ref.read(gameStateProvider.notifier).saveGame();
    ref.read(gameStateProvider.notifier).showToast('${tile.building!.type.name.toUpperCase()} Seviye $level yapıldı.');
  }
}
