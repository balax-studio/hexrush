# HexRush Proje Kimliği ve Mağaza Standartları Kuralı

Bu kural projenin kimlik, mağaza uyumluluğu ve derleme standartlarını belirler. Tüm geliştirmelerde bu kurallara uyulması zorunludur:

## 1. Proje Kimliği ve Paket Yapısı
- **Oyun Adı (App Title / Display Name):** `HexRush` (Tüm platformlarda: iOS, Android, Web, Windows).
- **Paket Kimliği (Bundle ID / Application ID / Namespace):** `com.balax.hexrush`.
- **Dart Paket Adı:** `hex_rush` (`pubspec.yaml` ve test importlarında).

## 2. Apple App Store & iOS Standartları
- `ios/Runner/PrivacyInfo.xcprivacy` dosyası ve `UserDefaults` (`CA92.1`) erişim sebebi her zaman korunmalı ve `project.pbxproj` Resources aşamasına dahil olmalıdır.
- `Info.plist` içerisinde `ITSAppUsesNonExemptEncryption = false` korunmalıdır.
- Kod değişiklikleri sonrası `greenlight preflight .` taramasında **sıfır kritik hata (GREENLIT)** durumu korunmalıdır.

## 3. Google Play & Android Standartları
- Sürüm derlemeleri için `android/app/build.gradle.kts` içerisinde `key.properties` üzerinden güvenli imzalama desteklenmelidir. Üretim anahtarları asla koda gömülmemelidir.
- `android/app/proguard-rules.pro` kuralları korunarak Flutter, Flame ve Riverpod reflection/küçültme güvenliği sağlanmalıdır.
- `AndroidManifest.xml` içinde gereksiz ve hassas izinler talep edilmemeli; çevrimdışı (offline-first) prensibi korunmalıdır.

## 4. Test ve Regresyon Zorunluluğu
- Yapılan her mimari, mekanik veya yapılandırma değişikliğinden sonra `flutter test` çalıştırılarak tüm testlerin eksiksiz geçtiği doğrulanmalıdır.
- Oyundaki taktil dopamin geri bildirimleri (fetih patlamaları, yükselen kaynak sayıları, akıcı kamera kontrolleri) bozulmamalı ve 60 FPS performansı korunmalıdır.

## 5. Mağaza Varlıkları Senkronizasyonu
- Yeni bir mekanik, veri saklama yöntemi veya özellik eklendiğinde `store_assets/ASO_AND_STORE_READINESS.md` ve `store_assets/PRIVACY_POLICY.md` dosyaları güncel tutulmalıdır.
