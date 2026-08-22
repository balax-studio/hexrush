# Sıfır Emoji & Vektörel SVG Standardı Kuralı (Zero Emoji & Strict SVG Standard)

Bu kural projenin profesyonel, modern ve tutarlı bir tasarım diline sahip olması için zorunlu kılınmıştır:

1. **Kesin Emoji Yasağı (Strict No-Emoji Rule):**
   - Projenin hiçbir yerinde (UI butonları, başlıklar, sekmeler, tost bildirimleri, modal pencereleri, envanter çipleri, istatistikler, canvas/oyun içi etiketler) standart sistem emojileri (örneğin 🌽, 🪵, 🍞, 👑, ⚡, ⚙️, 🔨, 🔒 vb.) KULLANILAMAZ.
   - Emojiler cihazdan cihaza ve işletim sistemine göre farklı ve çocuksu göründüğü için kesinlikle yasaktır.

2. **Vektörel SVG Standardı (Inline SVG & Icon System):**
   - Tüm kaynak, bina, sekme ve arayüz ikonları için temiz, optimize edilmiş inline `<svg>` veya SVG sembolleri kullanılmalıdır.
   - SVG ikonlar `class="svg-icon"` sınıfı ile standart boyutlandırılmalı (16x16, 20x20, 24x24 px gibi) ve renkleri CSS (`currentColor` veya tematik renkler) ile yönetilmelidir.

3. **Canvas ve Bildirim Uyumluluğu:**
   - Canvas üzerinde uçuşan kaynaklar veya yüzen metinlerde emoji yerine sade semboller, metin etiketleri veya canvas üzerinde render edilen vektörel ikonlar kullanılmalıdır.
   - Tost ve bildirim mesajlarında emoji yerine SVG içeren HTML veya temiz tipografik etiketler kullanılmalıdır.
