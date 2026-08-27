import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/building_model.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class GreatMigrationDialog extends ConsumerStatefulWidget {
  const GreatMigrationDialog({super.key});

  @override
  ConsumerState<GreatMigrationDialog> createState() => _GreatMigrationDialogState();
}

class _GreatMigrationDialogState extends ConsumerState<GreatMigrationDialog> {
  void _confirmAndExecuteMigration(
    BuildContext context,
    int newCrowns,
    int newTamgas,
    String lang,
  ) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: NeoBrutalistTheme.sharpRadius,
          side: const BorderSide(color: Color(0xFFEF4444), width: 2.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text(
              'BÜYÜK GÖÇÜ ONAYLIYOR MUSUNUZ?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        content: Text(
          'Mevcut topraklarınız ve hammaddeleriniz sıfırlanacak; obanız yeni çağa göç edecektir.\n\nKazanılacak Miras:\n• +$newCrowns Taç\n• +$newTamgas Kalıcı Atalar Tamgası\n• Binalarınız Ata Kurganlarına dönüşecek.\n\nDevam etmek istediğinizden emin misiniz?',
          style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.45),
        ),
        actions: [
          TactileNeoButton(
            onTap: () => Navigator.of(ctx).pop(),
            backgroundColor: const Color(0xFF1E293B),
            borderColor: const Color(0xFF475569),
            shadowOffset: 2.0,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: const Text('İPTAL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
          const SizedBox(width: 8),
          TactileNeoButton(
            onTap: () {
              Navigator.of(ctx).pop(); // Onay modalını kapat
              Navigator.of(context).pop(); // Büyük Göç modalını kapat
              ref.read(gameStateProvider.notifier).resetGame();
            },
            backgroundColor: const Color(0xFFDC2626),
            borderColor: Colors.black,
            shadowOffset: 2.5,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: const Text('EVET, GÖÇÜ BAŞLAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final palette = gameState.settings.activeThemePalette;
    final theme = NeoBrutalistTheme.getTheme(palette);
    final lang = gameState.settings.language;

    final breakdown = EconomyCalculator.calculateResetCrownsBreakdown(
      tiles: gameState.tiles.values,
      resources: gameState.resources,
      castleLevel: gameState.progression.castleLevel,
    );

    final int ownedHexes = gameState.progression.ownedCount;
    final int shrines = gameState.tiles.values.where((t) => t.isOwned && t.hasShrine).length;
    final int newTamgas = (ownedHexes + (shrines * 5)) ~/ 2;
    final int nextTotalTamgas = gameState.resources.tamgas + newTamgas;
    final double nextMultiplier = EconomyCalculator.getTamgaMultiplier(nextTotalTamgas);

    final int buildingCount = gameState.tiles.values
        .where((t) => t.isOwned && t.hasBuilding && t.building!.type != BuildingType.castle)
        .length;

    final String activeRealm = gameState.progression.activeRealmId;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: const Color(0xFFD97706), width: 2.5),
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
            // Başlık Çubuğu
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(bottom: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  const GameVectorIcon(type: GameIconType.land, size: 22, color: Color(0xFFFFD700)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BÜYÜK GÖÇ (PRESTİJ & ÇAĞ ATLAYIŞI)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Bozkırın Kadim Döngüsü ve Kalıcı Miras',
                          style: TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
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
                    backgroundColor: const Color(0xFF1E293B),
                    borderColor: theme.slateBorder,
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),

            // İçerik
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // 1. Kazanılacak Miraslar Özeti
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BU GÖÇTE KAZANILACAK KALICI MİRAS',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text('KAZANILACAK TAÇ', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '+${breakdown.totalCrowns}',
                                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFF334155)),
                            Column(
                              children: [
                                const Text('ATALAR TAMGASI', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '+$newTamgas',
                                  style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 28, color: const Color(0xFF334155)),
                            Column(
                              children: [
                                const Text('YENİ ÇARPAN', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '+${((nextMultiplier - 1.0) * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Taç Kazanım Detayları Kısa Dökümü
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF475569), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TAÇ KAZANIM DAĞILIMI:',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        _buildRow('Topraklar ($ownedHexes Karo)', '+${breakdown.hexCrowns} Taç', const Color(0xFF38BDF8)),
                        _buildRow('Ambar Stoğu', '+${breakdown.resourceCrowns} Taç', const Color(0xFF34D399)),
                        _buildRow('Binalar & Sunaklar', '+${breakdown.buildingAndShrineCrowns} Taç', const Color(0xFFF59E0B)),
                        _buildRow('Kurgana Dönüşecek Yapılar', '$buildingCount Adet Yapı', const Color(0xFFA78BFA)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Hedef Sefer Diyarı Seçimi
                  const Text(
                    'HEDEF SEFER DİYARI SEÇİMİ',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'altay',
                    title: 'ALTAY GÖKSEL PLATOLARI',
                    desc: 'Taş, Demir & Şam Çeliği 2x • Dağ fethinde %30 indirim',
                    color: const Color(0xFF818CF8),
                    isSelected: activeRealm == 'altay',
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'idil',
                    title: 'İDİL-YAYIK NEHİR HAVZASI',
                    desc: 'Balık, Gıda, Un & Kımız 2x • Sulak/Deniz fethinde %30 indirim',
                    color: const Color(0xFF34D399),
                    isSelected: activeRealm == 'idil',
                  ),
                  const SizedBox(height: 6),
                  _buildRealmOption(
                    id: 'karakum',
                    title: 'KARAKUM & TARIM VAHALARI',
                    desc: 'Kervanlar, Pazar & Taç Getirisi 2x • Keçe üretimi +%50',
                    color: const Color(0xFFF59E0B),
                    isSelected: activeRealm == 'karakum',
                  ),
                ],
              ),
            ),

            // Alt Buton Alanı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                border: Border(top: BorderSide(color: theme.border, width: 2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TactileNeoButton(
                      onTap: () => Navigator.of(context).pop(),
                      height: 38,
                      backgroundColor: const Color(0xFF1E293B),
                      borderColor: theme.slateBorder,
                      alignment: Alignment.center,
                      child: Text(
                        GameLocalization.get('close', lang: lang).toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TactileNeoButton(
                      onTap: () => _confirmAndExecuteMigration(context, breakdown.totalCrowns, newTamgas, lang),
                      height: 38,
                      backgroundColor: const Color(0xFFDC2626),
                      borderColor: Colors.black,
                      shadowOffset: 2.5,
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flight_takeoff, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'BÜYÜK GÖÇÜ BAŞLAT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildRealmOption({
    required String id,
    required String title,
    required String desc,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(gameStateProvider.notifier).selectMigrationRealm(id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFF0F172A),
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(
            color: isSelected ? color : const Color(0xFF334155),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? color : const Color(0xFF64748B),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? color : Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
