import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audio/tactile_audio_service.dart';
import '../../core/theme/neo_brutalist_theme.dart';
import '../providers/game_state_notifier.dart';
import 'tactile_neo_button.dart';

class IntroStoryScene {
  final String titleTr;
  final String titleEn;
  final String chapterTr;
  final String chapterEn;
  final String narrativeTr;
  final String narrativeEn;
  final String quoteTr;
  final String quoteEn;
  final IconData icon;
  final Color themeColor;

  const IntroStoryScene({
    required this.titleTr,
    required this.titleEn,
    required this.chapterTr,
    required this.chapterEn,
    required this.narrativeTr,
    required this.narrativeEn,
    required this.quoteTr,
    required this.quoteEn,
    required this.icon,
    required this.themeColor,
  });
}

class IntroStoryDialog extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;

  const IntroStoryDialog({super.key, this.onComplete});

  static Future<void> show(BuildContext context, {VoidCallback? onComplete}) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'IntroStoryDialog',
      barrierColor: const Color(0xE6020617),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) => IntroStoryDialog(onComplete: onComplete),
      transitionBuilder: (context, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<IntroStoryDialog> createState() => _IntroStoryDialogState();
}

class _IntroStoryDialogState extends ConsumerState<IntroStoryDialog> {
  int _currentPage = 0;
  late final PageController _pageController;

