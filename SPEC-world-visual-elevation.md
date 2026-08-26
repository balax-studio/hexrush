# Specification: World Visual Elevation & Architectural Dynamics

## Objective
HexRush'ın izometrik dünyasındaki binalara Seviye 1-10 görsel metamorfozu kazandırmak, yeni inşa edilen binalara ağırlık hissi veren düşme-yaylanma (drop & squash) fiziği entegre etmek, kış/zud mevsiminde dinamik kar sırtları oluşturmak ve canlı yaban hayatı mikro-animasyonlarını zenginleştirmek.

## Capabilities & Modules
1. `building_tiers`: Yel Değirmeni, Maden, Fırın, Keresteci, Taş Ocağı ve Sawmill için 3 kademeli (Lv 1-3 Ahşap, Lv 4-7 Taş/Demir, Lv 8-10+ İmparatorluk Altını) voksel mimari evrimi.
2. `construction_drop_physics`: İnşaat anında voksel blokların gökten -16px yüksekten inip yere çarpması ve yaylanması.
3. `seasonal_winter_caps`: Kış/Zud mevsiminde çatı sırtlarına ve çam dallarına beyaz voksel kar prizmaları.
4. `synergy_connections`: Komşu üretim karoları arasına otomatik organik taş patika bağlantıları.
5. `micro_fauna_flora`: At ve koyunlara baş eğip otlama mikro-kinetiği.

## Commands
- Test: `flutter test`
- Static Analysis: `flutter analyze`

## Zero-GC & Performance Boundary
- Tüm yeni çizim araçları (`Paint`, `Path`) sınıf seviyesinde `static final` havuzlarda tutulacak.
- Render döngüsünde hiçbir dinamik nesne oluşturulmayacak.
