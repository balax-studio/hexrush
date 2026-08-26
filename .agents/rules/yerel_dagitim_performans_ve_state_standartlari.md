# Yerel Dağıtım, Performans, State ve Kayıt Standartları

Bu kural belgesi, HexRush projesinde yerel çalışma prensiplerini, Flame render optimizasyonunu, Riverpod mimari sınırlarını, kayıt bütünlüğünü ve dokunsal geri bildirimleri tanımlar.

---

## 1. Yerel Öncelikli Çalışma ve Dağıtım Kilidi (Deployment Guard)
- **Kesin Kural:** Kullanıcı açıkça *"push et"*, *"web build al"*, *"deploy et"* talimatı vermediği sürece ajanlar:
  - Asla `git push` komutu çalıştıramaz.
  - Asla `flutter build web` veya otomatik CI/CD dağıtımını tetikleyen komutlar çalıştıramaz.
- **Yerel Doğrulama:** Tüm yeni özellikler ve hata düzeltmeleri yerel testlerle (`flutter test`) veya yerel çalıştırmalarla doğrulanır.

---

## 2. Flame Motoru Render & Bellek Bütçesi (Zero-GC Standard)
- **Garbage Collector Yükünü Sıfırlama:**
  - `render(Canvas canvas)` veya `update(double dt)` döngüsü içerisinde her karede (`60 FPS = her 16ms`) `new Paint()`, `new Path()` veya dinamik `Rect` oluşturulması yasaktır.
  - Sık kullanılan fırçalar, gölgeler ve stiller `static final Paint _xxx = Paint()...` veya bileşen sınıfı seviyesinde bir kez oluşturulup tekrar kullanılır.
- **Viewport Kırpma (Culling):**
  - Kamera görüş alanının dışında kalan altıgen karoların karmaşık alt nesneleri çizilmemeli, render maliyeti düşürülmelidir.

---

## 3. İmmutable State & Katman Ayrımı
- **Riverpod ve GameState Bütünlüğü:**
  - `GameState`, `HexTileModel`, `BuildingModel` ve tüm veri modelleri daima `@immutable` kalmalıdır.
  - Durum güncellemeleri yalnızca `state = state.copyWith(...)` veya saf fonksiyonlar üzerinden yapılır; doğrudan referans mutasyonu yasaktır.
- **UI Katmanından Mantık İzolasyonu:**
  - Zamanlayıcılar, hammadde çarpanları, offline gelir hesaplamaları ve biyom kuralları doğrudan Widget'lar içine yazılamaz. Bu mantıklar `EconomyCalculator` ve `GameStateNotifier` içinde yer almalıdır.

---

## 4. Kayıt Bütünlüğü, Şema Sürümleme ve Eşzamanlama (Save Integrity)
- **Kayıt Şeması ve Migrasyon:**
  - `SharedPreferences` veya yerel JSON deposuna kaydedilen verilerde mutlaka bir `schemaVersion` (örn. `version: 2`) alanı tutulmalıdır.
  - Yeni bir veri alanı eklendiğinde eski kayıtların bozulmaması için varsayılan değerler atanmalı ve geriye dönük uyumlu `fromJson` / `toJson` migrasyonu işletilmelidir.
- **Kayıt ve State Tam Eşzamanlaması:**
  - `GameState` veri modeline eklenen her yeni alan (`doctrines`, `slots`, `stats`), `SaveDataBundle`, `SaveRepository.saveGame` ve `SaveRepository.loadGame` içine anında eklenmelidir.
  - Oyuncu tarafından tetiklenen kritik veri mutasyonlarında (`unlockDoctrine`, `equipDoctrine`, `upgradeBuilding`, `demolishBuilding`, `resetGame`) anında `saveGame()` çağrılmalıdır.

---

## 5. Dokunsal Ses ve Haptik Standardı (Tactile Audio & Haptics)
- **Organik Ses Tasarımı:**
  - Oyunun Arkeolojik Bozkır Neo-Brutalizm kimliğine uygun olarak dijital/bip sesleri yerine taş sürtünmesi, çekiç darbesi, ahşap tokmağı ve bozkır rüzgarı gibi taktil ses efektleri tercih edilmelidir.
- **Fiziksel Haptik Geri Bildirim:**
  - Tıklanan tüm butonlar, inşa edilen binalar ve fethedilen karolarda `HapticFeedback.lightImpact()` veya `HapticFeedback.mediumImpact()` ile dokunsal onay sağlanmalıdır.

---

## 6. Dinamik Ekonomi ve Arayüz Ayrımı (Domain-Driven UI)
- **Sabit Sayı Yasağı (No Hardcoded Costs):**
  - Arayüz bileşenlerinde (örneğin buton etiketleri veya aktifleşme kontrollerinde) `wood >= 5.0` gibi sabit sayı kontrolleri kesinlikle yasaktır.
  - Tüm maliyetler, indirimler ve formüller daima `EconomyCalculator` üzerinden dinamik olarak çekilmelidir.

---

## 7. Prestij İlerlemesi ve Arazi Yönetimi Kuralları
- **Prestij Kümülatif Sayaç Koruması:**
  - Büyük Göç (`resetGame`) sonrası oyun sıfırlanırken, `totalMigrations` sayacı `totalMigrations + 1` olarak korunmalıdır.
- **Bina Yıkma ve Yeniden Yapılandırma Özgürlüğü:**
  - Merkez Han Şatosu hariç tüm yapılarda oyuncunun karoyu boşaltabilmesi için yıkma (`demolishBuilding`) ve %50 gıda iadesi mekanizması sağlanmalıdır.

---

## 8. Flutter HUD / Widget Katmanı Render ve Ticker İzolasyonu (Zero-Stutter UI Rebuilds)
- **Granüler Riverpod Dinleyicileri:**
  - Arayüz bileşenlerinde (`TopBarHUD`, `QuestTrackerHUD`, `TileActionSheet` vb.) asla doğrudan `ref.watch(gameStateProvider)` kullanılmamalıdır.
  - Sadece ihtiyaç duyulan alt alanlar `ref.watch(gameStateProvider.select((s) => s.alan))` şeklinde dinlenerek saniyelik pasif sayaç artışlarında tüm arayüzün gereksiz yere baştan inşa edilmesi önlenmelidir.
- **Ticker ve Animasyon Kontrolcüsü Tasarrufu:**
  - Boşta duran veya tamamlanmamış görev kutularında `AnimationController.repeat` gibi sürekli 60 FPS çalışan kontrolcüler kesinlikle durdurulmalıdır (`stop()`).
  - Pasif mikro-kaynak artışlarında (örneğin her saniye +0.1 gıda gelmesi) her sayaç çipine 60 FPS darbe animasyonu başlatılmamalıdır.
- **RepaintBoundary İzolasyonu:**
  - HUD katmanları (`TopBarHUD`, `QuestTrackerHUD`, `TileActionSheet`, `ResourcePulseChip`) `RepaintBoundary` ile sarılarak Flame oyun tuvali ve diğer arayüz katmanlarından tamamen izole edilmelidir.
- **Frustum Culling Payı (Margin Guard):**
  - Ekranda çizilen altıgen karoların viewport kırpma kontrolünde (`bounds`) ani nesne kaybolmasını (pop-in) engellemek için `margin = hexRadius * 1.6` güvenli kırpma mesafesi uygulanmalıdır.


