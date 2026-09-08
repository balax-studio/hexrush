---
name: plan
description: "Karmaşık oyun mekaniği, ekonomi optimizasyonu, UI refaktörü veya özellik geliştirmeleri için adım adım, test güdümlü (TDD) ve cerrahi uygulama planları hazırlar."
metadata:
  origin: custom
---

# Plan (Surgical Implementation Planning Protocol)

Bu beceri, oyun geliştirme, mimari refaktör, dengeleme ve yeni özellik entegrasyonu süreçlerinde karmaşık görevleri atomik, doğrulanabilir ve geri alınabilir alt adımlara bölerek ayrıntılı bir uygulama planı (`implementation_plan.md` / `docs/plans/`) oluşturmak için kullanılır.

## 1. Temel Prensipler
- **Sıfır Varsayım & Cerrahi Odak:** Kod yazmaya başlamadan önce tüm dosya bağımlılıkları ve veri modelleri kesinleştirilir.
- **TDD (Test Güdümlü Geliştirme):** Her kritik mantık adımı için önce başarısız test, ardından minimal kod ve son olarak yeşil test doğrulaması öngörülür.
- **Atomik Görevler:** Her görev bağımsız olarak doğrulanabilir, 5-15 dakikalık cerrahi parçalara bölünür.
- **AGENTS.md & Mimari Değişmezler:** Neo-brutalizm, zero-emoji, Zero-GC (Flame render döngüsünde dinamik nesne yasağı) ve immutable state kuralları her görev adımına entegre edilir.

---

## 2. Planlama Aşamaları

### Aşama 1: Durum Tespiti ve Kapsam Analizi (Discovery & Scoping)
- İlgili modeller, hesaplayıcılar (`EconomyCalculator`, `GameStateNotifier`) ve UI bileşenleri tespit edilir.
- Mevcut test kapsamı (`flutter test`) ve olası regresyon riskleri çıkarılır.

### Aşama 2: Mimari Tasarım ve Veri Akışı (Data Flow & Architecture)
- Yeni alanlar (`GameState`, `TileModel` vb.) ve bu alanların `SaveRepository` (serileştirme/deserileştirme) uyumu tanımlanır.
- UI bileşenlerinin `ref.watch(gameStateProvider.select(...))` ile nasıl izole edileceği belirlenir.

### Aşama 3: Atomik Görev Dökümü (Task Breakdown)
Her görev şu formatta tanımlanır:
1. **Hedef Dosyalar:** Düzenlenecek veya oluşturulacak dosyaların tam yolları.
2. **Yapılacak İş:** Minimal ve cerrahi değişiklik açıklaması.
3. **Doğrulama / Test:** Çalıştırılacak spesifik test komutu (`flutter test test/...`).

### Aşama 4: Riskler, Geri Alma ve Dengeleme Kriterleri (Contingency)
- Ekonomik enflasyon veya erken aşama soft-lock riskleri.
- Performans / render bütçesi (60 FPS, Zero-GC).

---

## 3. Çıktı Standardı
Plan her zaman net, maddeler halinde, gereksiz laf kalabalığından arındırılmış ve geliştiricinin doğrudan adım adım uygulayabileceği somut kod/test talimatları içermelidir.
