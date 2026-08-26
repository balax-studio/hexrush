import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/localization/game_localization.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../../domain/economy/economy_calculator.dart';
import '../../domain/models/game_state_model.dart';
import '../providers/game_state_notifier.dart';
import 'celestial_omen_hud.dart';
import 'icons/game_vector_icons.dart';
import 'season_calendar_widget.dart';
import 'tactile_neo_button.dart';
import 'transhumance_banner_widget.dart';

class TopBarHUD extends ConsumerStatefulWidget {
  final VoidCallback onOpenMarket;
  final VoidCallback onOpenTore;
  final VoidCallback onOpenSettings;

  const TopBarHUD({
    super.key,
    required this.onOpenMarket,
    required this.onOpenTore,
    required this.onOpenSettings,
  });

  @override
  ConsumerState<TopBarHUD> createState() => _TopBarHUDState();
}

class _TopBarHUDState extends ConsumerState<TopBarHUD> {
  bool _isDrawerExpanded = false;

  void _showResourceExplanation(
    BuildContext context, {
    required String title,
    required GameIconType iconType,
    required Color iconColor,
    required String description,
    required NeoBrutalistThemeData theme,
    String? currentStock,
    String? netRate,
    String? strategicHint,
  }) {
    TactileAudioService.instance.play(TactileSoundType.tap);
    HapticFeedback.lightImpact();

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) {
        return Dialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: NeoBrutalistTheme.sharpRadius,
            side: BorderSide(color: theme.border, width: 2.5),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: NeoBrutalistTheme.sharpRadius,
              boxShadow: theme.hardShadow(offset: 4.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık Çubuğu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.surfaceLight,
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: theme.border, width: 2.0),
                      ),
                      child: GameVectorIcon(type: iconType, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (currentStock != null)
                            Text(
                              'Mevcut Stok: $currentStock',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                        ],
                      ),
                    ),
                    TactileNeoButton(
                      onTap: () => Navigator.of(ctx).pop(),
                      backgroundColor: theme.slateBorder,
                      borderColor: theme.border,
                      shadowOffset: 2.0,
                      padding: const EdgeInsets.all(5),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(color: theme.border, thickness: 1.5, height: 1.5),
                const SizedBox(height: 10),

                // Net Üretim Bilgisi (Varsa)
                if (netRate != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.surfaceLight,
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: theme.slateBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed, color: Color(0xFF38BDF8), size: 14),
                        const SizedBox(width: 6),
                        const Text(
                          'Net Üretim Hızı:',
                          style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          netRate,
                          style: TextStyle(
                            color: netRate.startsWith('-') ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Açıklama Metni
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.surfaceLight,
                    borderRadius: NeoBrutalistTheme.sharpRadius,
                    border: Border.all(color: theme.slateBorder, width: 1.5),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 11.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Stratejik İpucu (Varsa)
                if (strategicHint != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: NeoBrutalistTheme.sharpRadius,
                      border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Color(0xFF10B981), size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            strategicHint,
                            style: const TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                TactileNeoButton(
                  onTap: () => Navigator.of(ctx).pop(),
                  backgroundColor: theme.primaryGold,
                  borderColor: theme.border,
                  shadowOffset: 2.0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: const Text(
                    'ANLADIM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final resources = gameState.resources;
    final lang = gameState.settings.language;
    final theme = NeoBrutalistTheme.getTheme(gameState.settings.activeThemePalette);

    final double globalMult = EconomyCalculator.getGlobalMultiplier(
      castleLevel: gameState.progression.castleLevel,
      crowns: gameState.resources.crowns,
      titles: gameState.titles,
    );

    final double seasonMult = gameState.season.isZud
        ? 0.2
        : (gameState.season.current == 'WINTER' ? 0.5 : 1.0);

    final netRates = EconomyCalculator.calculateNetRates(
      tiles: gameState.tiles.values,
      globalMultiplier: globalMult,
      seasonMultiplier: seasonMult * gameState.frenzyMultiplier,
      shrineMultiplier: gameState.shrineMultiplier,
      tileMap: gameState.tiles,
      season: gameState.season.current,
      isZud: gameState.season.isZud,
    );

    final int nextCastleLvl = gameState.progression.castleLevel + 1;
    final castleCosts = EconomyCalculator.getCastleUpgradeCost(nextCastleLvl);
    final bool canUpgradeCastle = resources.food >= (castleCosts['food'] ?? double.infinity) &&
        resources.wood >= (castleCosts['wood'] ?? 0);

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(
          bottom: BorderSide(color: theme.border, width: 2.5),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana Kaynak Satırı
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ResourcePulseChip(
                  type: GameIconType.food,
                  value: resources.food,
                  color: const Color(0xFFFBBF24),
                  rate: netRates.food,
                  theme: theme,
                  onTap: () => _showResourceExplanation(
                    context,
                    title: 'GIDA (İAŞE)',
                    iconType: GameIconType.food,
                    iconColor: const Color(0xFFFBBF24),
                    currentStock: resources.food.toStringAsFixed(1),
                    netRate: '${netRates.food >= 0 ? '+' : ''}${netRates.food.toStringAsFixed(1)}/saniye',
                    description: 'Kağanlığın temel besin kaynağı. Yeni altıgen toprakları fethetmek ve oba halkını doyurmak için harcanır.',
                    strategicHint: 'Tarlalar, Bozkır Göçer İaşesi doktrini ve Kağan Otağı\'ndan toplanır.',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 6),
                ResourcePulseChip(
                  type: GameIconType.wood,
                  value: resources.wood,
                  color: const Color(0xFFD97706),
                  rate: netRates.wood,
                  theme: theme,
                  onTap: () => _showResourceExplanation(
                    context,
                    title: 'ODUN',
                    iconType: GameIconType.wood,
                    iconColor: const Color(0xFFD97706),
                    currentStock: resources.wood.toStringAsFixed(1),
                    netRate: '${netRates.wood >= 0 ? '+' : ''}${netRates.wood.toStringAsFixed(1)}/saniye',
                    description: 'İnşaat, atölye üretimi ve kış aylarında donan karoları ısıtmanın ana yakıtı.',
                    strategicHint: 'Oduncu kulübelerinden toplanır. Kalas ve mobilya üretimi için harcanır.',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 6),
                if (resources.stone > 0 || gameState.progression.castleLevel >= 2) ...[
                  ResourcePulseChip(
                    type: GameIconType.stone,
                    value: resources.stone,
                    color: const Color(0xFF94A3B8),
                    rate: netRates.stone,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'TAŞ',
                      iconType: GameIconType.stone,
                      iconColor: const Color(0xFF94A3B8),
                      currentStock: resources.stone.toStringAsFixed(1),
                      netRate: '${netRates.stone >= 0 ? '+' : ''}${netRates.stone.toStringAsFixed(1)}/saniye',
                      description: 'Gelişmiş binalar, taş fırınlar ve anıtsal harikalar inşa etmek için gereklidir.',
                      strategicHint: 'Dağ maden ocaklarından çıkarılır ve pazardan takas edilir.',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                ResourcePulseChip(
                  type: GameIconType.crown,
                  value: resources.crowns.toDouble(),
                  color: const Color(0xFFFFD700),
                  isInt: true,
                  theme: theme,
                  onTap: () => _showResourceExplanation(
                    context,
                    title: 'ŞAN (HÜKÜMDAR İTİBARI)',
                    iconType: GameIconType.crown,
                    iconColor: const Color(0xFFFFD700),
                    currentStock: '${resources.crowns} Şan',
                    description: 'Görevleri tamamlayarak ve fetihler yaparak kazanılan itibar puanı.',
                    strategicHint: 'Töre Meclisinde yeni doktrin kartlarını kabul etmek ve yetenek yükseltmek için kullanılır.',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 6),
                _buildLandChip(
                  gameState.progression.ownedCount,
                  theme,
                  onTap: () => _showResourceExplanation(
                    context,
                    title: 'HÜKÜM SÜRÜLEN TOPRAKLAR',
                    iconType: GameIconType.land,
                    iconColor: const Color(0xFF10B981),
                    currentStock: '${gameState.progression.ownedCount} Altıgen',
                    description: 'Egemenliğiniz altındaki karoların sayısı. Toprak sayısı arttıkça yeni yapay sinerjiler ve kaynaklar açılır.',
                    strategicHint: 'Bitişik karolara tıklayıp Gıda harcayarak yeni topraklar fethedin.',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),

                // İkincil kaynak çekmecesi butonu
                _buildIconButton(
                  icon: Icon(
                    _isDrawerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: _isDrawerExpanded ? theme.primaryGold : Colors.white,
                    size: 16,
                  ),
                  backgroundColor: _isDrawerExpanded ? theme.surfaceLight : theme.slateBorder,
                  borderColor: _isDrawerExpanded ? theme.primaryGold : theme.border,
                  onPressed: () {
                    setState(() {
                      _isDrawerExpanded = !_isDrawerExpanded;
                    });
                  },
                  tooltip: 'Genişletilmiş Envanter Çekmecesi',
                ),
                const SizedBox(width: 5),

                // Pazar Butonu
                _buildIconButton(
                  icon: const GameVectorIcon(type: GameIconType.market, size: 15),
                  onPressed: widget.onOpenMarket,
                  tooltip: GameLocalization.get('market_title', lang: lang),
                  backgroundColor: theme.slateBorder,
                  borderColor: theme.border,
                ),
                const SizedBox(width: 5),

                // Töre Butonu
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildIconButton(
                      icon: const GameVectorIcon(type: GameIconType.tore, size: 15),
                      onPressed: widget.onOpenTore,
                      tooltip: 'Töre & Kurultay Meclisi',
                      backgroundColor: theme.slateBorder,
                      borderColor: theme.border,
                    ),
                    if (resources.crowns > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.primaryGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.border, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 5),

                // Kompakt Frenzy / Çılgınlık Butonu
                TactileNeoButton(
                  onTap: () {
                    ref.read(gameStateProvider.notifier).activateFrenzy();
                  },
                  backgroundColor: gameState.frenzyTimer > 0
                      ? const Color(0xFFEF4444)
                      : theme.accentColor,
                  borderColor: theme.border,
                  shadowColor: theme.shadowColor,
                  shadowOffset: 2.0,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const GameVectorIcon(type: GameIconType.frenzy, size: 13, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        gameState.frenzyTimer > 0
                            ? '${gameState.frenzyTimer.toInt()}s'
                            : '10x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),

                // Ayarlar butonu
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildIconButton(
                      icon: const GameVectorIcon(type: GameIconType.settings, size: 15),
                      onPressed: widget.onOpenSettings,
                      tooltip: 'Ayarlar',
                      backgroundColor: theme.slateBorder,
                      borderColor: theme.border,
                    ),
                    if (gameState.settings.notifications.storageFullAlert ||
                        gameState.settings.notifications.seasonChangeAlert ||
                        gameState.settings.notifications.questCompletedAlert ||
                        gameState.settings.notifications.castleUpgradeReadyAlert)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(1.5),
                            border: Border.all(color: const Color(0xFF020617), width: 1.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Genişletilmiş Kaynak Çekmecesi (Un, Kereste, Ekmek, Mobilya, Demir)
          if (_isDrawerExpanded) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ResourcePulseChip(
                    type: GameIconType.flour,
                    value: resources.flour,
                    color: const Color(0xFFFEF08A),
                    rate: netRates.flour,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'UN (İŞLENMİŞ GIDA)',
                      iconType: GameIconType.flour,
                      iconColor: const Color(0xFFFEF08A),
                      currentStock: resources.flour.toStringAsFixed(1),
                      netRate: '${netRates.flour >= 0 ? '+' : ''}${netRates.flour.toStringAsFixed(1)}/saniye',
                      description: 'Değirmende mısırdan öğütülen hammadde. Taş fırında ekmek pişirmek ve pazarda takas için kullanılır.',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.plank,
                    value: resources.plank,
                    color: const Color(0xFFD97706),
                    rate: netRates.plank,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'KERESTE (KALAS)',
                      iconType: GameIconType.plank,
                      iconColor: const Color(0xFFD97706),
                      currentStock: resources.plank.toStringAsFixed(1),
                      netRate: '${netRates.plank >= 0 ? '+' : ''}${netRates.plank.toStringAsFixed(1)}/saniye',
                      description: 'Kereste fabrikasında kütüklerden biçilen tahtalar. Mobilya ve gelişmiş yapılar için elzemdir.',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.bread,
                    value: resources.bread,
                    color: const Color(0xFFF59E0B),
                    rate: netRates.bread,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'EKMEK (İŞLENMİŞ BESİN)',
                      iconType: GameIconType.bread,
                      iconColor: const Color(0xFFF59E0B),
                      currentStock: resources.bread.toStringAsFixed(1),
                      netRate: '${netRates.bread >= 0 ? '+' : ''}${netRates.bread.toStringAsFixed(1)}/saniye',
                      description: 'Taş köz fırınında un ve gıda harcanarak pişirilen yüksek besleyici gıda. Otağ geliştirmeleri için gereklidir.',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.furniture,
                    value: resources.furniture,
                    color: const Color(0xFFB45309),
                    rate: netRates.furniture,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'AHŞAP İŞLEME (TİCARET MALI)',
                      iconType: GameIconType.furniture,
                      iconColor: const Color(0xFFB45309),
                      currentStock: resources.furniture.toStringAsFixed(1),
                      netRate: '${netRates.furniture >= 0 ? '+' : ''}${netRates.furniture.toStringAsFixed(1)}/saniye',
                      description: 'Marangoz otağında keresteden üretilir. Yüksek pazar takas değerine sahiptir.',
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ResourcePulseChip(
                    type: GameIconType.iron,
                    value: resources.iron,
                    color: const Color(0xFFCBD5E1),
                    rate: netRates.iron,
                    theme: theme,
                    onTap: () => _showResourceExplanation(
                      context,
                      title: 'DEMİR CEVHERİ',
                      iconType: GameIconType.iron,
                      iconColor: const Color(0xFFCBD5E1),
                      currentStock: resources.iron.toStringAsFixed(1),
                      netRate: '${netRates.iron >= 0 ? '+' : ''}${netRates.iron.toStringAsFixed(1)}/saniye',
                      description: 'Madenlerden çıkarılan dayanıklı metal. Ağır donanım, kuleler ve anıtlar için kullanılır.',
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 6),

          // Sezon & Şato Hız Bilgi Çubuğu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSeasonBadge(
                    gameState.season,
                    lang,
                    theme,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (ctx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SeasonCalendarWidget(
                            season: gameState.season,
                            language: lang,
                            onClose: () => Navigator.of(ctx).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 6),
                  const CelestialOmenHud(),
                  const SizedBox(width: 6),
                  const TranshumanceBannerWidget(),
                  if (gameState.season.isZud) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: theme.border, width: 1.5),
                        boxShadow: theme.hardShadowSmall,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameVectorIcon(type: GameIconType.zud, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'ZUD AFETİ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              GestureDetector(
                onTap: () => _showResourceExplanation(
                  context,
                  title: 'KAĞAN OTAĞI & KÜRESEL BONUS',
                  iconType: GameIconType.crown,
                  iconColor: theme.primaryGold,
                  currentStock: 'Kağan Otağı Seviye ${gameState.progression.castleLevel}',
                  description: 'Kağanlığınızın ana yönetim merkezi. Otağı büyüttükçe tüm obanın küresel üretim hızı katlanır, yeni yapılar ve kurultay yuvaları açılır.',
                  strategicHint: 'Otağı merkez karoya dokunarak gerekli erzak ve malzemelerle büyütebilirsiniz.',
                  theme: theme,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.surfaceLight,
                        borderRadius: NeoBrutalistTheme.sharpRadius,
                        border: Border.all(color: theme.border, width: 1.8),
                        boxShadow: theme.hardShadowSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OTAĞ LV.${gameState.progression.castleLevel}',
                            style: TextStyle(
                              color: theme.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              '+${((globalMult - 1.0) * 100).toInt()}% HIZ',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (canUpgradeCastle)
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD97706),
                            borderRadius: BorderRadius.circular(1.5),
                            border: Border.all(color: const Color(0xFF020617), width: 1.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Mevsim İlerleme Çubuğu (Season Progress Micro-Bar)
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 3,
              width: double.infinity,
              color: theme.slateBorder,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: (gameState.season.timer / 300.0).clamp(0.0, 1.0),
                  child: Container(
                    color: _getSeasonColor(gameState.season),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Color _getSeasonColor(SeasonModel season) {
    if (season.isZud) return const Color(0xFFEF4444);
    if (season.current == 'SUMMER') return const Color(0xFFFBBF24);
    if (season.current == 'AUTUMN') return const Color(0xFFEA580C);
    if (season.current == 'WINTER') return const Color(0xFF38BDF8);
    return const Color(0xFF4ADE80);
  }

  Widget _buildIconButton({
    required Widget icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color backgroundColor = const Color(0xFF334155),
    Color borderColor = Colors.black,
  }) {
    return TactileNeoButton(
      onTap: onPressed,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      shadowOffset: 2.0,
      padding: const EdgeInsets.all(6),
      child: Tooltip(
        message: tooltip,
        child: icon,
      ),
    );
  }

  Widget _buildLandChip(int count, NeoBrutalistThemeData theme, {VoidCallback? onTap}) {
    final lang = ref.watch(gameStateProvider).settings.language;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: theme.surfaceLight,
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: theme.border, width: 1.8),
          boxShadow: theme.hardShadowSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameVectorIcon(type: GameIconType.land, size: 14),
            const SizedBox(width: 5),
            Text(
              GameLocalization.get('land', lang: lang).toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeasonBadge(dynamic season, String lang, NeoBrutalistThemeData theme, {VoidCallback? onTap}) {
    GameIconType iconType = GameIconType.spring;
    String name = GameLocalization.get('spring', lang: lang);
    Color color = const Color(0xFF4ADE80);

    if (season.current == 'SUMMER') {
      iconType = GameIconType.summer;
      name = GameLocalization.get('summer', lang: lang);
      color = const Color(0xFFFBBF24);
    } else if (season.current == 'AUTUMN') {
      iconType = GameIconType.autumn;
      name = GameLocalization.get('autumn', lang: lang);
      color = const Color(0xFFEA580C);
    } else if (season.current == 'WINTER') {
      iconType = GameIconType.winter;
      name = GameLocalization.get('winter', lang: lang);
      color = const Color(0xFF38BDF8);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.surfaceLight,
          borderRadius: NeoBrutalistTheme.sharpRadius,
          border: Border.all(color: theme.border, width: 1.8),
          boxShadow: theme.hardShadowSmall,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameVectorIcon(type: iconType, size: 13),
            const SizedBox(width: 5),
            Text(
              '$name · ${GameLocalization.get('year', lang: lang)} ${season.year}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kaynak Değişim Nabzı Animasyonlu Çip
class ResourcePulseChip extends StatefulWidget {
  final GameIconType type;
  final double value;
  final Color color;
  final bool isInt;
  final double? rate;
  final VoidCallback? onTap;
  final NeoBrutalistThemeData? theme;

  const ResourcePulseChip({
    super.key,
    required this.type,
    required this.value,
    required this.color,
    this.isInt = false,
    this.rate,
    this.onTap,
    this.theme,
  });

  @override
  State<ResourcePulseChip> createState() => _ResourcePulseChipState();
}

class _ResourcePulseChipState extends State<ResourcePulseChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  double _lastValue = 0;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value;
    final defaultBg = widget.theme?.surfaceLight ?? const Color(0xFF0F172A);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _colorAnimation = ColorTween(
      begin: defaultBg,
      end: defaultBg,
    ).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant ResourcePulseChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final defaultBg = widget.theme?.surfaceLight ?? const Color(0xFF0F172A);
    // Pasif saniyelik mikro artışlarda CPU döngüsünü korumak için sadece belirgin (>= 10) değişimlerde darbe animasyonu başlat
    if ((widget.value - oldWidget.value).abs() >= 10.0) {
      final bool increased = widget.value > oldWidget.value;
      _lastValue = widget.value;
      _colorAnimation = ColorTween(
        begin: increased ? (widget.theme?.primaryGold.withValues(alpha: 0.45) ?? const Color(0xFF78350F)) : const Color(0xFF7F1D1D),
        end: defaultBg,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRate = widget.rate != null && widget.rate!.abs() >= 0.01;
    final bool isPositive = widget.rate != null && widget.rate! > 0;
    final theme = widget.theme ?? NeoBrutalistTheme.basaltTheme;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: _controller.isAnimating ? (_colorAnimation.value ?? theme.surfaceLight) : theme.surfaceLight,
                borderRadius: NeoBrutalistTheme.sharpRadius,
                border: Border.all(
                  color: _controller.isAnimating
                      ? (widget.value >= _lastValue ? theme.primaryGold : const Color(0xFFEF4444))
                      : theme.border,
                  width: 1.8,
                ),
                boxShadow: theme.hardShadowSmall,
              ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GameVectorIcon(type: widget.type, size: 14),
                const SizedBox(width: 5),
                Text(
                  widget.isInt ? widget.value.toInt().toString() : widget.value.toStringAsFixed(1),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                if (hasRate) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? '+' : ''}${widget.rate!.toStringAsFixed(1)}/s',
                    style: TextStyle(
                      color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    ),
    );
  }
}