  static const List<IntroStoryScene> _scenes = [
    IntroStoryScene(
      chapterTr: 'BÖLÜM I',
      chapterEn: 'CHAPTER I',
      titleTr: 'ŞAFAK VE İLK OCAK',
      titleEn: 'DAWN OF THE STEPPE',
      narrativeTr:
          'Uçsuz bucaksız Avrasya bozkırlarında rüzgar dindi. Kadim boylar kutlu bir önderin sancağı altında toplanmayı bekliyor. Ataların buyruğu açıktır: Çadırını kur, ocağını yak ve toprağı dinle. Çayırlardan biçilen ilk başak ve ormanlardan yontulan ilk kereste, yükselecek kutlu kağanlığın ilk adımıdır.',
      narrativeEn:
          'The wind stills across the vast Eurasian steppe. Nomadic tribes await unification beneath the sacred banner of a destined Khagan. Pitch your tent, kindle the ancestral hearth, and heed the earth. The first wheat harvested and logs hewn shall lay the foundations of an eternal empire.',
      quoteTr: '"Üstte mavi gök, altta yağız yer kılındıkta, ikisi arasında insanoğlu kılınmış..."',
      quoteEn: '"When the blue sky above and the dark earth below were fashioned, between them were fashioned the sons of men..."',
      icon: Icons.wb_sunny,
      themeColor: Color(0xFFF59E0B),
    ),
    IntroStoryScene(
      chapterTr: 'BÖLÜM II',
      chapterEn: 'CHAPTER II',
      titleTr: 'BENGÜ TAŞ VE KADİM TÖRE',
      titleEn: 'RUNIC STELE & SACRED LAW',
      narrativeTr:
          'Sislerin ardında dikilen Orhun yazıtları, göğe ve yere kazınmış töreyi fısıldıyor. Bilgelik olmadan güç zayıftır. Rünik yazıt taşları yükseldikçe bozkırın kadim sırları uyanır; kervan hatları kurulur, nadasa bırakılan toprak nefes alır ve 12 Hayvanlı Göksel Takvim kutlu seferlere rehberlik eder.',
      narrativeEn:
          'Rising through mountain mists, the Orkhon runic steles whisper the sacred laws carved into stone. Strength without wisdom falters. Erect runic monuments to awaken ancient steppe lore; weave caravan trade networks, practice seasonal transhumance, and let the 12-Year Celestial Calendar guide your path.',
      quoteTr: '"Ey Türk Kağanı! Töreni, ilini kim bozabilir? Bilge ol, töreye uy, kut bul!"',
      quoteEn: '"O Khagan of the Steppe! Who can overturn your law and realm? Be wise, uphold the Tore, and prosper!"',
      icon: Icons.auto_stories,
      themeColor: Color(0xFF38BDF8),
    ),
    IntroStoryScene(
      chapterTr: 'BÖLÜM III',
      chapterEn: 'CHAPTER III',
      titleTr: 'KUTLU FETİH VE KOZMİK ZİRVE',
      titleEn: 'CONQUEST & COSMIC PEAK',
      narrativeTr:
          'Altıgen karolar sınır tanımaz bir güçle genişliyor. Kağan Otağı altın kubbesiyle göğe yükselirken, düşman akınlarına karşı taş ve demir surlar örülüyor. Zud fırtınalarına göğüs gerecek, Toy Coşkusuyla tüm diyarı birleştireceksiniz. Kaderiniz tahtta, sınırlarınız ufukların ötesindedir.',
      narrativeEn:
          'Hexagonal lands expand beneath your unyielding will. As the golden dome of the Khan Tent pierces the clouds, stone and iron ramparts rise against raiders. Weather the harshest Zud blizzards, unite the realm through Toy Frenzy, and forge a legacy that echoes through eternity.',
      quoteTr: '"Gündüz oturmadım, gece uyumadım... Türk milleti için ili, töreyi kazandım!"',
      quoteEn: '"By day I did not sit idle, by night I did not sleep... For the people I won the realm and the law!"',
      icon: Icons.castle,
      themeColor: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishStoryAndStartAdventure() {
    TactileAudioService.instance.play(TactileSoundType.conquer);
    ref.read(gameStateProvider.notifier).completeIntroStory();
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(gameStateProvider.select((s) => s.settings));
    final lang = settings.language;
    final theme = NeoBrutalistTheme.getTheme(settings.activeThemePalette);
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width > 680 ? 640 : size.width * 0.94,
          height: size.height > 660 ? 600 : size.height * 0.92,
          decoration: BoxDecoration(
            color: const Color(0xFF060913),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFD97706), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF020617),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Üst Başlık & Atla Barı
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFF334155), width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu, color: Color(0xFFF59E0B), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'tr' ? 'BOZKIRIN DOĞUŞU' : 'DAWN OF THE STEPPE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Sayfa Göstergeleri
                        Row(
                          children: List.generate(_scenes.length, (idx) {
                            final isActive = _currentPage == idx;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF475569),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 14),
                        // Atla Butonu
                        TactileNeoButton(
                          onTap: _finishStoryAndStartAdventure,
                          backgroundColor: const Color(0xFF1E293B),
                          borderColor: const Color(0xFF475569),
                          shadowOffset: 1.5,
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            lang == 'tr' ? 'ATLA' : 'SKIP',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ana Hikaye Sayfaları
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _scenes.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (ctx, index) {
                    final scene = _scenes[index];
                    return _buildScenePage(scene, index, lang, theme);
                  },
                ),
              ),

              // Alt Navigasyon & Aksiyon Barı
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  border: Border(
                    top: BorderSide(color: Color(0xFF334155), width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Geri Butonu
                    if (_currentPage > 0)
                      TactileNeoButton(
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        backgroundColor: const Color(0xFF1E293B),
                        borderColor: const Color(0xFF475569),
                        shadowOffset: 2.0,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              lang == 'tr' ? 'GERİ' : 'PREV',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(width: 70),

                    // İleri veya Maceraya Başla Butonu
                    if (_currentPage < _scenes.length - 1)
                      TactileNeoButton(
                        onTap: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        },
                        backgroundColor: sceneColor(_currentPage),
                        borderColor: const Color(0xFF020617),
                        shadowOffset: 2.5,
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              lang == 'tr' ? 'İLERİ' : 'NEXT',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 14, color: Colors.black),
                          ],
                        ),
                      )
                    else
                      TactileNeoButton(
                        onTap: _finishStoryAndStartAdventure,
                        backgroundColor: const Color(0xFFF59E0B),
                        borderColor: const Color(0xFF020617),
                        shadowOffset: 3.0,
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.explore, size: 16, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(
                              lang == 'tr' ? 'MACERAYA BAŞLA' : 'BEGIN ADVENTURE',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color sceneColor(int idx) {
    switch (idx) {
      case 0:
        return const Color(0xFFF59E0B);
      case 1:
        return const Color(0xFF38BDF8);
      default:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildScenePage(IntroStoryScene scene, int index, String lang, NeoBrutalistThemeData theme) {
    final title = lang == 'tr' ? scene.titleTr : scene.titleEn;
    final chapter = lang == 'tr' ? scene.chapterTr : scene.chapterEn;
    final narrative = lang == 'tr' ? scene.narrativeTr : scene.narrativeEn;
    final quote = lang == 'tr' ? scene.quoteTr : scene.quoteEn;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Atmosferik Sanat Kartı (Neo-Brutalist Katmanlı İllüstrasyon)
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: scene.themeColor, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF020617),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildIllustratedBanner(index, scene),
                // Üst Gölgelendirme
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF060913).withValues(alpha: 0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                // Bölüm Rozeti
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      border: Border.all(color: scene.themeColor, width: 1.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      chapter,
                      style: TextStyle(
                        color: scene.themeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Başlık
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),

          // Taktiksel Hikaye Anlatısı
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFF334155), width: 1.2),
            ),
            child: Text(
              narrative,
              style: const TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Orhun Bengü Taş Alıntısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              border: Border(
                left: BorderSide(color: scene.themeColor, width: 3),
              ),
            ),
            child: Text(
              quote,
              style: TextStyle(
                color: scene.themeColor.withValues(alpha: 0.9),
                fontSize: 11,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustratedBanner(int index, IntroStoryScene scene) {
    switch (index) {
      case 0:
        // Bölüm I: Şafak ve İlk Çadır Ocağı (Altın Gündoğumu, Bozkır ve Ocak)
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF451A03),
                Color(0xFF78350F),
                Color(0xFF0F172A),
                Color(0xFF060913),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Güneş Işığı
              Positioned(
                top: 20,
                right: 40,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Dağ / Tepe Katmanları
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.terrain, size: 70, color: const Color(0xFF1E293B).withValues(alpha: 0.7)),
                    Icon(Icons.terrain, size: 90, color: const Color(0xFF0F172A).withValues(alpha: 0.8)),
                    Icon(Icons.terrain, size: 60, color: const Color(0xFF1E293B).withValues(alpha: 0.6)),
                  ],
                ),
              ),
              // Merkez İkon Kompozisyonu: Çadır & Ocak
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                      ),
                      child: const Icon(Icons.wb_sunny, size: 36, color: Color(0xFFFBBF24)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF451A03),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFFD97706), width: 1),
                      ),
                      child: const Text(
                        'BOZKIR OCAĞI',
                        style: TextStyle(
                          color: Color(0xFFFDE047),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 1:
        // Bölüm II: Bengü Taş ve Kadim Töre (Göksel Aurora, Monolit ve Bilgelik)
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF020617),
                Color(0xFF082F49),
                Color(0xFF0369A1),
                Color(0xFF060913),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Aurora Işıltısı
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF38BDF8).withValues(alpha: 0.25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Altıgen Sütunlar
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.view_in_ar, size: 40, color: const Color(0xFF0C4A6E).withValues(alpha: 0.6)),
                    Icon(Icons.view_in_ar, size: 55, color: const Color(0xFF0369A1).withValues(alpha: 0.5)),
                    Icon(Icons.view_in_ar, size: 40, color: const Color(0xFF0C4A6E).withValues(alpha: 0.6)),
                  ],
                ),
              ),
              // Merkez İkon: Bengü Taş & Rünik Yazıt
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                      ),
                      child: const Icon(Icons.auto_stories, size: 36, color: Color(0xFF38BDF8)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF082F49),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF0284C7), width: 1),
                      ),
                      child: const Text(
                        'ORHUN BENGÜ TAŞI',
                        style: TextStyle(
                          color: Color(0xFFBAE6FD),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 2:
      default:
        // Bölüm III: Kutlu Fetih ve Kozmik Zirve (Altın Kubbeli Kağan Otağı ve Surlar)
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF064E3B),
                Color(0xFF047857),
                Color(0xFF0F172A),
                Color(0xFF060913),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Göksel Yıldız Işıltısı
              Positioned(
                top: 15,
                left: 30,
                child: Icon(Icons.auto_awesome, size: 28, color: const Color(0xFFFBBF24).withValues(alpha: 0.7)),
              ),
              Positioned(
                top: 25,
                right: 35,
                child: Icon(Icons.auto_awesome, size: 22, color: const Color(0xFFFDE047).withValues(alpha: 0.6)),
              ),
              // Sur Mazgalları
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.shield, size: 34, color: const Color(0xFF065F46).withValues(alpha: 0.7)),
                    Icon(Icons.fort, size: 55, color: const Color(0xFF047857).withValues(alpha: 0.8)),
                    Icon(Icons.shield, size: 34, color: const Color(0xFF065F46).withValues(alpha: 0.7)),
                  ],
                ),
              ),
              // Merkez İkon: Kağan Otağı
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF10B981), width: 2),
                      ),
                      child: const Icon(Icons.castle, size: 36, color: Color(0xFF34D399)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: const Color(0xFF10B981), width: 1),
                      ),
                      child: const Text(
                        'KAĞANLIK ZİRVESİ',
                        style: TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
