# HexRush Geliştirici ve Ajan Kuralları (AGENTS.md)

Bu dosya, projede çalışan tüm yapay zeka ajanları ve geliştiriciler için bağlayıcı ana kuralları içerir.

## 1. Proje Temel Bilgileri
- **Oyun Adı:** HexRush
- **Paket Kimliği:** `com.balax.hexrush`
- **Dart Paket Adı:** `hex_rush`
- **Mimari:** Flutter + Flame + Riverpod (İzometrik altıgen ızgara, voksel render sistemi, taktil boşta/fetih stratejisi).

## 2. Zorunlu Standartlar ve Kontrol Noktaları
1. **Apple App Store Uyumluluğu:**
   - `ios/Runner/PrivacyInfo.xcprivacy` manifesti her zaman korunmalı ve Xcode projesine bağlı olmalıdır.
   - `Info.plist` içinde `ITSAppUsesNonExemptEncryption = false` bulunmalıdır.
   - Değişiklikler sonrası `greenlight preflight .` çalıştırıldığında GREENLIT (0 kritik sorun) çıktısı alınmalıdır.

2. **Google Play Store Uyumluluğu:**
   - Android release derlemeleri için `android/app/build.gradle.kts` içindeki `key.properties` mekanizması korunmalıdır.
   - `android/app/proguard-rules.pro` kuralları eksiksiz tutulmalıdır.
   - İzinler minimal tutulmalı, gereksiz internet veya hassas izin eklenmemelidir.

3. **Oturum İyileştirmelerini Kaydetme İlkesi:**
   - Her sohbette yapılan kalıcı mimari kararlar, standartlar ve optimizasyonlar `.agents/rules/` ve `AGENTS.md` içerisine kaydedilir.

4. **Zorunlu Tasarım, Arayüz ve İçerik İlkeleri (Anti-Slop & Zero-Emoji):**
   - **Sıfır Emoji Yasağı:** HUD, butonlar, modallar, diyaloglar, bildirimler, oyun metinleri ve dökümanlarda sistem emojisi kullanımı KESİNLİKLE YASAKTIR. Simgeler Flutter `Icons.*`, Flame voksel renderers veya özel vektör çizimlerle sağlanır.
   - **Yapay Zeka Slop Metin Yasağı:** Kalıplaşmış, abartılı, süslü yapay zeka jargonu (örn. *"Destansı macera"*, *"Unleash power"*, aşırı ünlemler) yasaktır. Metinler net, özlü, mekanik ve taktiksel olmalıdır.
   - **Slop Tasarım ve Şablon Arayüz Yasağı:** Jenerik iç içe kartlar (cards-inside-cards), aşırı yuvarlak hap köşeler (12px+), bulanık cam efektleri (blur/glassmorphism) yasaktır.
   - **Arkeolojik Neo-Brutalizm Standartları:** Maksimum 3px-4px köşe yarıçapı, 2px katı kenarlıklar (`#334155`, `#d97706`), sert açılı sıfır blur ofset gölgeler (`box-shadow: 3px 3px 0px #020617`), opak taş dokusu zeminler (`#060913`, `#0f172a`, `#1e293b`) ve dokunsal basma geri bildirimi zorunludur.

5. **Test ve Doğrulama:**
   - Her geliştirme adımından sonra `flutter test` çalıştırılarak tüm testlerin eksiksiz geçtiği teyit edilmelidir.

6. **Yerel Öncelikli Çalışma ve Dağıtım Kontrolü (Deployment Guard):**
   - Kullanıcıdan açık ve net bir talimat gelmedikçe (örn. *"push et"*, *"web build al"*) kesinlikle `git push` yapılamaz ve `flutter build web` tetiklenemez.
   - Tüm geliştirme, deneme ve doğrulamalar yerel çalışma alanında tutulmalıdır.

