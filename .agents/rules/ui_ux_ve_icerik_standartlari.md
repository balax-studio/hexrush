# Arayüz (UI/UX) ve İçerik Standartları (Anti-Slop & Zero-Emoji)

Bu kural belgesi, HexRush projesindeki tüm arayüz tasarımı, kullanıcı deneyimi, tipografi, simge kullanımı ve metin yazımı standartlarını belirler. Geliştiriciler ve yapay zeka ajanları bu kurallara istisnasız uymak zorundadır.

---

## 1. Kesin Emoji Yasağı (Zero Emoji Mandate)
- **Kural:** Arayüz bileşenlerinde (HUD, butonlar, modal başlıkları, diyaloglar, listeler, kaynak göstergeleri, tost bildirimleri), oyun içi metinlerde, lokalizasyon dosyalarında ve dökümanlarda **hiçbir koşulda sistem emojisi (Unicode emoji) kullanılamaz.**
- **Neden?** Emojiler platformlar arasında (iOS, Android, Web, Windows) tutarsız görünür, amatör bir his verir ve oyunun Arkeolojik / Neo-Brutalist görsel kimliğini bozar.
- **Alternatifler:**
  - Flutter UI için: `Icons.*` (`Icons.fort`, `Icons.storefront`, `Icons.auto_stories`, `Icons.warning_amber`, `Icons.lock`, `Icons.local_fire_department` vb.) veya özel `CustomPainter` / SVG vektör ikonları.
  - Flame oyun motoru için: Düşük poligonlu voksel çizimler, prosedürel parçacık efektleri ve vektörel renderers.

---

## 2. Slop Metin Yasağı (Zero AI Slop Text)
- **Kural:** Kalıplaşmış, süslü, içeriksiz ve jenerik yapay zeka jargonları (AI slop) kesinlikle yasaktır.
- **Yasaklı Kalıplar ve Yaklaşımlar:**
  - *"Destansı bir yolculuğa çıkın"*, *"Gücün sınırlarını zorlayın"*, *"Unleash your potential"*, *"Embark on an epic quest"* gibi içi boş pazarlama sloganları.
  - Gereksiz sıfat yığınları, yapay zeka selamlama cümleleri ve aşırı ünlem işaretleri (`!!!`).
- **Zorunlu Metin Tonu:**
  - **Net, Özlü ve İşlevsel:** Oyuncuya ne olduğunu, ne gerektiğini veya ne kazandığını doğrudan söyleyin.
  - **Taktiksel ve Mekanik Odaklı:** Sayısal veriler, kaynak gereksinimleri ve oyun içi etki açıkça belirtilmelidir.
  - *Örnek (Kötü):* `✨ Muazzam bir başarı! Krallığın sınırlarını genişleterek efsanevi bir şato inşa ettiniz! 🔥`
  - *Örnek (Doğru):* `Şato Seviye 2 inşa edildi. Küresel üretim hızı: +%25.`

---

## 3. Slop Tasarım ve Şablon Arayüz Yasağı (Anti-Slop UI)
- **Kural:** Web/mobil arayüzlerde görülen jenerik şablon tasarımlar, gereksiz kart hiyerarşileri ve tembel UI kalıpları yasaktır.
- **Yasaklı Tasarım Öğeleri:**
  - **Kart İçinde Kart (Cards-inside-cards):** 3-4 kademe iç içe geçmiş gereksiz kutu katmanları yasaktır.
  - **Aşırı Yuvarlatılmış Köşeler (Bubbly UI):** 12px, 16px, 24px hap/baloncuk köşeler yasaktır. Maksimum köşe yarıçapı `3px - 4px`'tir.
  - **Bulanık Cam Efekti (Glassmorphism / Backdrop Blur):** Katı, opak taş tablet dokusu esastır. Opak bazalt, arduvaz ve granit tonları (`#060913`, `#0F172A`, `#1E293B`) kullanılır.
  - **Yumuşak / Dağınık Gölgeler:** `blurRadius` içeren yumuşak gölgeler yerine daima sıfır yayılımlı sert açılı ofset gölgeler (`Offset(3, 3)`, sıfır blur) kullanılır.
  - **Tembel Boşluklar ve Düzensiz Hizalama:** Her bileşenin net bir grid konumu, sabit dokunsal basma durumu (hover/active basma hareketi) ve yüksek kontrastlı kenarlığı (`2px solid`) olmalıdır.

---

## 4. Tipografi ve Sayısal Hiyerarşi
- **Başlıklar ve Unvanlar:** `Cinzel` / Serif büyük harf (`UPPERCASE`), tok ve anıtsal.
- **Sayısal Metrikler ve Maliyetler:** `JetBrains Mono` / Monospace, sabit genişlikli (`tabular-nums`), titreşimsiz sayaçlar.
- **Açıklama ve Gövde Metinleri:** `Outfit` / Sans-serif, yüksek okunabilirlik (`#F8FAFC` kireçtaşı beyazı veya `#94A3B8` kül grisi).

---

## 5. Kadim Bozkır ve Türk Terminoloji Standardı (Anti-Feudal & Anti-Arcade Slop)
Oyun dili ve metinleri Göktürk, Hun ve Avrasya bozkır devlet nizamı ile tam uyumlu olmalıdır. Batı feodalizmi, modern sanayi veya jenerik fantezi slopları KESİNLİKLE KULLANILAMAZ.

| Yasaklı Feodal / Slop Terim | Zorunlu Bozkır & Brutalist Karşılığı | Neden Yasak? |
| :--- | :--- | :--- |
| **Şato / Kale** | **Kağan Otağı / Ak Otağ / Merkez Otağ** | Bozkır kağanlığının idare merkezi otağdır. |
| **Krallık** | **Kağanlık / Bozkır Kağanlığı** | Bozkır devlet teşkilatı krallık değil kağanlıktır. |
| **Taç (`crowns`)** | **Kut / Hanlık Şanı / Altın Tamga** | Bozkır hükümdarlarında taç değil, kut ve tamga esastır. |
| **Mısır Tarlası** | **Buğday Tarlası / Darı Ekini** | Mısır Amerika kıtası kökenlidir; kadim bozkırda buğday/darı ekilirdi. |
| **Kereste Fabrikası** | **Hızar Otağı / Bıçkıhane** | "Fabrika" modern sanayi çağı terimidir. |
| **Mobilyacı** | **Marangoz Otağı / Ağaç Yontucu** | Modern dükkan çağrışımı yapar. |
| **Mithril** | **Gök Demiri / Semavi Çelik** | Mithril Batı fantastik edebiyatı slopudur; Türk mitolojisinde göktaşı demiri "Gök Demiri"dir. |
| **Krallık Pazarı** | **Bozkır Kurultay Pazarı / İpek Pazarı** | Feodal pazar kalıbı yerine bozkır meclisi pazar kültürü. |
| **(Tier 2, Tier 3, ...)** | *(Kaldırılmalı veya "2. Aşama")* | İngilizce jenerik oyun slopudur. |
| **10x Çılgınlık (Frenzy)** | **10x Toy Coşkusu / 10x Akın Narası** | Arcade mobil oyun jargonu yerine kültürel coşku. |
| **"Harika!", "İyi oyunlar!"** | **"Oban kutlu, tören daim olsun."** | Şablon yapay zeka ve mobil tutorial slopu. |

