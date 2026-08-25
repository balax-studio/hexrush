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
