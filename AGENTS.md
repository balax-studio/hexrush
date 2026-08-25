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

17. **Kadim Bozkır Terminolojisi ve Tarihsel Uyum Standardı (Anti-Feudal & Anti-Arcade Slop):**
    - Batı feodalizmi, modern sanayi veya jenerik fantastik slop terimlerinin (örn. *"Şato"*, *"Krallık"*, *"Taç"*, *"Mısır Tarlası"*, *"Kereste Fabrikası"*, *"Mobilyacı"*, *"Mithril"*, *"Tier X"*, *"Frenzy/Çılgınlık"*) kullanımı KESİNLİKLE YASAKTIR.
    - Tüm arayüz, yerelleştirme, görevler ve bildirimler Göktürk ve Avrasya bozkır devlet nizamına uygun terminoloji ile yazılmalıdır (*"Kağan Otağı"*, *"HexRush Kağanlığı"*, *"Kut / Hanlık Şanı"*, *"Buğday Tarlası"*, *"Hızar Otağı"*, *"Marangoz Otağı"*, *"Gök Demiri"*, *"Toy Coşkusu / Akın Narası"*, *"Bozkır Kurultay Pazarı"*). Detaylar `.agents/rules/ui_ux_ve_icerik_standartlari.md` belgesindedir.

