# Arkeolojik / Bozkır Neo-Brutalizmi Tasarım Standardı

## 1. Görsel Kimlik Tanımı (Visual Identity)
Oyunumuzun görsel kimliği, **"Arkeolojik / Bozkır Neo-Brutalizmi"** olarak tanımlanmıştır. Bu tarz; Göktürk ve Avrasya bozkır mitolojisinin mistik, epik tonlarını (Cinzel başlıklar, tunç/altın/turkuaz vurgular, taş tablet zeminler) modern Neo-Brutalist ürün tasarımıyla (sert ofset gölgeler, kalın katı kenarlıklar, yüksek kontrast, monospace metrikler, fiziksel basma hissi) harmanlar.

Arayüzde (UI) yapılacak tüm geliştirmelerde, yeni bileşenlerde ve revizyonlarda bu kural belgesindeki ilkelere istisnasız uyulması zorunludur.

---

## 2. Tipografi Standartları (Typography Rules)
- **Başlıklar (`h1, h2, h3, h4`, Modal Başlıkları, Unvanlar, Ferman Kartları):**  
  `font-family: 'Cinzel', Georgia, serif;`  
  `text-transform: uppercase;`  
  `letter-spacing: 0.5px - 1px;`  
  `font-weight: 700 / 900;`
- **Aksiyon Butonları (`.btn-primary, .btn-upgrade, .btn-collect`, Sekmeler):**  
  `font-family: 'Cinzel', serif;` veya `font-family: 'JetBrains Mono', monospace;`  
  `text-transform: uppercase;`  
  `font-weight: 700;`
- **Sayısal Metrikler, Sayaçlar, Kaynak Maliyetleri ve Timerlar:**  
  `font-family: 'JetBrains Mono', monospace;`  
  `font-variant-numeric: tabular-nums;` (sayı değişimlerinde layout titreşimi engellenir)
- **Gövde Metinleri ve Açıklama/Flavor Yazıları:**  
  `font-family: 'Outfit', sans-serif;`  
  `font-weight: 400 / 500;`

---

## 3. Geometri ve Köşe Yuvarlaklığı Kuralı (Zero Bubbly Corners)
- Yumuşak, yuvarlak hatlı (10px, 14px, 16px, 24px) SaaS/iOS köşe stilleri kesinlikle yasaktır.
- Tüm konteynerler (`#top-bar`, `#bottom-menu`, `.modal-card`, `.chip`, `.card`, `.btn`), taş tablet ve yontma kalkan hissi verecek şekilde **maksimum `3px` - `4px` `border-radius`** (`BorderRadius.circular(3)` veya `4`) değerine sahip olmalıdır.

---

## 4. Opak Yüzeyler (Zero Glassmorphism / Zero Blur)
- `backdrop-filter: blur(...)`, `ImageFiltered` veya `BackdropFilter` kullanımı kesinlikle yasaktır.
- Neo-Brutalizm katı, opak, fiziksel taş zeminleri temsil eder. Tüm paneller ve kartlar `%100` opak bazalt, arduvaz ve granit renkleri (`#060913`, `#0F172A`, `#1E293B` / `Color(0xFF060913)`, `Color(0xFF0F172A)`, `Color(0xFF1E293B)`) ile kaplanmalıdır.

---

## 5. Sert Ofset Gölgeler ve Kenarlıklar (Hard Offset Shadows & 2px Solid Borders)
- Blur (bulanıklık/yayılma) içeren yumuşak gölgeler (`blurRadius > 0`) yasaktır.
- Gölgeler daima sıfır yayılımlı sert açılı gölgelerdir (`BoxShadow(offset: Offset(3, 3), blurRadius: 0, color: ...)`):
  - **Standart Panel ve Buton:** `Offset(3, 3)` gölge `Color(0xFF020617)` (Büyük panellerde `Offset(5, 5)`)
  - **Altın / Hakan Vurgusu:** `Offset(3, 3)` gölge `Color(0xFF78350F)`
  - **Tengri Turkuazı / Rün Vurgusu:** `Offset(3, 3)` gölge `Color(0xFF0E7490)`
  - **Savaş Ateşi / Kırmızı Vurgu:** `Offset(3, 3)` gölge `Color(0xFF450A0A)`
- Kenarlıklar katı `2px` kalınlığında olmalıdır (`Border.all(color: Color(0xFF334155), width: 2)` veya altın vurgusu için `Color(0xFFD97706)`).

---

## 6. Dokunsal Mekanik Basma Hissi (Tactile Press States)
Tüm tıklanabilir butonlar, kartlar ve çipler fiziksel basma geri bildirimi vermelidir:
- **Hover / Normal Durumu:**  
  `Offset(-1, -1)` ve `Offset(4, 4)` sert gölge.
- **Active / Tıklanma Durumu:**  
  `Offset(3, 3)` aşağı çökme hareketi ve `Offset(0, 0)` sıfır gölge.

---

## 7. Bozkır Destanı Renk Paleti (Steppe Palette Tokens)
- **Bazalt Zemin:** `#060913`
- **Yontma Arduvaz Panel:** `#0f172a`
- **Taş Tablet Çip:** `#1e293b`
- **Yapısal Kenarlık:** `#334155`
- **Bozkır Altını:** `#f59e0b` / `#d97706` (Gölge: `#78350f`)
- **Gök Tengri Turkuazı:** `#06b6d4` / `#38bdf8` (Gölge: `#0e7490`)
- **Sedir / Ağaç Odunu:** `#b45309` / `#92400e`
- **Kurt Kanı / Savaş Ateşi:** `#dc2626` / `#ef4444` (Gölge: `#450a0a`)
- **Cilalı Kireçtaşı Metin:** `#f8fafc`
- **Kül Grisi (Muted):** `#94a3b8`

---

## 8. Sıfır Emoji ve Vektör/İkon Standardı
- Arayüzde ve oyun içi metinlerde hiçbir koşulda sistem emojisi kullanılmaz.
- **Flutter Arayüzü İçin:** Simgeler Flutter `Icons.*` (`Icons.fort`, `Icons.storefront`, `Icons.shield`, `Icons.warning_amber`, `Icons.lock`, `Icons.whatshot`), `CustomPainter` veya `flutter_svg` vektör ikonları ile render edilir.
- **Flame Oyun Motoru İçin:** Düşük poligonlu voksel çizimler (`LowPolyBuildingRenderer`), prosedürel parçacık efektleri (`VoxelParticleEmitter`) ve izometrik vektörel bileşenler kullanılır.
