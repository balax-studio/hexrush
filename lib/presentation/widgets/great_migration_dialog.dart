import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../core/utils/number_formatter.dart';
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
  bool _isBreakdownExpanded = true;

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
          'Mevcut topraklarınız ve hammaddeleriniz sıfırlanacak; obanız yeni çağa göç edecektir.\n\nKazanılacak Miras:\n• +$newCrowns Taç (Şan & Kut Puanı)\n• +$newTamgas Kalıcı Atalar Tamgası\n• Binalarınız Ata Kurganlarına dönüşecek.\n\nDevam etmek istediğinizden emin misiniz?',
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
    final double nextKut = EconomyCalculator.calculateKutMultiplier(
      tamgas: nextTotalTamgas,
      totalMigrations: gameState.progression.totalMigrations + 1,
      victoryMilestones: gameState.progression.victoryMilestones,
      activeOaths: gameState.progression.activeOaths,
    );

    // Tamga katkı hesabı
    double tamgaBonus = 0.0;
    if (nextTotalTamgas <= 50) {
      tamgaBonus = nextTotalTamgas * 0.04;
    } else {
      tamgaBonus = 2.0 + (math.log(nextTotalTamgas - 49.0) / math.ln10) * 0.5;
    }
    final double migrationBonus = (gameState.progression.totalMigrations + 1) * 0.05;
    int victoryCount = 0;
    for (final v in gameState.progression.victoryMilestones.values) {
      if (v) victoryCount++;
    }
    final double victoryBonus = victoryCount * 0.25;
    final double oathBonus = gameState.progression.activeOaths.length * 0.15;

    final double totalResourceStock = gameState.resources.food +
        gameState.resources.wood +
        gameState.resources.stone +
        gameState.resources.iron +
        gameState.resources.fish +
        gameState.resources.flour +
        gameState.resources.plank +
        gameState.resources.bread +
        gameState.resources.furniture +
        (gameState.resources.kumis * 2.0) +
        (gameState.resources.felt * 2.0) +
        (gameState.resources.damascusSteel * 3.0) +
        gameState.resources.wisdom;

    int buildingLevelsTotal = 0;
    for (final tile in gameState.tiles.values) {
      if (tile.isOwned && tile.hasBuilding && tile.building!.type != BuildingType.castle) {
        buildingLevelsTotal += tile.building!.level;
      }
    }

    final int buildingCount = gameState.tiles.values
        .where((t) => t.isOwned && t.hasBuilding && t.building!.type != BuildingType.castle)
        .length;

    final String activeRealm = gameState.progression.activeRealmId;
    final victories = gameState.progression.victoryMilestones;
    final activeOaths = gameState.progression.activeOaths;

    final bool isEligible = gameState.progression.castleLevel >= 5 && gameState.progression.ownedCount >= 12;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 700),
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
                          'BÜYÜK GÖÇ (PRESTİJ & KUT KATLAYICI)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                        Text(
                          'Bozkırın Ebedi Zafer Döngüsü ve Miras Katsayısı',
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
                                const Text('KUT KATSAYISI', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  '${nextKut.toStringAsFixed(2)}x',
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

                  // 2. DETAYLI KAZANIM & KAYNAK DAĞILIM DÖKÜMÜ (BREAKDOWN)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isBreakdownExpanded = !_isBreakdownExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: const Color(0xFF1E293B),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF38BDF8)),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'KAZANIM & MİRAS DAĞILIM LİSTESİ (NEREDEN NE GELİYOR?)',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _isBreakdownExpanded ? Icons.expand_less : Icons.expand_more,
                                  size: 18,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isBreakdownExpanded) ...[
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // A. Taç Dağılımı
                                const Row(
                                  children: [
                                    GameVectorIcon(type: GameIconType.crown, size: 14, color: Color(0xFFFFD700)),
                                    SizedBox(width: 6),
                                    Text(
                                      'TAÇ (KUT/ŞAN) KAZANIM DAĞILIMI',
                                      style: TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildBreakdownRow(
                                  title: 'Hüküm Sürülen Topraklar (Hexler)',
                                  desc: '$ownedHexes Fethedilmiş Karo (Her 5 Karo = 1 Taç)',
                                  yieldText: '+${breakdown.hexCrowns} Taç',
                                  color: const Color(0xFF38BDF8),
                                ),
                                _buildBreakdownRow(
                                  title: 'Ambar ve Hammadde Refah Stoğu',
                                  desc: '${NumberFormatter.format(totalResourceStock)} birim stok (Kademeli Refah)',
                                  yieldText: '+${breakdown.resourceCrowns} Taç',
                                  color: const Color(0xFF34D399),
                                ),
                                _buildBreakdownRow(
                                  title: 'Binalar, Sunaklar ve Otağ Kademesi',
                                  desc: 'Otağ Sv.${gameState.progression.castleLevel} ($shrines Sunak, $buildingLevelsTotal Yapı Kademesi)',
                                  yieldText: '+${breakdown.buildingAndShrineCrowns} Taç',
                                  color: const Color(0xFFF59E0B),
                                ),
                                Divider(color: Colors.white.withValues(alpha: 0.1), height: 16),

                                // B. Tamga Dağılımı
                                const Row(
                                  children: [
                                    Icon(Icons.shield_moon_outlined, size: 14, color: Color(0xFF38BDF8)),
                                    SizedBox(width: 6),
                                    Text(
                                      'ATALAR TAMGASI DAĞILIMI',
                                      style: TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildBreakdownRow(
                                  title: 'Toprak Mirası Payı',
                                  desc: '$ownedHexes Karo (~/2 Oranıyla)',
                                  yieldText: '+${ownedHexes ~/ 2} Tamga',
                                  color: const Color(0xFF38BDF8),
                                ),
                                if (shrines > 0)
                                  _buildBreakdownRow(
                                    title: 'Kadim Tapınak & Sunak Payı',
                                    desc: '$shrines Kutlu Sunak (x5 Ağırlık)',
                                    yieldText: '+${(shrines * 5) ~/ 2} Tamga',
                                    color: const Color(0xFFA78BFA),
                                  ),
                                _buildBreakdownRow(
                                  title: 'Tamga Formülü',
                                  desc: '(Toprak Sayısı + Sunak * 5) / 2',
                                  yieldText: 'Toplam +$newTamgas',
                                  color: const Color(0xFF10B981),
                                ),
                                Divider(color: Colors.white.withValues(alpha: 0.1), height: 16),

                                // C. Kut Katsayısı Bileşenleri
                                const Row(
                                  children: [
                                    Icon(Icons.bolt, size: 14, color: Color(0xFF10B981)),
                                    SizedBox(width: 6),
                                    Text(
                                      'YENİ KUT KATSAYISI HIZ BİLEŞENLERİ',
                                      style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildBreakdownRow(
                                  title: 'Kümülatif Tamgalar ($nextTotalTamgas Adet)',
                                  desc: 'Kalıcı üretim hız çarpanı',
                                  yieldText: '+%${(tamgaBonus * 100).toStringAsFixed(1)}',
                                  color: const Color(0xFF38BDF8),
                                ),
                                _buildBreakdownRow(
                                  title: 'Büyük Göç Tecrübesi (${gameState.progression.totalMigrations + 1}. Göç)',
                                  desc: 'Her göçte kalıcı +%5',
                                  yieldText: '+%${(migrationBonus * 100).toStringAsFixed(0)}',
                                  color: const Color(0xFFFBBF24),
                                ),
                                if (victoryCount > 0)
                                  _buildBreakdownRow(
                                    title: 'Ebedi Zaferler ($victoryCount Zafer)',
                                    desc: 'Zafer başı +%25',
                                    yieldText: '+%${(victoryBonus * 100).toStringAsFixed(0)}',
                                    color: const Color(0xFF10B981),
                                  ),
                                if (activeOaths.isNotEmpty)
                                  _buildBreakdownRow(
                                    title: 'Kutsal Andlar (${activeOaths.length} And)',
                                    desc: 'And başı +%15 ekstra',
                                    yieldText: '+%${(oathBonus * 100).toStringAsFixed(0)}',
                                    color: const Color(0xFFEC4899),
                                  ),
                                Divider(color: Colors.white.withValues(alpha: 0.1), height: 16),

                                // D. Ata Kurganı
                                _buildBreakdownRow(
                                  title: 'Atalar Kurganı Mirası',
                                  desc: '$buildingCount Adet görkemli yapı yeni diyarda Kutsal Kurgan kalıntısına dönüşecek.',
                                  yieldText: '$buildingCount Kurgan',
                                  color: const Color(0xFFC084FC),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Bengü İl Zafer Rozetleri
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
                          'EBEDİ DEVLET ZAFERLERİ:',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        _buildVictoryRow('Orhun Bengü Taşları (Kültürel)', victories['culturalBenguTas'] == true),
                        _buildVictoryRow('Ulu İpek Yolu Ağı (Lojistik)', victories['silkRoadNetwork'] == true),
                        _buildVictoryRow('4 Kadim Diyar Hakimiyeti (Coğrafi)', victories['realmConquest'] == true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 4. Kutsal Andlar (Meydan Okuma Modifikatörleri)
                  const Text(
                    'KUTSAL ANDLAR (MEYDAN OKUMA MODİFİKATÖRLERİ)',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildOathOption(
                    id: 'oath_of_iron',
                    title: 'Yalın Kılıç Andı (+%15 Kut)',
                    desc: 'Maden & demir odaklı ilerleme • Ekstra Tamga bereketi',
                    isSelected: activeOaths.contains('oath_of_iron'),
                  ),
                  const SizedBox(height: 6),
                  _buildOathOption(
                    id: 'oath_of_frost',
                    title: 'Buzul Çağı Andı (+%15 Kut)',
                    desc: 'Kış ve Zud boranlarına karşı çetin direnç',
                    isSelected: activeOaths.contains('oath_of_frost'),
                  ),
                  const SizedBox(height: 12),

                  // 5. Hedef Sefer Diyarı Seçimi
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
              child: Column(
                children: [
                  if (!isEligible)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7F1D1D),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, color: Colors.white70, size: 12),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Oba henüz göçe hazır değil (Gereken: Otağ Sv. 5 ve en az 12 Karo)',
                                style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Row(
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
                          onTap: isEligible
                              ? () => _confirmAndExecuteMigration(context, breakdown.totalCrowns, newTamgas, lang)
                              : () {
                                  ref.read(gameStateProvider.notifier).showToast('Göç için Kağan Otağı Sv. 5 ve 12 Karo gereklidir.');
                                },
                          height: 38,
                          backgroundColor: isEligible ? const Color(0xFFDC2626) : const Color(0xFF334155),
                          borderColor: Colors.black,
                          shadowOffset: 2.5,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isEligible ? Icons.flight_takeoff : Icons.lock, color: isEligible ? Colors.white : Colors.white60, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                isEligible ? 'BÜYÜK GÖÇÜ BAŞLAT' : 'GÖÇ KİLİTLİ',
                                style: TextStyle(
                                  color: isEligible ? Colors.white : Colors.white60,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String title,
    required String desc,
    required String yieldText,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: color, width: 1),
            ),
            child: Text(
              yieldText,
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVictoryRow(String title, bool isAchieved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isAchieved ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isAchieved ? const Color(0xFF10B981) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isAchieved ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 9.5,
                fontWeight: isAchieved ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          if (isAchieved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text('+%25 KUT', style: TextStyle(color: Color(0xFF6EE7B7), fontSize: 8, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  Widget _buildOathOption({
    required String id,
    required String title,
    required String desc,
    required bool isSelected,
  }) {
    return TactileNeoButton(
      onTap: () {
        ref.read(gameStateProvider.notifier).toggleOath(id);
      },
      height: 38,
      backgroundColor: isSelected ? const Color(0xFF3B0764) : const Color(0xFF1E293B),
      borderColor: isSelected ? const Color(0xFFA855F7) : const Color(0xFF475569),
      shadowOffset: isSelected ? 2.0 : 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            size: 16,
            color: isSelected ? const Color(0xFFC084FC) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE9D5FF) : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                ),
              ],
            ),
          ),
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
    return TactileNeoButton(
      onTap: () {
        ref.read(gameStateProvider.notifier).selectMigrationRealm(id);
      },
      height: 44,
      backgroundColor: isSelected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
      borderColor: isSelected ? color : const Color(0xFF475569),
      shadowOffset: isSelected ? 2.5 : 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? color : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'SEÇİLİ',
                style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }
}
