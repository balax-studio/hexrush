# Spec: Next-Gen Render Engine Pipeline (İleri Seviye Render Mimarisi)

## Capability Map (Yetenek Haritası)

| Modül ID | Sorumluluk | Bağımlılık |
|---|---|---|
| `frustum-culling` | Kamera görünürlük alanına (viewport rect + margin) göre karo kırpma | — |
| `layer-baking` | Değişmeyen zemin karolarını `ui.Picture` katmanına fırınlayarak (bake) tek çağrıda çizme | `frustum-culling` |
| `instanced-particles` | Kar, rüzgar tozu, duman ve altın tozu parçacıklarını tek çağrıda işleme | — |
| `post-processing` | Oyun sahnesine Tilt-Shift diorama derinliği ve atmosferik renk tonlaması (bloom/vignette) uygulayan GLSL shader | — |

**İnşa Sırası:** `frustum-culling` → `layer-baking` → `instanced-particles` → `post-processing`

---

## 1. Objective (Hedef ve Kabul Kriterleri)

HexRush izometrik harita çizimini mobil ve web ortamlarında 60 FPS sabit akıcılıkta tutmak, çizim çağrılarını (draw calls) %85 azaltmak ve masaüstü diorama estetiğini ekran uzayı GLSL efektleriyle zenginleştirmek.

### Başarı Kriterleri:
- **Draw Call Tasarrufu:** 100+ karolu haritada kare başına çizim çağrıları %60+ azalmalı.
- **Sıfır Bellek Çöpü (Zero-GC):** Culling ve Particle tamponları `Float32List` ve `Rect` havuzlarından beslenmeli, döngüde `new` nesne oluşturulmamalı.
- **Geriye Dönük Uyumluluk:** Test koşullarında (headless / CI) tüm motorlar graceful fallback ile çalışmalı, 250+ testin tamamı yeşil kalmalı.

---

## 2. Tech Stack & Komutlar

- **Framework:** Flutter (Impeller/Skia) + Flame 1.38 + Riverpod
- **Komutlar:**
  - Test: `flutter test --reporter compact`
  - Dev Sunucu: `flutter run -d web-server --web-port=8088 --web-hostname=localhost`
  - Statik Analiz: `flutter analyze`

---

## 3. Modül Detayları ve Mimari Tasarım

### A. Modül: `frustum-culling` ([`lib/presentation/flame/renderers/viewport_culling_manager.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/altıgen/lib/presentation/flame/renderers/viewport_culling_manager.dart))
- Kamera `camera.visibleWorldRect` alanını alır, 64px güvenlik payı (margin) ekler.
- `HexTileComponent.render(canvas)` çağrılmadan önce `cullingManager.isVisible(pixelPos)` kontrolü yapılır; ekran dışındaki karoların 3D duvar, zemin ve voksel çizimleri atlanır.

### B. Modül: `layer-baking` ([`lib/presentation/flame/components/hex_terrain_chunk_layer.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/altıgen/lib/presentation/flame/components/hex_terrain_chunk_layer.dart))
- Statik zemin katmanlarını (toprak, taş duvarlar) `ui.PictureRecorder` ile bir kez kaydeder.
- Yalnızca bir karo fethedildiğinde, bina inşa edildiğinde veya sis açıldığında ilgili chunk invalidate edilir.

### C. Modül: `instanced-particles` ([`lib/presentation/flame/components/instanced_weather_particles.dart`](file:///c:/Users/YSR_MONSTER/.antigravity/altıgen/lib/presentation/flame/components/instanced_weather_particles.dart))
- 1.000+ kar tanesi, çöl tozu ve hasat kıvılcımı `Float32List` transform ve rect dizileri üzerinden `Canvas.drawRawAtlas` veya batched vertices ile tek donanım çağrısında işlenir.

### D. Modül: `post-processing` ([`shaders/post_process_diorama.frag`](file:///c:/Users/YSR_MONSTER/.antigravity/altıgen/shaders/post_process_diorama.frag))
- Kamera görüntüsü üzerine Tilt-Shift derinlik alanı (DOF), sıcaklık tonlaması ve organik vinyet uygulayan global ekran gölgelendiricisi.

---

## 4. Sınırlar ve Kurallar (Boundaries)

- **Her Zaman Yap:** `Zero-GC` çizim araçlarını koru, `flutter test` ile doğrula.
- **Asla Yapma:** UI mantığına doğrudan render maliyeti yükleme, oyun döngüsünde dinamik `Paint` tahsis etme.

---

## 5. Doğrulama Planı

1. **Birim Testleri:** `test/viewport_culling_test.dart`, `test/instanced_particles_test.dart`, `test/post_process_test.dart`.
2. **Genel Test Paketi:** `flutter test --reporter compact` ile tüm 250+ testin başarıyla geçtiğini doğrulama.
