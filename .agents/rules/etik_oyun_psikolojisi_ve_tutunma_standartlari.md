# Etik Oyun Psikolojisi ve Oyuncu Tutunma Standartları (Retention Standards)

Bu kural belgesi, HexRush'ta oyuncu elde tutma (D1, D7, D21, D30 Retention) ve psikolojik tasarım stratejilerini, etik sınırlar ve projenin Arkeolojik Neo-Brutalizm ilkeleri doğrultusunda düzenler.

---

## 1. Etik İlkeler ve Kesin Yasaklar (Anti-Dark Patterns)

HexRush içerisinde kısa vadeli metrik şişirmelerine dayalı, oyuncuyu sömüren, kaygı veya bağımlılık tuzakları kuran karanlık desenler (Dark Patterns) KESİNLİKLE YASAKTIR.

1. **Kaybolan Fırsat ve Sahte Zamanlayıcı Yasağı (No FOMO Timers):**
   - "2 saat içinde almazsan kaybolur" türü yapay geri sayımlar ve aciliyet baskıları yasaktır.
   - Zamanlama unsurları yalnızca oyun içi deterministik mevsim döngüsü (`SeasonModel`) ile sınırlıdır.

2. **Saldırgan ve Suçluluk Yaratan Bildirim Yasağı (No Guilt-Tripping Push Notifications):**
   - Oyuncuya "Bizi unuttun!", "Toprakların yok oluyor!" gibi suçluluk yükleyen bildirimler gönderilemez.
   - Bildirimler varsayılan olarak sessiz/kapalı olmalı; oyuncunun kendi kurduğu hedeflere (ör. "Ambarlar dolduğunda haber ver") dayalı ve Arkeolojik Neo-Brutalizm üslubuna uygun sakin bilgilendirme metinleriyle iletilmelidir.

3. **Cezalandırıcı Yokluk Yasağı (No Punitive Inactivity):**
   - Oyuncunun oyuna girmediği günler için ceza (kaynak çürümesi, bina yıkılması, verim düşüşü) uygulanamaz.
   - Çevrimdışı üretim (`calculateOfflineGains`) 8 saatlik depolama sınırına ulaşınca durur, ancak birikmiş kaynaklar asla kaybolmaz.

4. **Yapay Ödeme Duvarı ve Aldatıcı Zorluk Yasağı (No Paywalls & Rigged DDA):**
   - Oyun içi zorluk eğrileri (`pow(1.6, ownedCount)` ve `pow(1.15, level)`) tamamen deterministiktir.
   - Oyuncuyu para harcamaya zorlamak için gizli algoritma müdahaleleri (DDA) yapılamaz.

---

## 2. Pozitif Psikoloji ve Öz-Belirleme Kuramı (SDT) İlkeleri

1. **Özerklik (Autonomy):**
   - Oyuncunun haritada hangi yöne genişleyeceğine, hangi biyomu fethedeceğine ve hangi binaları kurup yıkacağına (`demolishBuilding`) kendisinin karar vermesi esastır. Tek tip zorunlu yol dayatılamaz.

2. **Yetkinlik (Competence & Game Feel):**
   - Stratejik yerleşimler (ör. volkan yanına maden kurarak +%50 jeotermal bonus almak) anında dokunsal ve görsel geri bildirimle ("Sinerji Parıltısı", haptik titreşim `HapticFeedback.lightImpact`, organik taş/demir sesleri) ödüllendirilmelidir.

3. **Anlamlı İlerleme:**
   - İlerleme adımları şansa değil, oyuncunun kurduğu üretim ve lojistik motoruna dayanır.

---

## 3. Aşamalı Tutunma (Retention) Yol Haritası

| Aşama | Hedef | Odak Mekanikler |
|---|---|---|
| **D1 (0-24 Saat)** | İlk İzlenim & İlk Başarı | İlk 90 saniyede dokun-fethet döngüsü, 3 dakikalık taktil açılış, net mikro görev zinciri (`QuestModel`), çevrimdışı üretim güvencesi. |
| **D7 (2-7 Gün)** | Alışkanlık & Strateji | Mevsim döngüsü farkındalığı (Kış hazırlığı, `isWarmed` ısıtma mekaniği), doktrin kartı kilitlerinin açılması, geri dönüş toplama animasyonu. |
| **D21 (8-21 Gün)** | Derinlik & Büyük Göç | İlk "Büyük Göç" (`resetGame`) eşiği, Tamga çarpanı (`getTamgaMultiplier`), alternatif doktrin yuva kombinasyonları, pazar takas optimizasyonu. |
| **D30+ (22+ Gün)** | Ustalık & Sadakat | Kümülatif unvanlar (`titles`: Kagan, Fatih, Zud Ustası, Tüccar), deterministik mevsim anomalileri (volkan patlamaları, bereket çağı), arazi uzmanlaşması. |

---

## 4. Etik Doğrulama Kontrol Listesi (Yeni Özellik Gate)

Her yeni mekanik, ekran veya sistem eklenmeden önce şu sorulardan geçmelidir:
- Oyuncuyu belirli saatlerde girmeye zorluyor mu? (Evetse: REDDET)
- Oyuncunun oyunda olmadığı süreyi cezalandırıyor mu? (Evetse: REDDET)
- Kayıp korkusu (FOMO) tetikliyor mu? (Evetse: REDDET)
- Oyuncunun stratejik becerisini ve planlamasını ödüllendiriyor mu? (Evetse: KABUL)
- Arkeolojik Neo-Brutalizm ve Sıfır-Emoji standartlarına tam uyumlu mu? (Evetse: KABUL)
