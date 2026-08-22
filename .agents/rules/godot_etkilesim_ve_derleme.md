---
trigger: always_on
---

# Godot UI & Etkileşim & Derleme Bütünlüğü Kuralları

Bu kurallar projede widget tıklanamama, harita kaybolması veya parse error sorunlarının tekrar yaşanmaması için her güncellemede zorunlu olarak uygulanır:

1. **Mükerrer Fonksiyon / Değişken Kontrolü (Zero Duplicate Declarations):**
   - GDScript içerisinde aynı isimde bir fonksiyon (`func`) veya değişken (`var`) tanımlandığında motor `Parse Error` verir ve bu sınıfa bağlı tüm diğer betikler zincirleme olarak çöker.
   - Herhangi bir betiğe fonksiyon eklerken veya güncellerken dosya içerisinde aynı fonksiyon adının zaten mevcut olup olmadığı daima kontrol edilmeli, mükerrer bloklar derhal temizlenmelidir.

2. **UI Mouse Filter Koruma Standardı (Mouse Filter Protection):**
   - Godot'da `Control`, `PanelContainer`, `Label`, `MarginContainer` düğümleri varsayılan olarak `mouse_filter = STOP (0)` kullanır ve altlarındaki buton ve altıgen karolara giden tıklamaları yutar.
   - Bildirimler (`ToastNotification`), etiketler (`Label`) ve tıklanmaması gereken tüm arka plan panelleri için `mouse_filter = Control.MOUSE_FILTER_IGNORE (2)` atanmalıdır.

3. **Sahne ve Sinyal Eşleşmesi (Scene Signal Integrity):**
   - `.tscn` sahne dosyasında bir `Area2D` veya `Button` sinyale (örneğin `_on_area_2d_input_event`) bağlanmışsa, bağlı `.gd` betiğinde bu fonksiyonun eksiksiz, tekil ve doğru parametrelerle yer aldığından emin olunmalıdır.

4. **Harita Başlatma ve Y-Sort Derinliği (Map Init & Isometric Depth):**
   - `HexGrid` başlatılırken hem `HexGrid._ready()` hem de `Main._initialize_game_state()` içinde çift harita oluşturma (`queue_free` çakışması) yapılmamalıdır.
   - Karoların `z_index` değeri elle negatif yapılmamalı; sıralama için `HexGrid` üzerinde `y_sort_enabled = true` kullanılmalıdır.

5. **Headless Motor ve Log Doğrulaması:**
   - Yapılan her değişiklikten sonra oyun motoru arka planda (`--headless`) çalıştırılmalı ve `logs/godot.log` dosyasında 0 hata ve 0 ayrıştırma hatası olduğu doğrulanmalıdır.
