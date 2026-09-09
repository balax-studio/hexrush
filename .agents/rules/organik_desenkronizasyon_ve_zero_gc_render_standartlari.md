# Organik Desenkronizasyon, Atmosferik Sis ve Zero-GC Render Standartları

Bu kural belgesi, HexRush izometrik Flame motoru ve arayüz çizim katmanında organik doğallığı korumak, senkronik robotik hareketleri önlemek ve 60 FPS Zero-GC bellek bütçesini sağlamak için zorunlu yönergeleri içerir.

---

## 1. Organik Animasyon Desenkronizasyonu (Deterministik Faz Kayması)

### 1.1. Senkronik Hareket Yasağı
- Sahnedeki ağaçlar, huş ağaçları, ekinler, yel değirmenleri, sazlıklar, koyunlar, balıklar, lav bacaları ve ateşböcekleri asla aynı fazda ve aynı hızda hareket edemez.
- Tekdüze `_animTimer` kullanımı yasaktır.

### 1.2. Eksenel Koordinat Tabanlı Faz Formülü
Her altıgen karo (`HexAxial(q, r)`), kendi koordinatlarından deterministik bir faz açısı ve frekans mikro-varyansı türetmelidir:
```dart
double get tileAnimTime {
  final double phaseOffset = (((coord.q * 17 + coord.r * 31).abs() % 360) * (math.pi / 180.0));
  final int seed = (coord.q * 37 + coord.r * 19).abs();
  final double freqMult = 0.90 + ((seed % 5) * 0.05); // 0.90x ile 1.10x hız varyansı
  return (_animTimer * freqMult) + phaseOffset;
}
```

### 1.3. Alt-Öğe (Sub-Prop) Faz Ayrımı
Aynı karo üzerinde birden fazla voksel nesnesi (örn. 2 ağaç, çiçekler ve koyun) varsa, her nesneye mikro-faz ofseti (`+0.65s` - `+1.2s`) atanarak bağımsız rüzgar dalgası oluşturulmalıdır:
```dart
VoxelIsometricRenderer.drawVoxelTree(canvas, posA, animTime: tTime);
VoxelIsometricRenderer.drawVoxelBirchTree(canvas, posB, animTime: tTime + 0.85);
```

---

## 2. Zero-GC ve 60 FPS Render Standartları

### 2.1. Render ve Update Döngüsünde Nesne Tahsisi Yasağı
- `render(Canvas canvas)` ve `update(double dt)` fonksiyonları içinde kesinlikle `Paint()`, `Path()`, `TextPainter()`, `TextStyle()` veya geçici dizi/liste `new`lenemez.
- Her karede çöp toplayıcı (GC) tetikleyecek heap tahsisleri yasaktır.

### 2.2. Yeniden Kullanılabilir Statik Havuzlar (Static Pools)
Tüm çizim nesneleri sınıf seviyesinde `static final` olarak tutulmalı ve kullanılmadan önce sıfırlanmalıdır (`reset()`):
```dart
static final Paint _sharedFillPaint = Paint()..style = PaintingStyle.fill;
static final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;
static final Path _fogPath = Path();

// Kullanım:
_fogPath.reset();
_sharedFillPaint.color = targetColor;
canvas.drawPath(_fogPath, _sharedFillPaint);
```

---

## 3. Atmosferik Sis ve Diorama Sınır Geçişi (Soft Fog Falloff)

### 3.1. Keskin Sınır Yasağı
- Açık/keşfedilmiş renkli karolar ile arkasındaki karanlık keşfedilmemiş alanlar arasında keskin ve sert kontrast geçişleri yasaktır.

### 3.2. Kademeli Sınır Sisi (Border Fog)
- Açık karolara komşu olan sınır sis karoları daha açık tonlarda (`#0F172A`, 0.82 alfa) çizilirken, dış çeperdeki derin sis `#060913` bazalt karanlığına yumuşakça gömülmelidir.