7. **Flame Motoru Render ve Bellek Bütçesi (Zero-GC & 60 FPS):**
   - `render(Canvas canvas)` ve `update(double dt)` döngüleri içinde her karede dinamik `Paint()` veya `Path()` nesnesi oluşturulamaz (`new`lenemez).
   - Çizim araçları `static final` veya bileşen seviyesinde önceden tahsis edilmiş olmalıdır.

8. **İmmutable State ve Katman Ayrımı:**
   - `GameState` ve tüm alt veri modelleri kesinlikle `immutable` (`copyWith`) kalmalıdır.
   - Formüller ve zamanlayıcılar UI katmanında değil, `EconomyCalculator` ve `GameStateNotifier` içinde izole edilmelidir.

9. **Kayıt Güvenliği, Migrasyon ve Eşzamanlama (Save & State Synchronization):**
   - Yerel depolamaya yazılan oyun durumlarında `schemaVersion` bulunmalı ve geriye dönük uyumlu migrasyon mekanizması korunmalıdır.
   - `GameState` içine eklenen her yeni veri modeli alanı anında `SaveDataBundle`, `SaveRepository.saveGame` ve `SaveRepository.loadGame` serileştirmesine bağlanmalıdır.
   - Doktrin açma, takma, prestij veya bina işlemlerinde 10 saniyelik otomatik kayıt beklenmeden anında `saveGame()` çağrılmalıdır.

10. **Dokunsal Ses ve Haptik Standardı (Tactile Audio & Haptics):**
    - Sentetik/dijital sesler yerine taş, ahşap ve demir gibi organik sesler kullanılmalıdır.
    - Tıklanabilir tüm interaktif butonlarda hafif dokunsal titreşim (`HapticFeedback.lightImpact`) sağlanmalıdır.

11. **Dinamik Ekonomi ve UI Mantık Ayrımı (Domain-Driven UI):**
    - Arayüz bileşenleri (HUD, Action Sheet, Dialoglar) kaynak maliyetlerini, indirimleri veya buton etiketlerini asla sabit sayılarla hardcode edemez (`wood >= 5.0` vb. yasaktır).
    - Tüm maliyetler ve metinler daima `EconomyCalculator` üzerinden dinamik hesaplanmalıdır.

12. **Kalıcı İlerleme ve Prestij Koruma İlkesi (Prestige Cumulative Invariance):**
    - Büyük Göç (`resetGame`) işleminde kümülatif sayaçlar (`totalMigrations`, `tamgas`) kesinlikle sıfırlanamaz; `totalMigrations + 1` olarak korunmalıdır.

13. **Arazi Yönetimi ve Yeniden Yapılandırma Özgürlüğü (Hex Remodeling Agency):**
    - Oyuncunun bina kurduğu arazilerde strateji değişikliği yapabilmesi için bina yıkma (`demolishBuilding`) ve kısmi iade mekanizması daima sunulmalıdır.

14. **Etik Oyun Psikolojisi ve Tutunma İlkeleri (Ethical Retention & Anti-Dark Patterns):**
    - Kısa vadeli metrik baskısı için oyuncuyu cezalandıran, kaygı (FOMO) yaratan veya agresif bildirimler içeren karanlık desenler (Dark Patterns) KESİNLİKLE YASAKTIR.
    - D1-D30 tutunma planı Öz-Belirleme Kuramı (özerklik, yetkinlik, akış hali), dokunsal mikro-tatminler ve deterministik mevsim/göç dengesi üzerine inşa edilir (`.agents/rules/etik_oyun_psikolojisi_ve_tutunma_standartlari.md`).

15. **Dijital Bağımlılık ve Karanlık Tasarım Kesin Yasakları (18 Mekanik Standartı):**
    - Lootbox, seri (streak) cezası, suni kıtlık/FOMO, kırmızı mikro-anksiyete rozetleri, sentetik casino efektleri, near-miss illüzyonları ve yapay gecikmeler (pay-to-skip) KESİNLİKLE YASAKTIR.
    - Tüm mekanik, görsel, fonksiyonel ve sosyal tasarımlar `.agents/rules/dijital_bagimlilik_ve_karanlik_tasarim_yasaklari.md` standartlarına tam uyumlu olmak zorundadır.

