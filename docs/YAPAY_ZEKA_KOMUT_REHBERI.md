# 👑 Hex Idle
## Yapay Zeka Yetenekleri ve Geliştirici Slash (/) Komutları Kılavuzu

Bu kılavuz, **Hex Idle** oyun projesinde Antigravity ve Claude Code Game Studios sistemleri altında yer alan 74 adet yapay zeka yeteneğini (skill / slash komutunu), görevlerini ve projeye özel somut kullanım senaryolarını açıklar.

---

### 📑 İçindekiler
1. [Oyun Tasarımı, Fikir & Konsept Yetenekleri](#1-oyun-tasarımı-fikir--konsept-yetenekleri)
2. [Oyun Ekonomisi, İlerleme & Matematiksel Denge](#2-oyun-ekonomisi-ilerleme--matematiksel-denge)
3. [Yazılım Mimarisi & Mimari Karar Kayıtları (ADR)](#3-yazılım-mimarisi--mimari-karar-kayıtları-adr)
4. [Görev, Sprint & Proje Yönetimi Yetenekleri](#4-görev-sprint--proje-yönetimi-yetenekleri)
5. [Kodlama, İnceleme & Canlı Hata Düzeltme (Dev & Review)](#5-kodlama-i̇nceleme--canlı-hata-düzeltme-dev--review)
6. [Kalite Güvence, Hata Takibi & Test (QA & Testing)](#6-kalite-güvence-hata-takibi--test-qa--testing)
7. [Kullanıcı Deneyimi, Görsel Sanat & Arayüz (UI/UX & Art)](#7-kullanıcı-deneyimi-görsel-sanat--arayüz-uiux--art)
8. [Ses, Hikaye, Harita & Seviye Tasarımı](#8-ses-hikaye-harita--seviye-tasarımı)
9. [Sürüm, Yerelleştirme & Yayınlama (Release & Live-Ops)](#9-sürüm-yerelleştirme--yayınlama-release--live-ops)
10. [Yapay Zeka İstemi Optimizasyonu & Genel Yardım](#10-yapay-zeka-i̇stemi-optimizasyonu--genel-yardım)

---

### 1. Oyun Tasarımı, Fikir & Konsept Yetenekleri

#### `/brainstorm`
- **📌 Görevi:** Sıfırdan yapılandırılmış oyun konsepti, temel döngü ve fikir beyin fırtınası yürütür.
- **💡 Bu Projede Kullanımı:** Deniz karolarına liman veya balıkçı ağı ekleyerek yeni bir gıda ve ticaret döngüsü tasarlamak istediğinizde.
- **🎯 Örnek İstem:**
  ```text
  /brainstorm deniz biyomunda balıkçılık ve liman ticareti mekanikleri
  ```

#### `/quick-design`
- **📌 Görevi:** Küçük denge ayarları ve minör mekanikler için hızlı ve hafif tasarım spesifikasyonu üretir.
- **💡 Bu Projede Kullanımı:** Mevcut fabrikalara küçük ara yükseltmeler veya tekil yetenekler eklerken kapsamlı GDD yazmadan hızlı spec çıkarmak için.
- **🎯 Örnek İstem:**
  ```text
  /quick-design odun üretim hızını %25 artıran testere yükseltmesi
  ```

#### `/design-system`
- **📌 Görevi:** Belirli bir oyun sistemi için adım adım kapsamlı Oyun Tasarım Belgesi (GDD) hazırlar.
- **💡 Bu Projede Kullanımı:** Giriş ekranındaki 3x video izleme bonusu, ambar kapasitesi limitleri ve zaman damgası hesaplama kurallarını resmi belgeye dökmek için.
- **🎯 Örnek İstem:**
  ```text
  /design-system Çevrimdışı Gelir ve Karşılama Ekranı Sistemi
  ```

#### `/map-systems`
- **📌 Görevi:** Oyun konseptini alt sistemlere ayırır, bağımlılıkları haritalandırır ve tasarım sırasını belirler.
- **💡 Bu Projede Kullanımı:** Yeni bir ekonomi dalı kurmadan önce hangi binalara, kaynaklara ve UI pencerelerine ihtiyaç duyulduğunu şematik olarak görmek için.
- **🎯 Örnek İstem:**
  ```text
  /map-systems Pazar Yeri, Tüccar Kervanı ve Krallık Vergisi mekanikleri
  ```

#### `/review-all-gdds`
- **📌 Görevi:** Tüm sistem GDD'lerini bütüncül olarak tarayarak çelişkileri ve ekonomik dengesizlikleri inceler.
- **💡 Bu Projede Kullanımı:** Kaynak tüketimlerinin (örneğin un -> ekmek ve tahta -> mobilya) birbiriyle çakışıp çakışmadığını denetlemek için.
- **🎯 Örnek İstem:**
  ```text
  /review-all-gdds
  ```

#### `/consistency-check`
- **📌 Görevi:** GDD belgeleri arasındaki tutarsızlıkları, çakışan istatistikleri ve formül uyumsuzluklarını tarar.
- **💡 Bu Projede Kullanımı:** Kod içerisindeki 10x Frenzy çarpanı ile tasarım belgesindeki bonus oranlarının birebir örtüştüğünü garantilemek için.
- **🎯 Örnek İstem:**
  ```text
  /consistency-check doc/gdd/economy.md ve Main.gd çarpanları
  ```

#### `/prototype`
- **📌 Görevi:** Oyun fikrinin üretilebilirliğini test etmek için hızlı ve atılabilir bir prototip planlar.
- **💡 Bu Projede Kullanımı:** HexGrid üzerinde dağ gölgesi ve sis açma algoritmasının performansını test edecek mini prototip oluşturmak için.
- **🎯 Örnek İstem:**
  ```text
  /prototype dinamik sis (Fog of War) ve görüş hattı algoritması
  ```

#### `/reverse-document`
- **📌 Görevi:** Mevcut kod ve prototiplerden geriye dönük eksik tasarım ve mimari belgelerini çıkarır.
- **💡 Bu Projede Kullanımı:** Halihazırda yazılmış olan altıgen koordinat ve biyom üretim kodlarından mimari ve GDD belgelerini otomatik üretmek için.
- **🎯 Örnek İstem:**
  ```text
  /reverse-document scripts/HexGrid.gd ve HexMath.gd
  ```

---

### 2. Oyun Ekonomisi, İlerleme & Matematiksel Denge

#### `/balance-check`
- **📌 Görevi:** Oyun ekonomisi, formüller, ilerleme eğrileri ve denge verilerini analiz ederek bozuklukları tespit eder.
- **💡 Bu Projede Kullanımı:** Bölge 1 (1-6 arsa), Bölge 2 (7-12 arsa) ve Bölge 3 (13+ arsa) maliyet artışlarının oyuncuyu tıkamadan tatmin edici ilerleme sunup sunmadığını test etmek için.
- **🎯 Örnek İstem:**
  ```text
  /balance-check 1-3. bölge arsa maliyetleri ve un/ekmek üretim oranları
  ```

#### `/perf-profile`
- **📌 Görevi:** Performans darboğazlarını, bellek/işlemci bütçelerini analiz eder ve optimizasyon önerileri sunar.
- **💡 Bu Projede Kullanımı:** Harita büyüdükçe her karede çalışan taşma/üretim döngülerinin 60 FPS altına düşmemesini garantilemek için.
- **🎯 Örnek İstem:**
  ```text
  /perf-profile 100+ altıgen ve 40 bina varken _process tick süresi
  ```

#### `/soak-test`
- **📌 Görevi:** Uzun süreli oyun oturumlarında bellek sızıntısı ve yavaşlayan hataları yakalamak için protokol hazırlar.
- **💡 Bu Projede Kullanımı:** Oyuncu oyunu arka planda günlerce açık bıraktığında float taşması (infinity) veya bellek şişmesi olup olmadığını denetlemek için.
- **🎯 Örnek İstem:**
  ```text
  /soak-test 8 saatlik kesintisiz simülasyon ve offline hesaplama
  ```

#### `/scope-check`
- **📌 Görevi:** Kapsam kaymasını (scope creep) orijinal plana göre karşılaştırarak şişkinlikleri tespit eder.
- **💡 Bu Projede Kullanımı:** Sprint hedeflerinden sapmadan sadece gerekli özelliklere odaklanıldığını doğrulamak için.
- **🎯 Örnek İstem:**
  ```text
  /scope-check Mevcut sprintte planlanan Taş Fırın vs eklenen diğer özellikler
  ```

---

### 3. Yazılım Mimarisi & Mimari Karar Kayıtları (ADR)

#### `/create-architecture`
- **📌 Görevi:** Kod yazımından önce tüm GDD'leri ve motor referanslarını okuyarak ana mimari planını oluşturur.
- **💡 Bu Projede Kullanımı:** Hem masaüstü Godot sürümünün hem de PWA web sürümünün aynı veri formatını (SaveManager JSON) kullanmasını planlamak için.
- **🎯 Örnek İstem:**
  ```text
  /create-architecture Çift Motor (Godot 4 + HTML5 Canvas) senkronizasyon mimarisi
  ```

#### `/architecture-decision`
- **📌 Görevi:** Önemli teknik kararları, bağlamı ve sonuçları belgeleyen Mimari Karar Kaydı (ADR) oluşturur.
- **💡 Bu Projede Kullanımı:** Neden küp koordinat yerine q,r aksiyel koordinat kullandığımızı ve matematiksel faydalarını belgelemek için.
- **🎯 Örnek İstem:**
  ```text
  /architecture-decision ADR-005: Hex koordinat matematiğinde Axial (q,r) formatı seçimi
  ```

#### `/architecture-review`
- **📌 Görevi:** Proje mimarisinin GDD ve teknik gereksinimlerle tutarlılığını ve eksiksizliğini denetler.
- **💡 Bu Projede Kullanımı:** Singleton sınıfların ve sinyal mimarisinin motorda döngüsel bağımlılık yaratmadığını doğrulamak için.
- **🎯 Örnek İstem:**
  ```text
  /architecture-review scripts/SaveManager.gd ve SoundManager.gd yapısı
  ```

#### `/tech-debt`
- **📌 Görevi:** Kod tabanındaki teknik borçları kategorize eder, kayıt altına alır ve geri ödeme planı önerir.
- **💡 Bu Projede Kullanımı:** Main.gd içerisindeki menü yönetimlerini ayrı kontrolcülere bölmek için teknik borç planı çıkarmada.
- **🎯 Örnek İstem:**
  ```text
  /tech-debt Main.gd içerisindeki 2000 satırlık dev scriptin refaktör planı
  ```

#### `/propagate-design-change`
- **📌 Görevi:** GDD güncellendiğinde etkilenen mimari kararları ve stale hale gelen ADR'leri tespit eder.
- **💡 Bu Projede Kullanımı:** Şato etrafında artık deniz çıkmama kuralı geldiğinde, harita jeneratörünü ve ilgili testleri otomatik tespit etmek için.
- **🎯 Örnek İstem:**
  ```text
  /propagate-design-change Şato 1. halka biyom kuralı değişikliği
  ```

---

### 4. Görev, Sprint & Proje Yönetimi Yetenekleri

#### `/create-epics` & `/create-stories`
- **📌 Görevi:** Büyük tasarım hedeflerini modül epiklerine ve ardından 15-30 dakikalık geliştirici hikayelerine böler.
- **🎯 Örnek İstem:**
  ```text
  /create-epics Tier 3 Üretim Zinciri: Taş Fırın ve Mobilya Atölyesi
  /create-stories Epic-04: Fırın ve Değirmen Entegrasyonu
  ```

#### `/sprint-plan` & `/sprint-status`
- **📌 Görevi:** Yeni sprint planı oluşturur ve mevcut ilerlemeyi grafiksel/metinsel olarak raporlar.
- **🎯 Örnek İstem:**
  ```text
  /sprint-plan Sprint 3: Prestij Sistemi ve İstatistikler Tablosu
  /sprint-status
  ```

#### `/story-readiness` & `/story-done`
- **📌 Görevi:** Bir görevin geliştirmeye hazır olduğunu denetler veya tamamlandığında testlerini yapıp hikayeyi kapatır.
- **🎯 Örnek İstem:**
  ```text
  /story-readiness Story-12: Orman Biyomunu Çayıra Çevirme
  /story-done Story-12
  ```

---

### 5. Kodlama, İnceleme & Canlı Hata Düzeltme (Dev & Review)

#### `/dev-story`
- **📌 Görevi:** Kullanıcı hikayesini motora (Godot/JS) uygun kodlama ve test etme.
- **🎯 Örnek İstem:**
  ```text
  /dev-story Story-15: Binaların Yıkılması ve %50 Kaynak İadesi
  ```

#### `/code-review`
- **📌 Görevi:** SOLID ilkeleri, Godot standartları ve performans için kod incelemesi.
- **🎯 Örnek İstem:**
  ```text
  /code-review scripts/Main.gd ve game.js
  ```

#### `/hotfix`
- **📌 Görevi:** Canlıdaki acil hatalar için hızlı ve güvenli yama akışı.
- **🎯 Örnek İstem:**
  ```text
  /hotfix Prestij onay popup'ında Localization argüman eksikliği hatası
  ```

---

### 6. Kalite Güvence, Hata Takibi & Test (QA & Testing)

#### `/smoke-check` & `/qa-plan`
- **📌 Görevi:** Kritik yol testlerini (Smoke Test) çalıştırır ve kapsamlı QA test planı hazırlar.
- **🎯 Örnek İstem:**
  ```text
  /smoke-check
  /qa-plan Prestij Sıfırlaması ve Kraliyet Tacı Çarpanları
  ```

#### `/bug-report` & `/bug-triage`
- **📌 Görevi:** Hata raporlarını standartlaştırır ve önem derecelerine göre önceliklendirir.
- **🎯 Örnek İstem:**
  ```text
  /bug-report Orman karosu 1. seviye şatoda kilitli uyarısı vermiyor
  /bug-triage
  ```

---

### 7. Kullanıcı Deneyimi, Görsel Sanat & Arayüz (UI/UX & Art)

#### `/ux-design` & `/ux-review`
- **📌 Görevi:** Yeni ekranlar ve HUD için UX kılavuzu hazırlar ve erişilebilirlik denetimi yapar.
- **🎯 Örnek İstem:**
  ```text
  /ux-design Krallık İstatistikleri ve Başarımlar Çekmecesi (Drawer UI)
  /ux-review Mobil ekranlarda buton boyutu ve dokunmatik isabet alanları
  ```

#### `/art-bible` & `/asset-spec`
- **📌 Görevi:** Görsel stil rehberi ve yapay zeka grafik prompt spesifikasyonları oluşturur.
- **🎯 Örnek İstem:**
  ```text
  /art-bible İzometrik Ortaçağ Fantezi ve Şirin Pastel Renk Paleti
  /asset-spec Seviye 1-10 Şato Görselleri ve İnşaat İkonları
  ```

---

### 8. Ses, Hikaye, Harita & Seviye Tasarımı

#### `/team-audio`
- **📌 Görevi:** Prosedürel sentezleyici (synthesizer) ve ses efektleri tasarımı.
- **🎯 Örnek İstem:**
  ```text
  /team-audio AudioStreamGenerator ile prosedürel synthesizer ses efektleri
  ```

#### `/team-narrative`
- **📌 Görevi:** Krallık diyalogları (Dialogic 2) ve görev anlatı kurgusu.
- **🎯 Örnek İstem:**
  ```text
  /team-narrative Kral Danışmanı ve Tüccar Diyalogları (Dialogic 2 entegrasyonu)
  ```

#### `/team-level`
- **📌 Görevi:** Altıgen harita oluşturma ve biyom dağılım algoritmaları.
- **🎯 Örnek İstem:**
  ```text
  /team-level 3 Bölge Harita Jeneratörü ve Biyom Kümelenme Algoritması
  ```

---

### 9. Sürüm, Yerelleştirme & Yayınlama (Release & Live-Ops)

#### `/localize`
- **📌 Görevi:** Çoklu dil (TR, EN, ES, DE) çeviri yönetimi ve eksik anahtar taraması.
- **🎯 Örnek İstem:**
  ```text
  /localize TR, EN, ES, DE dilleri için eksik anahtar taraması
  ```

#### `/patch-notes` & `/changelog`
- **📌 Görevi:** Oyuncular için anlaşılır yama notları ve dahili değişiklik günlükleri üretme.
- **🎯 Örnek İstem:**
  ```text
  /patch-notes v1.2.0: Binaları Yıkma ve Orman Kurutma Güncellemesi
  /changelog v1.1.0 -> v1.2.0
  ```

#### `/release-checklist`
- **📌 Görevi:** Web PWA, service worker ve masaüstü sürüm öncesi kontrol listesi.
- **🎯 Örnek İstem:**
  ```text
  /release-checklist Web PWA ve Windows Desktop Build
  ```

---

### 10. Yapay Zeka İstemi Optimizasyonu & Genel Yardım

#### `/prompt-optimizer`
- **📌 Görevi:** İsteklerinizi ROCCA mimarisinde profesyonel YZ promptuna dönüştürme.
- **🎯 Örnek İstem:**
  ```text
  /prompt-optimizer oyuna yeni bir pazar yeri binası eklemek istiyorum
  ```

#### `/help` & `/onboard`
- **📌 Görevi:** Geliştirme sürecinde sıradaki adım için rehberlik ve yeni oturum oryantasyonu.
- **🎯 Örnek İstem:**
  ```text
  /help
  /onboard
  ```
