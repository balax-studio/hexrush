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
- Tüm konteynerler (`#top-bar`, `#bottom-menu`, `.modal-card`, `.chip`, `.card`, `.btn`), taş tablet ve yontma kalkan hissi verecek şekilde **maksimum `3px` - `4px` `border-radius`** değerine sahip olmalıdır.

---

## 4. Opak Yüzeyler (Zero Glassmorphism / Zero Blur)
- `backdrop-filter: blur(...)` veya `filter: blur(...)` kullanımı kesinlikle yasaktır.
- Neo-Brutalizm katı, opak, fiziksel taş zeminleri temsil eder. Tüm paneller ve kartlar `%100` opak bazalt, arduvaz ve granit renkleri (`#060913`, `#0f172a`, `#1e293b`) ile kaplanmalıdır.

---

## 5. Sert Ofset Gölgeler ve Kenarlıklar (Hard Offset Shadows & 2px Solid Borders)
- Blur (bulanıklık/yayılma) içeren yumuşak gölgeler (`rgba(...) 0 4px 12px`) yasaktır.
- Gölgeler daima sıfır yayılımlı (`X Y 0px Color`) sert açılı gölgelerdir:
  - **Standart Panel ve Buton:** `box-shadow: 3px 3px 0px #020617;` (Büyük panellerde `5px 5px 0px #020617`)
  - **Altın / Hakan Vurgusu:** `box-shadow: 3px 3px 0px #78350f;`
  - **Tengri Turkuazı / Rün Vurgusu:** `box-shadow: 3px 3px 0px #0e7490;`
  - **Savaş Ateşi / Kırmızı Vurgu:** `box-shadow: 3px 3px 0px #450a0a;`
- Kenarlıklar katı `2px solid` kalınlığında olmalıdır (`#334155`, `#d97706`, `#0891b2`, `#dc2626`).

---

## 6. Dokunsal Mekanik Basma Hissi (Tactile Press States)
Tüm tıklanabilir butonlar, kartlar ve çipler fiziksel basma geri bildirimi vermelidir:
- **Hover Durumu:**  
  `transform: translate(-1px, -1px);`  
  `box-shadow: 4px 4px 0px #020617;`
- **Active (Tıklanma) Durumu:**  
  `transform: translate(3px, 3px);`  
  `box-shadow: 0px 0px 0px #020617;`

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

## 8. Sıfır Emoji ve SVG Vektör Standardı
- Arayüzde hiçbir koşulda sistem emojisi kullanılmaz.
- Tüm simgeler `<svg class="svg-icon ..."><use href="#icon-..."/></svg>` vektör sprite sistemiyle render edilir.