16. **Organik Animasyon Desenkronizasyonu, Sis Geçişi ve Zero-GC Standartları:**
    - Doğadaki ağaç, ekin, su ve bina animasyonlarında tekdüze senkronik hareket yasaktır; eksenel koordinat tabanlı deterministik faz ofseti (`tileAnimTime`) ve alt-öğe faz kaymaları zorunludur.
    - Açık karolar ile karanlık sis alanı arasında yumuşak atmosferik geçiş (Border Fog & Multi-Stop Radial Vignette) sağlanmalıdır.
    - `render()` ve `update()` döngülerinde her karede yeni `Paint()` veya `Path()` nesnesi oluşturulamaz; `static final` veya önceden tahsis edilmiş havuzlar korunmalıdır (`.agents/rules/organik_desenkronizasyon_ve_zero_gc_render_standartlari.md`).

18. **Flutter HUD / Widget Katmanı Render ve Ticker İzolasyonu (Zero-Stutter UI Rebuilds):**
    - Arayüz bileşenlerinde (TopBarHUD, QuestTrackerHUD, TileActionSheet vb.) `ref.watch(gameStateProvider)` şeklinde tüm state'i dinleyen geniş dinleyiciler yasaktır; her zaman hassas `ref.watch(gameStateProvider.select((s) => ...))` kullanılmalıdır.
    - Saniyede 60 kare çalışan döngüsel `AnimationController` nesneleri sadece aktif bir animasyon gerektiğinde çalıştırılmalı, boşta (idle) veya tamamlanmamış görev kutularında durdurulmalıdır (`stop()`).
    - HUD bileşenleri ve bağımsız animasyon yongaları mutlaka `RepaintBoundary` ile sarılarak Flame oyun motoru ve diğer ekran katmanlarından izole edilmelidir.
    - Ağır hesaplamalar (örn. `calculateNetRates`) sadece karolar, seviye veya mevsim değiştiğinde yapılmalı; saniyelik pasif kaynak sayaç artışlarında tüm harita döngüleri baştan çalıştırılmamalıdır.

19. **Doğal Düzensizlik İçinde Düzen ve Organik Çeşitlilik Standardı (Procedural Organic Variance):**
    - Her çayır, çöl veya orman karosu tekdüze kopyala-yapıştır varlık ve hayvan içeremez; tohum (`seed = (q*37 + r*19).abs()`) tabanlı organik dağılım zorunludur.
    - Çayır karolarında yalnızca %50 ihtimalle hayvan bulunur; atlar (4 farklı don: Doru, Yağız, Kır, Alaca), koyunlar, koçlar ve kuzular yön (`flipX`) ve konum ofsetleriyle çeşitlendirilir.
    - Parçacıklar (çöl tozu, tundra ışıltısı, deniz balıkları) her karoda değil, 1/4 veya 1/5 sıklıkta seyrek dağıtılmalıdır.
    - Gökyüzü kuşları sabit 3'lü dizilim yerine döngüsel çoklu tür filoları (Kartal, Turna, Kırlangıç, Martı) halinde uçmalıdır.

20. **Karpathy Davranışsal Kodlama ve Cerrahi Müdahale İlkeleri:**
    - **Kodlamadan Önce Düşün (Think Before Coding):** Belirsizliklerde varsayım üretme, netleştirme iste. Alternatifleri ve trade-off'ları açıkça belirt.
    - **Önce Basitlik ve Minimalizm (Simplicity First):** Talep edilmeyen hiçbir soyutlama, ekstra özellik veya spekülatif esneklik ekleme. Minimum ve en yalın kodla çöz.
    - **Cerrahi Değişiklikler (Surgical Changes):** Yalnızca görevin doğrudan gerektirdiği satırlara dokun. Çevre kodlarda veya ilgisiz dosyalarda refactoring/temizlik yapma.
    - **Hedef Odaklı Yürütme (Goal-Driven Execution):** Her adımı somut doğrulama kriterlerine bağla ve testlerle teyit etmeden görevi tamamlandı sayma.