### 3.3. Hafif Atmosferik Vinyet (Zero-Drop Blur)
- Performans düşüşüne sebep olacak ağır tam ekran Gaussian Blur filtreleri yerine, `DioramaLensOverlay` içindeki çok kademeli `RadialGradient` vinyet katmanları (`0.0, 0.48, 0.72, 0.88, 1.0` durakları) ile sinematik yumuşak geçiş sağlanmalıdır.

---

## 4. Pahalı GPU `saveLayer` Kesin Yasağı ve Doğrudan Harmanlama

### 4.1. `canvas.saveLayer` Yasağı
- Gece atmosferi, sis, fener ışığı, gölgeler veya parçacık sistemlerinde `canvas.saveLayer(bounds, Paint())` kullanımı KESİNLİKLE YASAKTIR.
- `saveLayer`, GPU üzerinde tam ekran boyutunda offscreen framebuffer/doku ayırır ve özellikle mobil/web platformlarında kare hızını 20-30 FPS'e düşürür.
- Tüm gece karartmaları ve fener efektleri doğrudan ana hedef yüzeye `BlendMode.screen`, `BlendMode.plus` veya `BlendMode.colorDodge` harmanlama modları ve `RadialGradient` ile çizilmelidir.

### 4.2. Emitter ve Işık Kaynağı Önbellekleme
- `update(double dt)` veya `render(Canvas canvas)` döngülerinde her karede `final List<LightEmitter> emitters = [];` veya `new LightEmitter(...)` üretilemez.
- Işık kaynakları yalnızca gün/gece geçişi olduğunda veya haritada bina inşaatı yapıldığında güncellenen `_cachedLightEmitters` havuzunda tutulmalıdır.

---

## 5. Harita Motorunda Görsel Eşitlik Koruması (`_isTileVisuallyIdentical`)

### 5.1. Ekonomik Sayaç Artışlarında Karo Tarama Yasağı
- Pasif üretim sırasında binaların `accumulatedResource`, `soilHealth` veya `restTimeAccumulated` gibi ekonomik sayaçları saniyelik olarak güncellenir.
- Bu sayaç artışlarında karo görseli değişmediği için, `HexMapGame._updateTiles` döngüsünde `prevTile == tile` yerine `_isTileVisuallyIdentical(prevTile, tile)` kontrolü zorunludur.
- Görsel durumu (biyom, sis, sahiplik, bina tipi, bina seviyesi, tapınak, kurgan, kış koruması, sur) değişmeyen karolar için 6-yönlü komşu taraması, kot farkı ve `updateData` çağrısı kesinlikle atlanmalıdır (`continue`).

---

## 6. Flutter UI Katmanında Ağır Matematik ve Ticker İzolasyonu

### 6.1. Saniyelik `calculateNetRates` Çalıştırma Yasağı
- `TopBarHUD` ve diğer HUD bileşenleri pasif kaynak sayaç artışlarında yeniden çizildiğinde, `EconomyCalculator.calculateNetRates(...)` gibi haritadaki tüm karoları ve komşuluk sinerjilerini tarayan ağır fonksiyonları doğrudan `build()` içinde her saniye ÇALIŞTIRAMAZ.
- `ratesHash` (karo sayısı, bina sayısı, kale seviyesi, taç, mevsim, zud, frenzy, tapınak) mekanizması ile oranlar önbelleklenmeli; yalnızca yapısal bir ekonomi değişkeni değiştiğinde yeniden hesaplanmalıdır.

### 6.2. Boştaki Panellerde Dinlemeyi Kapatma (Idle Early Exit)
- `TileActionSheet`, `Hexpedia` vb. paneller kapalıyken veya boştayken (`selectedCoord == null` ve `isDismissed`), `ref.watch(gameStateProvider)` ile saniyelik sayaç artışlarında gereksiz `build()` tetiklememelidir; doğrudan `const SizedBox.shrink()` ile dinleme kesilmelidir.

