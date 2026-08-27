import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/models/doctrine_model.dart';
import '../../domain/models/game_state.dart';
import '../providers/game_state_notifier.dart';
import 'icons/game_vector_icons.dart';
import 'tactile_neo_button.dart';

class ToreDialog extends ConsumerStatefulWidget {
  const ToreDialog({super.key});

  @override
  ConsumerState<ToreDialog> createState() => _ToreDialogState();
}

class _ToreDialogState extends ConsumerState<ToreDialog> {
  int _selectedTab = 0; // 0: Doktrinler, 1: Yetenekler, 2: Unvanlar

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final crowns = gameState.resources.crowns;
    final notifier = ref.read(gameStateProvider.notifier);
    final lang = gameState.settings.language;

    return Dialog(
      backgroundColor: NeoBrutalistTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: NeoBrutalistTheme.standardRadius,
        side: BorderSide(color: Colors.black, width: 2.5),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 620, maxWidth: 540),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NeoBrutalistTheme.surface,
          borderRadius: NeoBrutalistTheme.standardRadius,
          boxShadow: NeoBrutalistTheme.hardShadow(offset: 4.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık Çubuğu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    GameVectorIcon(type: GameIconType.tore, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'TÖRE & KURULTAY MECLİSİ',
                      style: NeoBrutalistTheme.fontHeaderMonolith,
                    ),
                  ],
                ),
                TactileNeoButton(
                  onTap: () => Navigator.of(context).pop(),
                  backgroundColor: const Color(0xFF334155),
                  shadowOffset: 2.0,
                  height: 28,
                  width: 28,
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: const Center(child: Icon(Icons.close, color: Colors.white, size: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Şan Sayacı ve Sekmeler
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: const Color(0xFF334155), width: 1.5),
                    boxShadow: NeoBrutalistTheme.hardShadowSmall,
                  ),
                  child: Row(
                    children: [
                      const GameVectorIcon(type: GameIconType.crown, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'ŞAN: $crowns',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    children: [
                      _buildTabButton(0, 'DOKTRİNLER', GameIconType.tore),
                      const SizedBox(width: 4),
                      _buildTabButton(1, 'YETENEKLER', GameIconType.frenzy),
                      const SizedBox(width: 4),
                      _buildTabButton(2, 'UNVANLAR', GameIconType.crown),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.black, thickness: 1.5, height: 1.5),
            const SizedBox(height: 10),

            // Sekme İçeriği
            Expanded(
              child: _selectedTab == 0
                  ? _buildDoctrinesTab(context, gameState, notifier, lang)
                  : (_selectedTab == 1
                      ? _buildTalentsTab(context, gameState, notifier, lang)
                      : _buildTitlesTab(context, gameState, notifier, lang)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, GameIconType icon) {
    final bool isSelected = _selectedTab == index;
    return Expanded(
      child: TactileNeoButton(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        backgroundColor: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF1E293B),
        borderColor: isSelected ? Colors.black : const Color(0xFF475569),
        shadowOffset: isSelected ? 2.0 : 0.0,
        height: 30,
        padding: EdgeInsets.zero,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GameVectorIcon(type: icon, size: 11, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEKME 1: TÖRE DOKTRİNLERİ (CIVIC DOCTRINES) ---
  Widget _buildDoctrinesTab(BuildContext context, GameState gameState, GameStateNotifier notifier, String lang) {
    final Map<DoctrineSlotType, String?> slots = gameState.activeDoctrineSlots;
    final List<DoctrineCardModel> doctrines = gameState.doctrines;
    final int castleLvl = gameState.progression.castleLevel;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YÜRÜRLÜKTEKİ TÖRE YUVALARI:',
            style: TextStyle(
              color: Color(0xFFFFC700),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),

          // 4 Yuva Izgarası
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              _buildSlotCard(
                DoctrineSlotType.economic,
                'İKTİSADİ',
                slots[DoctrineSlotType.economic],
                doctrines,
                notifier,
                true,
              ),
              _buildSlotCard(
                DoctrineSlotType.military,
                'ASKERİ',
                slots[DoctrineSlotType.military],
                doctrines,
                notifier,
                true,
              ),
              _buildSlotCard(
                DoctrineSlotType.nomadic,
                'BOZKIR',
                slots[DoctrineSlotType.nomadic],
                doctrines,
                notifier,
                true,
              ),
              _buildSlotCard(
                DoctrineSlotType.wildcard,
                'KAĞANLIK (JOKER)',
                slots[DoctrineSlotType.wildcard],
                doctrines,
                notifier,
                castleLvl >= 12,
                lockMsg: 'Otağ Lv.12 Gerekli',
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.black, thickness: 1.0),
          const SizedBox(height: 8),

          const Text(
            'MECLİSTEKİ TÖRE KARTLARI:',
            style: TextStyle(
              color: Color(0xFFFFC700),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),

          ...doctrines.map((doc) {
            final bool isUnlocked = doc.isUnlocked;
            final bool isEquipped = slots.values.contains(doc.id);
            final bool canUnlock = gameState.resources.crowns >= doc.costCrowns && castleLvl >= doc.unlockCastleLevel;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEquipped
                    ? const Color(0xFF064E3B)
                    : (isUnlocked ? const Color(0xFF0F172A) : const Color(0xFF020617)),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFF10B981)
                      : (isUnlocked ? const Color(0xFF334155) : const Color(0xFF1E293B)),
                  width: 1.8,
                ),
                boxShadow: NeoBrutalistTheme.hardShadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSlotTypeColor(doc.slotType),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                _getSlotTypeName(doc.slotType),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                doc.titleTr,
                                style: TextStyle(
                                  color: isEquipped ? const Color(0xFF6EE7B7) : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doc.descriptionTr,
                          style: TextStyle(
                            color: isUnlocked ? Colors.white70 : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isEquipped)
                    TactileNeoButton(
                      onTap: () {
                        // Yuvasından çıkar
                        for (final entry in slots.entries) {
                          if (entry.value == doc.id) {
                            notifier.equipDoctrine(entry.key, null);
                            break;
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF10B981),
                      borderColor: Colors.black,
                      shadowOffset: 2.0,
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        'ÇIKAR',
                        style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    )
                  else if (isUnlocked)
                    TactileNeoButton(
                      onTap: () {
                        // Uygun yuvaya veya jokere tak
                        if (doc.slotType == DoctrineSlotType.wildcard || slots[doc.slotType] != null) {
                          if (castleLvl >= 12 && slots[DoctrineSlotType.wildcard] == null) {
                            notifier.equipDoctrine(DoctrineSlotType.wildcard, doc.id);
                            return;
                          }
                        }
                        notifier.equipDoctrine(doc.slotType, doc.id);
                      },
                      backgroundColor: const Color(0xFF8B5CF6),
                      borderColor: Colors.black,
                      shadowColor: const Color(0xFF4C1D95),
                      shadowOffset: 2.0,
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: const Text(
                        'YUVAYA TAK',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    )
                  else
                    TactileNeoButton(
                      onTap: canUnlock ? () => notifier.unlockDoctrine(doc.id) : null,
                      isEnabled: canUnlock,
                      backgroundColor: const Color(0xFFFFC700),
                      borderColor: Colors.black,
                      shadowColor: const Color(0xFF78350F),
                      shadowOffset: 2.0,
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      child: Text(
                        castleLvl < doc.unlockCastleLevel
                            ? 'ŞATO LV.${doc.unlockCastleLevel}'
                            : 'KABUL ET (${doc.costCrowns} ŞAN)',
                        style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlotCard(
    DoctrineSlotType slotType,
    String slotName,
    String? equippedId,
    List<DoctrineCardModel> allDoctrines,
    GameStateNotifier notifier,
    bool isUnlocked, {
    String? lockMsg,
  }) {
    final DoctrineCardModel? equipped = equippedId != null
        ? allDoctrines.where((d) => d.id == equippedId).firstOrNull
        : null;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: !isUnlocked
            ? const Color(0xFF020617)
            : (equipped != null ? const Color(0xFF064E3B) : const Color(0xFF0F172A)),
        borderRadius: NeoBrutalistTheme.sharpRadius,
        border: Border.all(
          color: !isUnlocked
              ? const Color(0xFF1E293B)
              : (equipped != null ? const Color(0xFF10B981) : const Color(0xFF334155)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                slotName,
                style: TextStyle(
                  color: _getSlotTypeColor(slotType),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (equipped != null)
                GestureDetector(
                  onTap: () => notifier.equipDoctrine(slotType, null),
                  child: const Icon(Icons.close, size: 12, color: Colors.white70),
                ),
            ],
          ),
          if (!isUnlocked)
            Text(
              lockMsg ?? 'KİLİTLİ',
              style: const TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w700),
            )
          else if (equipped != null)
            Text(
              equipped.titleTr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          else
            const Text(
              '[ BOŞ YUVA ]',
              style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }

  Color _getSlotTypeColor(DoctrineSlotType type) {
    switch (type) {
      case DoctrineSlotType.economic:
        return const Color(0xFF10B981);
      case DoctrineSlotType.military:
        return const Color(0xFFEF4444);
      case DoctrineSlotType.nomadic:
        return const Color(0xFFF59E0B);
      case DoctrineSlotType.wildcard:
        return const Color(0xFF8B5CF6);
    }
  }

  String _getSlotTypeName(DoctrineSlotType type) {
    switch (type) {
      case DoctrineSlotType.economic:
        return 'İKTİSAT';
      case DoctrineSlotType.military:
        return 'ASKERİ';
      case DoctrineSlotType.nomadic:
        return 'BOZKIR';
      case DoctrineSlotType.wildcard:
        return 'JOKER';
    }
  }

  // --- SEKME 2: KADİM YETENEKLER ---
  Widget _buildTalentsTab(BuildContext context, GameState gameState, GameStateNotifier notifier, String lang) {
    final crowns = gameState.resources.crowns;
    final tore = gameState.toreTalents;

    final int rainLvl = (tore['gokTengri']?['rainBlessing'] as num? ?? 0).toInt();
    final int silkLvl = (tore['tonyukuk']?['silkNetwork'] as num? ?? 0).toInt();
    final int roadsLvl = (tore['tonyukuk']?['pavedRoads'] as num? ?? 0).toInt();
    final int braveLvl = (tore['kulTigin']?['braveHeart'] as num? ?? 0).toInt();

    final talents = [
      {
        'branch': 'gokTengri',
        'key': 'rainBlessing',
        'icon': GameIconType.food,
        'title': 'GÖK TENGRİ: YAĞMUR BEREKETİ (LV.$rainLvl)',
        'desc': 'Tüm krallık üretim hızını her seviyede +%5 artırır.',
        'cost': rainLvl + 1,
        'lvl': rainLvl,
      },
      {
        'branch': 'tonyukuk',
        'key': 'silkNetwork',
        'icon': GameIconType.tore,
        'title': 'TONYUKUK: İPEK AĞI (LV.$silkLvl)',
        'desc': 'Üretim çarpanını her seviyede +%4 artırır.',
        'cost': silkLvl + 1,
        'lvl': silkLvl,
      },
      {
        'branch': 'tonyukuk',
        'key': 'pavedRoads',
        'icon': GameIconType.wood,
        'title': 'TONYUKUK: TAŞ YOLLAR (LV.$roadsLvl)',
        'desc': 'İşçi taşıma hızını her seviyede +%8 artırır.',
        'cost': roadsLvl + 1,
        'lvl': roadsLvl,
      },
      {
        'branch': 'kulTigin',
        'key': 'braveHeart',
        'icon': GameIconType.frenzy,
        'title': 'KÜL TİGİN: CESUR YÜREK (LV.$braveLvl)',
        'desc': 'Toprak fethetme gıda maliyetini her seviyede %5 düşürür.',
        'cost': braveLvl + 1,
        'lvl': braveLvl,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TÖRE AĞACI (KALICI YÜKSELTMELER):',
            style: TextStyle(
              color: Color(0xFFFFC700),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...talents.map((t) {
            final int cost = t['cost'] as int;
            final bool canAfford = crowns >= cost;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(
                  color: canAfford ? const Color(0xFF8B5CF6) : const Color(0xFF334155),
                  width: 1.8,
                ),
                boxShadow: NeoBrutalistTheme.hardShadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GameVectorIcon(type: t['icon'] as GameIconType, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t['title'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t['desc'] as String,
                          style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TactileNeoButton(
                    onTap: canAfford
                        ? () => notifier.upgradeToreTalent(
                              t['branch'] as String,
                              t['key'] as String,
                              cost,
                            )
                        : null,
                    isEnabled: canAfford,
                    backgroundColor: const Color(0xFF8B5CF6),
                    borderColor: Colors.black,
                    shadowColor: const Color(0xFF4C1D95),
                    shadowOffset: 2.0,
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    soundType: TactileSoundType.upgrade,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GameVectorIcon(type: GameIconType.crown, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$cost ŞAN',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- SEKME 3: UNVANLAR & BAŞARIMLAR (Dinamik Tema Bağlantılı) ---
  Widget _buildTitlesTab(BuildContext context, GameState gameState, GameStateNotifier notifier, String lang) {
    final titles = gameState.titles;
    final activeTitle = gameState.settings.activeTitle;

    final titleList = [
      {
        'key': 'nomad',
        'icon': GameIconType.tore,
        'title': 'BOZKIR GÖÇERİ',
        'palette': 'KADİM BAZALT TEMASI',
        'desc': 'Bozkırın kadim topraklarına adım atmış özgür göçer.',
        'inscription': 'Çadırını kuran, göğün altında ateşini yakan her göçerin temel hakkı.',
        'owned': true,
        'canClaim': false,
      },
      {
        'key': 'conqueror',
        'icon': GameIconType.land,
        'title': 'TOPRAK FATİHİ',
        'palette': 'KIZIL KURGAN TEMASI',
        'desc': '15 Toprak gerektirir. (Fetih Maliyeti -%10)',
        'inscription': 'Bozkırın ufuklarını yurt tutan, sınırları aşarak çadırını kuran fatihlerin izi.',
        'owned': titles['conqueror'] == true,
        'canClaim': gameState.progression.ownedCount >= 15,
      },
      {
        'key': 'merchant',
        'icon': GameIconType.market,
        'title': 'İPEK YOLU TÜCCARI',
        'palette': 'ALTAY YEŞİMİ TEMASI',
        'desc': '50 Un ve 50 Kereste gerektirir. (Pazar Gelirleri +%20)',
        'inscription': 'Kervan yollarını bağlayan, un ve keresteyi berekete çeviren usta tacirlerin kaydı.',
        'owned': titles['merchant'] == true,
        'canClaim': gameState.resources.flour >= 50 && gameState.resources.plank >= 50,
      },
      {
        'key': 'zudMaster',
        'icon': GameIconType.winter,
        'title': 'ZUD FATİHİ',
        'palette': 'GÖK TENGRİ TEMASI',
        'desc': 'Kış Yılı 2\'ye ulaşmayı gerektirir. (Kış Kayıpları -%20)',
        'inscription': 'Dondurucu boranları ve kara kışları dize getiren, ocağı hiç sönmeyen bilgelerin anısı.',
        'owned': titles['zudMaster'] == true,
        'canClaim': gameState.season.year >= 2,
      },
      {
        'key': 'khagan',
        'icon': GameIconType.crown,
        'title': 'BÜYÜK KAĞAN',
        'palette': 'ALTIN KAĞANLIK TEMASI',
        'desc': 'Kağan Otağı Lv.4 ve 10 Toprak gerektirir. (+%15 Küresel Hız)',
        'inscription': 'On boyu birleştiren, kutlu otağı kuran ve bozkıra nizam veren ulu hükümdar yazıtı.',
        'owned': titles['khagan'] == true,
        'canClaim': gameState.progression.castleLevel >= 4 && gameState.progression.ownedCount >= 10,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOZKIR KAĞANLIK UNVANLARI & DİNAMİK TEMALAR:',
            style: TextStyle(
              color: Color(0xFFFFC700),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...titleList.map((t) {
            final String key = t['key'] as String;
            final bool isOwned = t['owned'] as bool;
            final bool canClaim = t['canClaim'] as bool;
            final bool isEquipped = (activeTitle == key) || (activeTitle.isEmpty && key == 'nomad');

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEquipped
                    ? const Color(0xFF1E1B4B)
                    : (isOwned ? const Color(0xFF064E3B) : const Color(0xFF0F172A)),
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(
                  color: isEquipped
                      ? const Color(0xFFA855F7)
                      : (isOwned ? const Color(0xFF10B981) : const Color(0xFF334155)),
                  width: 1.8,
                ),
                boxShadow: NeoBrutalistTheme.hardShadowSmall,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GameVectorIcon(type: t['icon'] as GameIconType, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                t['title'] as String,
                                style: TextStyle(
                                  color: isEquipped
                                      ? const Color(0xFFC084FC)
                                      : (isOwned ? const Color(0xFF10B981) : Colors.white),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF020617),
                            borderRadius: NeoBrutalistTheme.sharpRadius,
                            border: Border.all(color: const Color(0xFF334155), width: 1.0),
                          ),
                          child: Text(
                            t['palette'] as String,
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t['desc'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                        if (t['inscription'] != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            t['inscription'] as String,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 9,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isEquipped)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: NeoBrutalistTheme.hardShadowSmall,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 12, color: Colors.black),
                          SizedBox(width: 4),
                          Text(
                            'KUŞANILDI',
                            style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    )
                  else if (isOwned)
                    TactileNeoButton(
                      onTap: () => notifier.equipTitle(key),
                      backgroundColor: const Color(0xFF38BDF8),
                      borderColor: Colors.black,
                      shadowColor: const Color(0xFF0369A1),
                      shadowOffset: 2.0,
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.center,
                      soundType: TactileSoundType.reward,
                      child: const Text(
                        'TEMAYI KUŞAN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  else
                    TactileNeoButton(
                      onTap: canClaim ? () => notifier.claimTitle(key) : null,
                      isEnabled: canClaim,
                      backgroundColor: const Color(0xFFFFC700),
                      borderColor: Colors.black,
                      shadowColor: const Color(0xFF78350F),
                      shadowOffset: 2.0,
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      soundType: TactileSoundType.reward,
                      child: Text(
                        GameLocalization.get('claim_title', lang: lang).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