21. **Buton Boyut, Yükseklik ve Taktil Hiyerarşi Standardı (Uniform Tactile Button Tokens):**
    - Ham Flutter `ElevatedButton`, `OutlinedButton` veya `TextButton` kullanımı KESİNLİKLE YASAKTIR; tüm interaktif butonlar `TactileNeoButton` ile oluşturulmalıdır.
    - Buton yükseklikleri keyfi dolgu (padding) yerine tanımlı yükseklik jetonlarıyla yönetilmelidir:
      - `ButtonSize.xs` (24px - 28px): Modal/HUD kapatma butonları (28x28px / 24x24px), Otağ seviye ve sinerji sayaçları (26px).
      - `ButtonSize.sm` (26px - 30px): TopBarHUD kaynak çipleri ve Frenzy (30px), Mevsim/Zud rozetleri (26px), Kehanet ve Göç bannerları (26px), Kurgan/Kervan aksiyonları (30px), Meclis sekmeleri ve doktrin aksiyonları (30px).
      - `ButtonSize.md` (32px - 38px): Görev tamamlama butonu (32px), Pazar takas butonları (34px), Dil seçim butonları (34px x 50px), Harita FAB butonları (36x36px), Bina topla/yükselt/ısıt/yık aksiyonları (38px).
      - `ButtonSize.lg` (40px - 42px): Ana fetih butonu (42px), Kağan Otağı geliştirme (40px), Diorama aksiyonları (40px).
      - `BuildGridCard`: İnşaat seçim kartları sabit 56px yükseklik ve `MainAxisAlignment.spaceBetween` ile hizalanmalıdır.
    - Tüm buton içerikleri `alignment: Alignment.center` veya `MainAxisAlignment.center` ile dikeyde tam ortalanmalıdır.

22. **Kayıpsız Git Senkronizasyon ve Akıllı Birleştirme Protokolü (Lossless Git Sync & Smart Merge):**
    - Uzak depodan (`origin/main`) kod çekilirken (pull / rebase / fetch) hiçbir yerel geliştirme veya script doğrudan ezilemez/silinemez.
    - Birleştirme öncesinde `git log HEAD..origin/main` ve yerel diff analizi yapılarak iki taraftaki tüm özelliklerin nihai kodda eksiksiz harmanlanması sağlanır.
    - `git stash save` -> `git pull --rebase` -> `git stash pop` akışı uygulanır; çakışmalarda her iki özelliğin de korunduğu kapsayıcı birleştirme yapılır.
    - İşlem sonrası `flutter test` çalıştırılarak tüm testlerin eksiksiz geçtiği doğrulanır (`.agents/rules/kayipsiz_git_senkronizasyon_ve_birlestirme_protokolu.md`).

23. **Cerrahi Arama, Ripgrep ve Token Tasarrufu Standardı (Surgical Phased Retrieval):**
    - Kod analizi ve düzenleme taleplerinde dosyaları körü körüne topluca okumak (bulk read) yasaktır; hedef sınıf/fonksiyon öncelikle `ripgrep` / `grep_search` ile taranmalıdır.
    - Kademeli arama protokolü (standart -> `-u` gizli dosyalar -> `-tdart` / `-tjson` dosya tipi filtreleme) uygulanır.
    - Cerrahi müdahale öncesinde kod bloğunun yaşam döngüsü ve yan etkileri incelenmeli, gereksiz token tüketimi ve bağlam kirliliği engellenmelidir (`.agents/rules/cerrahi_arama_ve_ripgrep_tasarruf_standartlari.md`).


