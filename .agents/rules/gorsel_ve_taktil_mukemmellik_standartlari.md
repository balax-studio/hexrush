# Görsel ve Taktil Mükemmellik, Voksel Derinlik ve Hasat Standartları

Bu kural belgesi; HexRush voksel izometrik diorama dünyasını, taktil geri bildirim mekaniklerini ve arayüz derinliğini Awwwards / Apple Design Award standartlarında en üst görsel seviyede tutmak için zorunlu tasarım ve kodlama ilkelerini içerir.

---

## 1. Taktil Hasat ve Parabolik Geri Bildirim (Juicy Harvest Feedback)

### 1.1. Doğrudan Hasat Yaylanması (Squash & Stretch Bounce)
- Karoya doğrudan dokunulduğunda (`collectFromTile` / `triggerTapBounce`) altıgen karo ve üzerindeki voksel binalar anında `math.sin(progress * math.pi) * 8.0` formülüyle dikeyde yaylanıp yerine oturmalıdır.
- Oyuncuya dokunmanın fiziksel bir nesneye temas ettiği hissi verilmelidir.

### 1.2. Parabolik Uçan Kaynak Rozetleri (`FloatingResourceNumberComponent`)
- Hasat yapıldığında çıkan kaynak sayıları dikey düz çizgide yükselmek yerine, `math.sin(progress * math.pi * 1.5) * 4.0` ile hafif yatay salınımlı parabolik bir yay çizerek süzülmelidir.
- Kart tasarımı **Çift Çerçeveli (Double-Bezel)** olmalıdır:
  - Dış 2.5px sert siyah ofset gölge (`Offset(2.5, 2.5)`).
  - 2px katı dış kenarlık.
  - 1px iç beyaz/altın aydınlatma çizgisi (`_innerBezelPaint`).
  - Açılışta 1.22 kat büyüyüp sönümlenen kinetik pop ölçeklendirmesi.

### 1.3. Voksel Parçacık Işıltıları (`HarvestSparkleEmitter`)
- Doğrudan hasatta patlayan parçacıklar 3D dönen voksel mikro-küpler ve dönen tamga ışıltı haçları (`_sparkleFlarePaint`) ile çizilmelidir.

---

## 2. İzometrik Yönlü Gölge Projeksiyonu ve Mekânsal Hacim

### 2.1. Yüksekliğe Bağlı Yönlü Zemin Gölgeleri
- `VoxelIsometricRenderer.drawIsoCube` fonksiyonunda `drawShadow: true` olduğunda, gölge sadece taban kenarı çizimiyle sınırlı kalmayıp küpün yüksekliğine (`h`) orantılı olarak 45 derecelik izometrik ışık açısıyla (`sOffset = math.min(12.0, h * 0.35)`) arazi üzerine yönlü uzayan sert gölge düşürmelidir.

### 2.2. Kademeli Monolitik Dağ Terasları
- Dağ karoları düz tek parça değil; taban bazalt kaidesi, orta sırt ve karla kaplı sivri zirvelerden oluşan 3 kademeli volümetrik masifler olarak render edilmelidir.

---

## 3. Yaşayan Kinetik Binalar ve Ortam Parçacıkları

### 3.1. Üretim ve Çalışma Görsel İpuçları
- **Yel Değirmeni:** Çark dönüşü esnasında rotorun altından havada süzülen altın-beyaz un tozu zerrecikleri (`dAlpha`, `drawIsoCube`) yayılmalıdır.
- **Demir Madeni:** Ocak kapısında akkor demir/kor ışıltısı (`emberPulse`) ve bacadan yükselen kömür dumanı halkaları bulunmalıdır.
- **Kağan Otağı:** Seviye 1-2'den Seviye 10+'a kadar aşamalı olarak taş platformlar, altın kemerli portaller, Seviye 5+ imparatorluk tuğ/sancakları ve Seviye 8+ göksel tamga spiresi ile evrilmelidir.

---

## 4. Hacimsel Atmosfer ve Bulut Gölgeleri

### 4.1. Geniş Dolaşımlı Yüzen Bulutlar (`FloatingVoxelCloudComponent`)
- Bulutlar dar bir alanda sıkışmak yerine harita üzerinde `-950px` ile `+950px` genişliğindeki alanda izometrik rüzgar açısıyla (`x += speed * dt`, `y += speed * 0.22 * dt`) süzülmelidir.
- Yeryüzüne vuran bulut gölgeleri çift katmanlı eliptik yumuşak gölgeler (`_innerGroundShadowPaint` + `_groundShadowPaint`) olarak araziyi örtmelidir.

### 4.2. Tilt-Shift Minyatür Diorama Merceği
- `DioramaLensOverlay` ile harita merkezdeki binaları odaklayan yumuşak tilt-shift dikey gradyanları ve mevsimsel atmosferik filtreler korunmalıdır.

---

## 5. Sıfır Çöp Toplama (Zero-GC) Değişmezi

- Tüm yeni parçacık, gölge, parıltı ve rozet çizimlerinde nesne tahsisi yasaktır.
- `Paint()` ve `Path()` nesneleri mutlaka `static final` veya bileşen havuzu seviyesinde önceden ayrılmış olmalıdır.
